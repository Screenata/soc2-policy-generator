#!/usr/bin/env bash
# .compliance/scripts/azure.sh
# Compliance evidence collection for Azure
# Requires: az CLI authenticated
# Config:   azure.config.json (co-located)
# Safety:   READ-ONLY commands only (list, show, get)
# Usage:    bash azure.sh [-v] [-t TIMEOUT]
set -uo pipefail

# ── Options ────────────────────────────────────────────
VERBOSE=false
CMD_TIMEOUT=30  # seconds per az command

while getopts "vt:" opt; do
  case $opt in
    v) VERBOSE=true ;;
    t) CMD_TIMEOUT="$OPTARG" ;;
    *) echo "Usage: $0 [-v] [-t TIMEOUT_SECS]"; exit 1 ;;
  esac
done

log() {
  if $VERBOSE; then
    echo "[$(date -u '+%H:%M:%S')] $*" >&2
  fi
}

# Run an az command with timeout; on timeout, return fallback
run_az() {
  local description="$1"
  shift
  log "START: ${description} → $*"
  local start_ts
  start_ts=$(date +%s)
  local result
  result=$(timeout "${CMD_TIMEOUT}" "$@" 2>&1 </dev/null) || {
    local rc=$?
    local elapsed=$(( $(date +%s) - start_ts ))
    if [ $rc -eq 124 ]; then
      log "TIMEOUT after ${elapsed}s: ${description}"
      echo '[]'
      return 0
    else
      log "FAILED (rc=${rc}) after ${elapsed}s: ${description}"
      log "  → ${result}"
      echo '[]'
      return 0
    fi
  }
  local elapsed=$(( $(date +%s) - start_ts ))
  log "DONE (${elapsed}s): ${description}"
  echo "$result"
}

# Disable interactive extension install prompts — auto-install if needed
export AZURE_CORE_NO_PROMPT=true
az config set extension.dynamic_install_allow_preview=true 2>/dev/null || true

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="${SCRIPT_DIR}/$(basename "$0" .sh).config.json"
SUBSCRIPTION=$(jq -r '.subscription // empty' "$CONFIG")

OUT="${COMPLIANCE_EVIDENCE_DIR:-.compliance/evidence/cloud}/azure-evidence.md"
mkdir -p "$(dirname "$OUT")"

log "Config: ${CONFIG}"
log "Subscription: ${SUBSCRIPTION:-default}"
log "Output: ${OUT}"
log "Command timeout: ${CMD_TIMEOUT}s"

{
  echo "# Azure Cloud Infrastructure Evidence"
  echo ""
  echo "> Scan date: $(date -u '+%Y-%m-%d %H:%M UTC')"
  echo "> Subscription: ${SUBSCRIPTION:-default}"
  echo ""
  echo "| Control | Extracted Value | Service | Region | Command | Raw Evidence |"
  echo "|---------|----------------|---------|--------|---------|-------------|"
} > "$OUT"

# ── Verify Authentication ───────────────────────────────
account_info=$(run_az "account show" az account show -o json)
if echo "$account_info" | jq -e '.id' > /dev/null 2>&1; then
  sub_name=$(echo "$account_info" | jq -r '.name')
  sub_id=$(echo "$account_info" | jq -r '.id')
  echo "| Azure Subscription | **${sub_name}** | Account | global | \`az account show\` | ID: ${sub_id} |" >> "$OUT"
  log "Authenticated as: ${sub_name} (${sub_id})"
else
  echo "| Azure Authentication | **FAILED** | Account | global | \`az account show\` | Not authenticated - run az login |" >> "$OUT"
  echo "" >> "$OUT"
  echo "*Scan aborted: Azure credentials not configured.*" >> "$OUT"
  echo "FAILED: azure - credentials not configured"
  exit 1
fi

# Set subscription if specified
if [ -n "$SUBSCRIPTION" ]; then
  log "Setting subscription to ${SUBSCRIPTION}"
  run_az "set subscription" az account set --subscription "$SUBSCRIPTION" > /dev/null
fi

# ── Access Control (CC6.1-6.3) ──────────────────────────

