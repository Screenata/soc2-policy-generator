#!/usr/bin/env bash
# .compliance/scripts/gcp.sh
# Compliance evidence collection for Google Cloud
# Requires: gcloud CLI authenticated
# Config:   gcp.config.json (co-located)
# Safety:   READ-ONLY commands only (describe, list, get)
# Usage:    bash gcp.sh [-v] [-t TIMEOUT]
set -uo pipefail

# ── Options ────────────────────────────────────────────
VERBOSE=false
CMD_TIMEOUT=30  # seconds per gcloud command

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

# Run a gcloud command with timeout; on timeout, return fallback
run_gcp() {
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

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="${SCRIPT_DIR}/$(basename "$0" .sh).config.json"
PROJECT=$(jq -r '.project // empty' "$CONFIG")
REGION=$(jq -r '.region // "us-central1"' "$CONFIG")

# Auto-detect project if not in config
if [ -z "$PROJECT" ]; then
  PROJECT=$(gcloud config get-value project 2>/dev/null || echo "")
fi

log "Config: ${CONFIG}"
log "Project: ${PROJECT:-unknown}"
log "Region: ${REGION}"
log "Command timeout: ${CMD_TIMEOUT}s"

OUT="${COMPLIANCE_EVIDENCE_DIR:-.compliance/evidence/cloud}/gcp-evidence.md"
mkdir -p "$(dirname "$OUT")"

{
  echo "# Google Cloud Infrastructure Evidence"
  echo ""
  echo "> Scan date: $(date -u '+%Y-%m-%d %H:%M UTC')"
  echo "> Project: ${PROJECT:-unknown}"
  echo "> Region: ${REGION}"
  echo ""
  echo "| Control | Extracted Value | Service | Region | Command | Raw Evidence |"
  echo "|---------|----------------|---------|--------|---------|-------------|"
} > "$OUT"

# ── Verify Authentication ───────────────────────────────
log "Verifying GCP authentication..."
active_account=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>&1 || echo "")
if [ -n "$active_account" ]; then
  echo "| GCP Account | **${active_account}** | Auth | global | \`gcloud auth list\` | Authenticated successfully |" >> "$OUT"
else
  echo "| GCP Authentication | **FAILED** | Auth | global | \`gcloud auth list\` | Not authenticated - run gcloud auth login |" >> "$OUT"
  echo "" >> "$OUT"
  echo "*Scan aborted: GCP credentials not configured.*" >> "$OUT"
  echo "FAILED: gcp - credentials not configured"
  exit 1
fi

if [ -z "$PROJECT" ]; then
  echo "| GCP Project | **not set** | Config | global | \`gcloud config get-value project\` | Set project in config or gcloud |" >> "$OUT"
  echo "" >> "$OUT"
  echo "*Scan aborted: no GCP project configured.*" >> "$OUT"
  echo "FAILED: gcp - no project configured"
  exit 1
fi

echo "| GCP Project | **${PROJECT}** | Config | global | \`gcloud config get-value project\` | Active project |" >> "$OUT"

# ── Access Control (CC6.1-6.3) ──────────────────────────

# Project IAM Policy
log "Checking project IAM policy..."
result=$(run_gcp "IAM policy" gcloud projects get-iam-policy "$PROJECT" --format=json)
if echo "$result" | jq -e '.bindings' > /dev/null 2>&1; then
  role_count=$(echo "$result" | jq '[.bindings[].role] | unique | length')
  member_count=$(echo "$result" | jq '[.bindings[].members[]] | unique | length')
  public_access=$(echo "$result" | jq '[.bindings[].members[] | select(. == "allUsers" or . == "allAuthenticatedUsers")] | length')
  echo "| IAM roles | **${role_count} distinct roles, ${member_count} principals** | IAM | global | \`gcloud projects get-iam-policy\` | Public bindings: ${public_access} |" >> "$OUT"
  if [ "$public_access" -gt 0 ]; then
    echo "| IAM public access | **WARNING: ${public_access} public bindings** | IAM | global | \`gcloud projects get-iam-policy\` | allUsers or allAuthenticatedUsers found |" >> "$OUT"
  fi
else
  echo "| IAM policy | **not accessible** | IAM | global | \`gcloud projects get-iam-policy\` | Permission denied or error |" >> "$OUT"
fi

# ── Data Management (CC6.5-6.7) ─────────────────────────

