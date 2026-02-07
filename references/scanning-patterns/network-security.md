# Network Security Scanning Patterns (CC6.6-6.7)

For policy: **Network Security** (`network-security`)
See [shared.md](shared.md) for evidence formatting and value usage guidelines.

## Basic Detection

**TLS/SSL Configuration:**
```
Glob: **/*.{tf,yaml,yml,conf}, **/nginx/**, **/config/**
Grep: ssl.?(cert|protocol)|tls.?(version|policy)|https.?(only|redirect|enforce)|force.?ssl|min.?tls.?version|listener.*443
```

## Deep Scanning (Value Extraction)

### TLS Version and Cipher Configuration

Extract minimum TLS version, SSL policy name, and cipher suites.

**Find files:**
```
Glob: **/*.tf, **/nginx/**/*.conf, **/config/**/*.{yaml,yml,json,ts,js}, **/infrastructure/**/*.*, **/*tls*.*, **/*ssl*.*
```

**Extract values:**
```
Grep: ssl_protocols\s+((?:TLSv[\d.]+\s*)+)  → Nginx TLS protocols
Grep: ssl_policy\s*=\s*["']([^"']+)["']  → AWS ALB SSL policy (encodes TLS version)
Grep: (?:minimum_tls_version|min_tls_version|tls_version)\s*=\s*["']?(TLS(?:v)?[\d_.]+|1\.[0-3])["']?  → explicit TLS version
Grep: (?:minVersion|secureProtocol)\s*[:=]\s*['"]?(TLSv[\d_.]+|TLS[\d_.]+)['"]?  → Node.js TLS version
Grep: ssl_ciphers\s+['"]?([^;'"]+)['"]?  → Nginx cipher suites
Grep: minimum_protocol_version\s*=\s*["']([^"']+)["']  → CloudFront minimum TLS
```

**Use in policy text:**
- Instead of: "Data in transit is encrypted using TLS"
- Write: "All data in transit is encrypted using **TLS 1.2 minimum** enforced by ALB policy `ELBSecurityPolicy-TLS-1-2-2017-01` (see `infrastructure/alb.tf:55`). Nginx accepts only **TLSv1.2 and TLSv1.3** (see `nginx/nginx.conf:8`)."

### CORS Configuration

Extract allowed origins, methods, and credential settings.

**Find files:**
```
Glob: **/config/**/*.{ts,js,py,go,json,yaml,yml}, **/middleware/**/*.{ts,js,py,go}, **/server.*, **/app.*, **/*cors*.*, **/nginx/**/*.conf
```

**Extract values:**
```
Grep: (?:origin|allowedOrigins)\s*[:=]\s*\[([^\]]+)\]  → allowed origins array
Grep: (?:origin)\s*[:=]\s*['"]\*['"]  → wildcard origin (flag as security concern)
Grep: (?:methods|allowedMethods|allow_methods)\s*[:=]\s*\[?['"]?([A-Z,\s]+)['"]?\]?  → allowed methods
Grep: (?:credentials|allow_credentials)\s*[:=]\s*(true|false)  → credentials flag
Grep: CORS_ALLOWED_ORIGINS\s*=\s*\[([^\]]+)\]  → Django CORS origins
Grep: CORS_ALLOW_ALL_ORIGINS\s*=\s*(True)  → Django wildcard CORS (flag as security concern)
```

**Use in policy text:**
- Instead of: "Cross-origin resource sharing is configured to restrict access"
- Write: "CORS is configured to allow requests only from **https://app.example.com** and **https://admin.example.com** (see `src/config/cors.ts:5-8`)."

### HSTS and Security Headers

Extract HSTS max-age, includeSubDomains, preload, and CSP directives.

**Find files:**
```
Glob: **/middleware/**/*.{ts,js,py,go}, **/config/**/*.{ts,js,py,go,json}, **/nginx/**/*.conf, **/*security*.*, **/*header*.*, **/*helmet*.*
```

**Extract values:**
```
Grep: [Ss]trict-[Tt]ransport-[Ss]ecurity.*max-age=(\d+)  → HSTS max-age (seconds)
Grep: [Ss]trict-[Tt]ransport-[Ss]ecurity.*?(includeSubDomains)  → HSTS includeSubDomains flag
Grep: [Ss]trict-[Tt]ransport-[Ss]ecurity.*?(preload)  → HSTS preload flag
Grep: SECURE_HSTS_SECONDS\s*=\s*(\d+)  → Django HSTS seconds
Grep: [Cc]ontent-[Ss]ecurity-[Pp]olicy['"]?\s*[:=]\s*['"]([^'"]+)['"]  → CSP header string
Grep: (?:defaultSrc|scriptSrc|styleSrc|imgSrc|connectSrc)\s*[:=]\s*\[([^\]]+)\]  → Helmet CSP directives
```

**Use in policy text:**
- Instead of: "HTTP Strict Transport Security is enabled"
- Write: "HSTS is enforced with **max-age=31536000 (1 year), includeSubDomains, preload** (see `nginx/nginx.conf:15`)."

## Example Evidence Table

| Control | Extracted Value | File | Line | Raw Evidence |
|---------|----------------|------|------|-------------|
| TLS minimum version | **TLS 1.2** | infrastructure/alb.tf | 55 | `ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01"` |
| HSTS | **1 year, includeSubDomains, preload** | nginx/nginx.conf | 15 | `max-age=31536000; includeSubDomains; preload` |
| CORS origins | **app.example.com, admin.example.com** | src/config/cors.ts | 5-8 | `origin: ['https://app.example.com', ...]` |

## Cloud Scanning Cross-Reference

For live infrastructure evidence related to network security:
- AWS: ALB TLS, security groups, WAF, CloudFront TLS -- see [aws.md](aws.md#network-security-cc66-67)
- GCP: SSL policies, firewall rules, Cloud Armor -- see [gcp.md](gcp.md#network-security-cc66-67)
- Azure: NSGs, Application Gateway WAF/TLS, Front Door -- see [azure.md](azure.md#network-security-cc66-67)