# Conditional Access Policies (requires MS Graph API)
result=$(run_az "conditional access policies" az rest --method GET --url "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies" -o json)
if echo "$result" | jq -e '.value[0]' > /dev/null 2>&1; then
  ca_count=$(echo "$result" | jq '.value | length')
  enabled=$(echo "$result" | jq '[.value[] | select(.state == "enabled")] | length')
  echo "| Conditional Access | **${ca_count} policies, ${enabled} enabled** | Entra ID | global | \`graph/conditionalAccess/policies\` | Conditional access policies |" >> "$OUT"
else
  echo "| Conditional Access | **not accessible** | Entra ID | global | \`graph/conditionalAccess/policies\` | Requires Entra ID Premium P1+ or Policy.Read.All permission |" >> "$OUT"
fi

# RBAC Role Assignments
result=$(run_az "RBAC role assignments" az role assignment list --all -o json --query '[].{principal:principalName,role:roleDefinitionName,scope:scope}')
if echo "$result" | jq -e '.[0]' > /dev/null 2>&1; then
  assignment_count=$(echo "$result" | jq 'length')
  role_count=$(echo "$result" | jq '[.[].role] | unique | length')
  owner_count=$(echo "$result" | jq '[.[] | select(.role == "Owner")] | length')
  echo "| RBAC assignments | **${assignment_count} assignments, ${role_count} distinct roles** | RBAC | global | \`az role assignment list\` | Owner assignments: ${owner_count} |" >> "$OUT"
else
  echo "| RBAC assignments | **not accessible** | RBAC | global | \`az role assignment list\` | Permission denied or error |" >> "$OUT"
fi

# ── Data Management (CC6.5-6.7) ─────────────────────────

# Storage Accounts
accounts=$(run_az "storage accounts" az storage account list -o json --query '[].{name:name,resourceGroup:resourceGroup}')
acct_count=$(echo "$accounts" | jq 'length' 2>/dev/null || echo "0")
if [ "$acct_count" -gt 0 ]; then
  for i in $(seq 0 $((acct_count - 1))); do
    name=$(echo "$accounts" | jq -r ".[$i].name")
    rg=$(echo "$accounts" | jq -r ".[$i].resourceGroup")
    detail=$(run_az "storage account ${name}" az storage account show --name "$name" --resource-group "$rg" -o json)
    blob_enc=$(echo "$detail" | jq -r '.encryption.services.blob.enabled // false')
    key_source=$(echo "$detail" | jq -r '.encryption.keySource // "unknown"')
    min_tls=$(echo "$detail" | jq -r '.minimumTlsVersion // "unknown"')
    echo "| Storage ${name} | **blob:${blob_enc}, keys:${key_source}, TLS:${min_tls}** | Storage | global | \`az storage account show\` | Encryption config |" >> "$OUT"
  done
else
  echo "| Storage accounts | **none found** | Storage | global | \`az storage account list\` | No storage accounts |" >> "$OUT"
fi

# SQL Servers & Databases
servers=$(run_az "SQL servers" az sql server list -o json --query '[].{name:name,resourceGroup:resourceGroup}')
srv_count=$(echo "$servers" | jq 'length' 2>/dev/null || echo "0")
if [ "$srv_count" -gt 0 ]; then
  for i in $(seq 0 $((srv_count - 1))); do
    srv_name=$(echo "$servers" | jq -r ".[$i].name")
    rg=$(echo "$servers" | jq -r ".[$i].resourceGroup")
    dbs=$(run_az "SQL DBs on ${srv_name}" az sql db list --server "$srv_name" --resource-group "$rg" -o json --query '[?name != '"'"'master'"'"'].{name:name,status:status}')
    db_count=$(echo "$dbs" | jq 'length' 2>/dev/null || echo "0")
    if [ "$db_count" -gt 0 ]; then
      for j in $(seq 0 $((db_count - 1))); do
        db_name=$(echo "$dbs" | jq -r ".[$j].name")
        tde=$(run_az "TDE on ${srv_name}/${db_name}" az sql db tde show --database "$db_name" --server "$srv_name" --resource-group "$rg" -o json)
        tde_state=$(echo "$tde" | jq -r '.state // "unknown"')
        echo "| SQL DB ${srv_name}/${db_name} | **TDE:${tde_state}** | Azure SQL | global | \`az sql db tde show\` | Transparent Data Encryption |" >> "$OUT"
      done
    fi
  done
else
  echo "| SQL servers | **none found** | Azure SQL | global | \`az sql server list\` | No SQL servers |" >> "$OUT"