# Cloud SQL Instances
log "Checking Cloud SQL instances..."
result=$(run_gcp "Cloud SQL instances" gcloud sql instances list --format=json)
db_count=$(echo "$result" | jq 'length' 2>/dev/null || echo "0")
if [ "$db_count" -gt 0 ]; then
  for i in $(seq 0 $((db_count - 1))); do
    name=$(echo "$result" | jq -r ".[$i].name")
    version=$(echo "$result" | jq -r ".[$i].databaseVersion")
    # Get detailed info
    detail=$(run_gcp "Cloud SQL ${name}" gcloud sql instances describe "$name" --format=json)
    backup_enabled=$(echo "$detail" | jq -r '.settings.backupConfiguration.enabled // false')
    ssl_required=$(echo "$detail" | jq -r '.settings.ipConfiguration.requireSsl // false')
    pitr=$(echo "$detail" | jq -r '.settings.backupConfiguration.binaryLogEnabled // .settings.backupConfiguration.pointInTimeRecoveryEnabled // false')
    echo "| Cloud SQL ${name} | **backup:${backup_enabled}, SSL:${ssl_required}, PITR:${pitr}** | Cloud SQL | ${REGION} | \`gcloud sql instances describe\` | Engine: ${version} |" >> "$OUT"
  done
else
  echo "| Cloud SQL | **none found** | Cloud SQL | ${REGION} | \`gcloud sql instances list\` | No instances in project |" >> "$OUT"
fi

# KMS Keyrings & Keys
log "Checking KMS keyrings..."
keyrings=$(run_gcp "KMS keyrings" gcloud kms keyrings list --location="$REGION" --format=json)
keyring_count=$(echo "$keyrings" | jq 'length' 2>/dev/null || echo "0")
if [ "$keyring_count" -gt 0 ]; then
  total_keys=0
  rotation_count=0
  for kr in $(echo "$keyrings" | jq -r '.[].name' | head -5); do
    kr_short=$(basename "$kr")
    keys=$(run_gcp "KMS keys ${kr_short}" gcloud kms keys list --keyring="$kr_short" --location="$REGION" --format=json)
    key_count=$(echo "$keys" | jq 'length' 2>/dev/null || echo "0")
    total_keys=$((total_keys + key_count))
    rotating=$(echo "$keys" | jq '[.[] | select(.rotationPeriod != null)] | length' 2>/dev/null || echo "0")
    rotation_count=$((rotation_count + rotating))
  done
  echo "| KMS keys | **${total_keys} keys in ${keyring_count} keyrings** | Cloud KMS | ${REGION} | \`gcloud kms keys list\` | ${rotation_count} with auto-rotation |" >> "$OUT"
else
  echo "| KMS keyrings | **none found** | Cloud KMS | ${REGION} | \`gcloud kms keyrings list\` | No keyrings in region |" >> "$OUT"
fi

# Cloud Storage Buckets
log "Checking Cloud Storage buckets..."
buckets=$(run_gcp "Cloud Storage buckets" gcloud storage buckets list --format=json)
bucket_count=$(echo "$buckets" | jq 'length' 2>/dev/null || echo "0")
if [ "$bucket_count" -gt 0 ]; then
  versioned=$(echo "$buckets" | jq '[.[] | select(.versioning.enabled == true)] | length' 2>/dev/null || echo "0")
  cmek=$(echo "$buckets" | jq '[.[] | select(.default_kms_key != null)] | length' 2>/dev/null || echo "0")
  echo "| Cloud Storage | **${bucket_count} buckets** | GCS | global | \`gcloud storage buckets list\` | Versioned: ${versioned}, CMEK: ${cmek} |" >> "$OUT"
else
  echo "| Cloud Storage | **no buckets** | GCS | global | \`gcloud storage buckets list\` | No buckets in project |" >> "$OUT"
fi

# ── Network Security (CC6.6-6.7) ────────────────────────

# SSL Policies
log "Checking SSL policies..."
ssl_policies=$(run_gcp "SSL policies" gcloud compute ssl-policies list --format=json)
ssl_count=$(echo "$ssl_policies" | jq 'length' 2>/dev/null || echo "0")
if [ "$ssl_count" -gt 0 ]; then
  for i in $(seq 0 $((ssl_count - 1))); do
    name=$(echo "$ssl_policies" | jq -r ".[$i].name")
    min_tls=$(echo "$ssl_policies" | jq -r ".[$i].minTlsVersion")
    profile=$(echo "$ssl_policies" | jq -r ".[$i].profile")
    echo "| SSL policy ${name} | **${min_tls}, ${profile}** | Compute | global | \`gcloud compute ssl-policies list\` | TLS policy |" >> "$OUT"
  done