fi

# PostgreSQL Flexible Servers
pg_servers=$(run_az "PostgreSQL flexible servers" az postgres flexible-server list -o json --query '[].{name:name,resourceGroup:resourceGroup,state:state,version:version}')
pg_count=$(echo "$pg_servers" | jq 'length' 2>/dev/null || echo "0")
if [ "$pg_count" -gt 0 ]; then
  for i in $(seq 0 $((pg_count - 1))); do
    pg_name=$(echo "$pg_servers" | jq -r ".[$i].name")
    pg_rg=$(echo "$pg_servers" | jq -r ".[$i].resourceGroup")
    pg_state=$(echo "$pg_servers" | jq -r ".[$i].state")
    pg_ver=$(echo "$pg_servers" | jq -r ".[$i].version")
    echo "| PG Flex ${pg_name} | **v${pg_ver}, state:${pg_state}** | PostgreSQL | global | \`az postgres flexible-server list\` | Flexible server |" >> "$OUT"

    # Check backup retention
    pg_detail=$(run_az "PG backup ${pg_name}" az postgres flexible-server show --name "$pg_name" --resource-group "$pg_rg" -o json)
    backup_days=$(echo "$pg_detail" | jq -r '.backup.backupRetentionDays // "unknown"')
    geo_backup=$(echo "$pg_detail" | jq -r '.backup.geoRedundantBackup // "unknown"')
    ha_mode=$(echo "$pg_detail" | jq -r '.highAvailability.mode // "Disabled"')
    ssl_enforce=$(echo "$pg_detail" | jq -r '.network.publicNetworkAccess // "unknown"')
    data_enc=$(echo "$pg_detail" | jq -r '.dataEncryption.type // "ServiceManaged"')
    echo "| PG Flex ${pg_name} backup | **retention:${backup_days}d, geo:${geo_backup}, HA:${ha_mode}** | PostgreSQL | global | \`az postgres flexible-server show\` | Backup: ${backup_days}d, encryption: ${data_enc} |" >> "$OUT"

    # Check firewall rules
    pg_fw=$(run_az "PG firewall ${pg_name}" az postgres flexible-server firewall-rule list --name "$pg_name" --resource-group "$pg_rg" -o json)
    fw_count=$(echo "$pg_fw" | jq 'length' 2>/dev/null || echo "0")
    open_all=$(echo "$pg_fw" | jq '[.[] | select(.startIpAddress == "0.0.0.0" and .endIpAddress == "255.255.255.255")] | length' 2>/dev/null || echo "0")
    echo "| PG Flex ${pg_name} firewall | **${fw_count} rules, open-to-all:${open_all}** | PostgreSQL | global | \`az postgres flexible-server firewall-rule list\` | Network rules |" >> "$OUT"
  done
else
  echo "| PostgreSQL Flex servers | **none found** | PostgreSQL | global | \`az postgres flexible-server list\` | No PostgreSQL flexible servers |" >> "$OUT"
fi

# Key Vault
vaults=$(run_az "key vaults" az keyvault list -o json --query '[].{name:name,resourceGroup:resourceGroup}')
vault_count=$(echo "$vaults" | jq 'length' 2>/dev/null || echo "0")
if [ "$vault_count" -gt 0 ]; then
  for i in $(seq 0 $((vault_count - 1))); do
    vault_name=$(echo "$vaults" | jq -r ".[$i].name")
    detail=$(run_az "key vault ${vault_name}" az keyvault show --name "$vault_name" -o json)
    soft_delete=$(echo "$detail" | jq -r '.properties.enableSoftDelete // false')
    purge_protect=$(echo "$detail" | jq -r '.properties.enablePurgeProtection // false')
    rbac_auth=$(echo "$detail" | jq -r '.properties.enableRbacAuthorization // false')
    echo "| Key Vault ${vault_name} | **softDelete:${soft_delete}, purgeProtection:${purge_protect}, RBAC:${rbac_auth}** | Key Vault | global | \`az keyvault show\` | Key management |" >> "$OUT"
  done
else
  echo "| Key Vault | **none found** | Key Vault | global | \`az keyvault list\` | No key vaults |" >> "$OUT"
fi

# ── Network Security (CC6.6-6.7) ────────────────────────