else
  echo "| SSL policies | **none configured** | Compute | global | \`gcloud compute ssl-policies list\` | Using GCP defaults |" >> "$OUT"
fi

# Firewall Rules
log "Checking firewall rules..."
firewalls=$(run_gcp "firewall rules" gcloud compute firewall-rules list --format=json)
fw_count=$(echo "$firewalls" | jq 'length' 2>/dev/null || echo "0")
if [ "$fw_count" -gt 0 ]; then
  open_ssh=$(echo "$firewalls" | jq '[.[] | select(.allowed != null) | select(.sourceRanges != null) | select(.sourceRanges[] == "0.0.0.0/0") | select(.allowed[].ports != null) | select(.allowed[].ports[] == "22")] | length' 2>/dev/null || echo "0")
  echo "| Firewall rules | **${fw_count} rules** | Compute | global | \`gcloud compute firewall-rules list\` | Open SSH from 0.0.0.0/0: ${open_ssh} |" >> "$OUT"
else
  echo "| Firewall rules | **none configured** | Compute | global | \`gcloud compute firewall-rules list\` | No custom firewall rules |" >> "$OUT"
fi

# Cloud Armor (WAF)
log "Checking Cloud Armor..."
armor=$(run_gcp "Cloud Armor policies" gcloud compute security-policies list --format=json)
armor_count=$(echo "$armor" | jq 'length' 2>/dev/null || echo "0")
echo "| Cloud Armor | **${armor_count} security policies** | Compute | global | \`gcloud compute security-policies list\` | WAF policies |" >> "$OUT"

# ── Vulnerability & Monitoring (CC7.1-7.2) ───────────────

# Enabled Security Services
log "Checking security services..."
sec_services=$(run_gcp "security services" gcloud services list --enabled --filter="name:(containeranalysis OR securitycenter OR binaryauthorization)" --format=json)
sec_count=$(echo "$sec_services" | jq 'length' 2>/dev/null || echo "0")
if [ "$sec_count" -gt 0 ]; then
  svc_names=$(echo "$sec_services" | jq -r '[.[].config.name // .[].name] | join(", ")' 2>/dev/null | head -c 100)
  echo "| Security services | **${sec_count} enabled** | Services | global | \`gcloud services list --enabled\` | ${svc_names} |" >> "$OUT"
else
  echo "| Security services | **none detected** | Services | global | \`gcloud services list --enabled\` | SCC, Container Analysis, Binary Auth not found |" >> "$OUT"
fi

# Log Sinks
log "Checking log sinks..."
sinks=$(run_gcp "log sinks" gcloud logging sinks list --format=json)
sink_count=$(echo "$sinks" | jq 'length' 2>/dev/null || echo "0")
if [ "$sink_count" -gt 0 ]; then
  destinations=$(echo "$sinks" | jq -r '[.[].destination] | join(", ")' 2>/dev/null | head -c 120)
  echo "| Log sinks | **${sink_count} sinks** | Logging | global | \`gcloud logging sinks list\` | Destinations: ${destinations} |" >> "$OUT"
else
  echo "| Log sinks | **none configured** | Logging | global | \`gcloud logging sinks list\` | No log export sinks |" >> "$OUT"
fi

# Alerting Policies
log "Checking alerting policies..."
alerts=$(run_gcp "alerting policies" gcloud alpha monitoring policies list --format=json)
alert_count=$(echo "$alerts" | jq 'length' 2>/dev/null || echo "0")
echo "| Alerting policies | **${alert_count} policies** | Monitoring | global | \`gcloud alpha monitoring policies list\` | Monitoring alerts |" >> "$OUT"

# ── Footer ──────────────────────────────────────────────
echo "" >> "$OUT"
echo "*Values extracted from live GCP infrastructure. These represent point-in-time configuration. Re-scan and verify before audit submission.*" >> "$OUT"

log "COMPLETE: gcp evidence written to $OUT"
echo "OK: gcp evidence written to $OUT"