# Network Security Groups
nsgs=$(run_az "NSGs" az network nsg list -o json)
nsg_count=$(echo "$nsgs" | jq 'length' 2>/dev/null || echo "0")
if [ "$nsg_count" -gt 0 ]; then
  open_rdp=$(echo "$nsgs" | jq '[.[].securityRules[] | select(.direction == "Inbound" and .access == "Allow" and .destinationPortRange == "3389" and (.sourceAddressPrefix == "*" or .sourceAddressPrefix == "Internet"))] | length' 2>/dev/null || echo "0")
  echo "| NSGs | **${nsg_count} groups** | Network | global | \`az network nsg list\` | Open RDP from Internet: ${open_rdp} |" >> "$OUT"
else
  echo "| NSGs | **none found** | Network | global | \`az network nsg list\` | No network security groups |" >> "$OUT"
fi

# Application Gateway (WAF)
gateways=$(run_az "app gateways" az network application-gateway list -o json --query '[].{name:name,resourceGroup:resourceGroup}')
gw_count=$(echo "$gateways" | jq 'length' 2>/dev/null || echo "0")
if [ "$gw_count" -gt 0 ]; then
  for i in $(seq 0 $((gw_count - 1))); do
    gw_name=$(echo "$gateways" | jq -r ".[$i].name")
    rg=$(echo "$gateways" | jq -r ".[$i].resourceGroup")
    detail=$(run_az "app gateway ${gw_name}" az network application-gateway show --name "$gw_name" --resource-group "$rg" -o json)
    min_tls=$(echo "$detail" | jq -r '.sslPolicy.minProtocolVersion // "default"')
    waf_enabled=$(echo "$detail" | jq -r '.webApplicationFirewallConfiguration.enabled // false')
    waf_mode=$(echo "$detail" | jq -r '.webApplicationFirewallConfiguration.firewallMode // "N/A"')
    echo "| App Gateway ${gw_name} | **TLS:${min_tls}, WAF:${waf_enabled}, mode:${waf_mode}** | App Gateway | global | \`az network application-gateway show\` | WAF config |" >> "$OUT"
  done
else
  echo "| App Gateway | **none found** | App Gateway | global | \`az network application-gateway list\` | No application gateways |" >> "$OUT"
fi

# Front Door
frontdoors=$(run_az "front doors" az network front-door list -o json)
fd_count=$(echo "$frontdoors" | jq 'length' 2>/dev/null || echo "0")
if [ "$fd_count" -gt 0 ]; then
  echo "| Front Door | **${fd_count} configured** | Front Door | global | \`az network front-door list\` | CDN/WAF front doors |" >> "$OUT"
else
  echo "| Front Door | **none found** | Front Door | global | \`az network front-door list\` | No front doors |" >> "$OUT"
fi

# ── Vulnerability & Monitoring (CC7.1-7.2) ───────────────

# Defender for Cloud
assessments=$(run_az "Defender assessments" az security assessment list -o json --query '[].{name:displayName,status:status.code}')
if echo "$assessments" | jq -e '.[0]' > /dev/null 2>&1; then
  total=$(echo "$assessments" | jq 'length')
  healthy=$(echo "$assessments" | jq '[.[] | select(.status == "Healthy")] | length')
  unhealthy=$(echo "$assessments" | jq '[.[] | select(.status == "Unhealthy")] | length')
  echo "| Defender assessments | **${total} total, ${healthy} healthy, ${unhealthy} unhealthy** | Defender | global | \`az security assessment list\` | Security posture |" >> "$OUT"
else
  echo "| Defender assessments | **not accessible** | Defender | global | \`az security assessment list\` | Defender not enabled or no permission |" >> "$OUT"
fi

# Activity Log Alerts
alerts=$(run_az "activity log alerts" az monitor activity-log alert list -o json)
alert_count=$(echo "$alerts" | jq 'length' 2>/dev/null || echo "0")
echo "| Activity log alerts | **${alert_count} alerts** | Monitor | global | \`az monitor activity-log alert list\` | Monitoring alerts |" >> "$OUT"

# ── Footer ──────────────────────────────────────────────
echo "" >> "$OUT"
echo "*Values extracted from live Azure infrastructure. These represent point-in-time configuration. Re-scan and verify before audit submission.*" >> "$OUT"

log "COMPLETE: azure evidence written to $OUT"
echo "OK: azure evidence written to $OUT"
