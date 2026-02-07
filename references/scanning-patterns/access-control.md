# Access Control Scanning Patterns (CC6.1-6.3)

For policy: **Access Control** (`access-control`)
See [shared.md](shared.md) for evidence formatting and value usage guidelines.

## Basic Detection

**Auth Middleware:**
```
Glob: **/middleware/**/*.{ts,js}, **/auth/**/*.{ts,js}, **/api/**/*.{ts,js}
Grep: withAuth|requireAuth|isAuthenticated|authMiddleware|passport\.(authenticate|use)
```

**JWT Validation:**
```
Glob: **/*.{ts,js}
Grep: jwt\.(verify|sign|decode)|jsonwebtoken|jose\.|verifyToken|Bearer.*token
```

**MFA Configuration:**
```
Glob: **/*.{ts,js,json,yaml,yml}
Grep: mfa|multi.?factor|two.?factor|2fa|totp|authenticator|otp
```

## Deep Scanning (Value Extraction)

### Password Format Requirements

Extract minimum length, complexity rules, and hashing configuration.

**Find files:**
```
Glob: **/config/**/*.{ts,js,py,go,json,yaml,yml}, **/auth/**/*.{ts,js,py,go}, **/validation/**/*.{ts,js,py,go}, **/schemas/**/*.{ts,js,py,go}, **/*password*.*, **/*auth*.*, **/*user*.*
```

**Extract values:**
```
Grep: (?:min(?:imum)?[_\-]?(?:length|len|Password[_\-]?Length))\s*[:=]\s*(\d+)  → password minimum length (number)
Grep: \.(?:min|minLength)\((\d+)\)  → Zod/Joi minimum length (number), only in files mentioning "password"
Grep: (?:requireUppercase|require_uppercase|uppercase)\s*[:=]\s*(true|True|1)  → uppercase required
Grep: (?:requireDigit|require_digit|requireNumber|require_number)\s*[:=]\s*(true|True|1)  → digit required
Grep: (?:requireSpecial|require_special|special[_\-]?char)\s*[:=]\s*(true|True|1)  → special char required
Grep: password.*(?:regex|pattern|match)\s*[:=]\s*[/'"](.+?)[/'"]  → password validation regex
Grep: bcrypt\.(?:hash|hashSync|genSalt|genSaltSync)\([^,]+,\s*(\d+)  → bcrypt rounds (JS/TS)
Grep: bcrypt\.gensalt\((?:rounds=)?(\d+)\)  → bcrypt rounds (Python)
Grep: bcrypt\.GenerateFromPassword\([^,]+,\s*(\d+)\)  → bcrypt cost (Go)
Grep: (?:argon2|Argon2).*(?:time[_\-]?cost|iterations)\s*[:=]\s*(\d+)  → argon2 iterations
Grep: (?:argon2|Argon2).*(?:memory[_\-]?cost|memory)\s*[:=]\s*(\d+)  → argon2 memory (KB)
Grep: pbkdf2.*(?:iterations|rounds)\s*[:=]\s*(\d+)  → PBKDF2 iterations
```

**Use in policy text:**
- Instead of: "Passwords must meet minimum complexity requirements"
- Write: "Passwords must be a minimum of **12 characters** with uppercase, lowercase, digit, and special character requirements (see `src/validation/password.ts:18`). Passwords are hashed using **bcrypt with a cost factor of 12** before storage (see `src/services/auth.ts:45`)."

### RBAC Roles and Permissions

Extract role names, permission definitions, and role-to-permission mappings.

**Find files:**
```
Glob: **/models/**/*.{ts,js,py,go}, **/types/**/*.{ts,js}, **/constants/**/*.{ts,js,py,go}, **/config/**/*.{ts,js,py,go,json,yaml,yml}, **/rbac/**/*.{ts,js,py,go}, **/permissions/**/*.{ts,js,py,go}, **/*role*.*, **/*permission*.*, **/prisma/schema.prisma, **/db/schema.*
```

**Extract values:**
```
Grep: enum\s+(?:Role|UserRole|Roles)\s*\{([^}]+)\}  → role enum body (TS/JS/Prisma)
Grep: (?:roles|ROLES|allowedRoles)\s*[:=]\s*\[([^\]]+)\]  → role array/list
Grep: (?:permission|Permission|PERMISSION)\s*[:=]\s*['"]([a-z_:]+\.(?:read|write|delete|create|admin|manage))['"]  → permission strings
Grep: @Roles?\(([^)]+)\)  → role decorator arguments (NestJS etc.)
Grep: (?:hasRole|requireRole|checkRole)\(['"](\w+)['"]  → role checks in middleware
Grep: (?:ROLE_CHOICES|role_choices)\s*=\s*\[([^\]]+)\]  → Python role choices
Grep: p,\s*(\w+),\s*(\S+),\s*(\w+)  → Casbin RBAC policy (role, resource, action)
```

**Use in policy text:**
- Instead of: "Access is managed using a role-based access control model"
- Write: "Access is managed using role-based access control with **4 defined roles: Admin, Editor, Viewer, and Billing** (see `src/models/user.ts:12`)."

### Session and Token Configuration

Extract session timeout, JWT expiry, refresh token lifetime, and cookie security settings.

**Find files:**
```
Glob: **/config/**/*.{ts,js,py,go,json,yaml,yml}, **/middleware/**/*.{ts,js,py,go}, **/auth/**/*.{ts,js,py,go}, **/*session*.*, **/*cookie*.*, **/*token*.*, .env.example, .env.sample
```

**Extract values:**
```
Grep: (?:expiresIn|exp|ttl|TOKEN_EXPIR(?:Y|ES|ATION))\s*[:=]\s*['"](\d+[smhd]|[\d.]+\s*(?:hour|minute|day|second)\w*)['"]  → token expiry (duration string)
Grep: (?:expiresIn|exp|ttl|maxAge)\s*[:=]\s*(\d+)\s*(?:\*\s*\d+)*  → token expiry (number, may have multipliers)
Grep: (?:maxAge|max_age|session[_\-]?timeout|SESSION_TIMEOUT|idle[_\-]?timeout)\s*[:=]\s*(\d+)  → session timeout (ms or seconds)
Grep: (?:secure|cookie.*secure)\s*[:=]\s*(true|false)  → cookie secure flag
Grep: (?:httpOnly|http_only)\s*[:=]\s*(true|false)  → cookie httpOnly flag
Grep: (?:sameSite|same_site)\s*[:=]\s*['"]?(Strict|Lax|None)['"]?  → cookie sameSite policy
Grep: (?:maxSessions|max_sessions|MAX_CONCURRENT_SESSIONS)\s*[:=]\s*(\d+)  → max concurrent sessions
Grep: (?:refresh.*(?:expir|ttl|lifetime)|REFRESH_TOKEN_TTL)\s*[:=]\s*['"]?(\d+[smhd]?|[\d.]+\s*(?:day|hour)\w*)['"]?  → refresh token expiry
Grep: SESSION_COOKIE_AGE\s*=\s*(\d+)  → Django session age (seconds)
```

**Use in policy text:**
- Instead of: "User sessions are configured with appropriate timeout values"
- Write: "JWT access tokens expire after **15 minutes**; refresh tokens expire after **7 days** (see `src/config/auth.ts:12-13`). Session cookies are configured with **secure=true, httpOnly=true, sameSite=Strict** (see `src/config/session.ts:14-16`)."

### Account Lockout

Extract max failed attempts, lockout duration, and progressive delay configuration.

**Find files:**
```
Glob: **/config/**/*.{ts,js,py,go,json,yaml,yml}, **/middleware/**/*.{ts,js,py,go}, **/auth/**/*.{ts,js,py,go}, **/*lockout*.*, **/*login*.*, **/*brute*.*, **/*rate*limit*.*
```

**Extract values:**
```
Grep: (?:max[_\-]?(?:attempts|retries|login[_\-]?attempts|failed)|MAX_FAILED_ATTEMPTS|maxLoginAttempts)\s*[:=]\s*(\d+)  → max failed attempts
Grep: (?:lockout[_\-]?(?:duration|time|period|minutes)|LOCKOUT_DURATION|lockDuration)\s*[:=]\s*(\d+)  → lockout duration (number)
Grep: freeRetries\s*:\s*(\d+)  → express-brute free retries
Grep: AXES_FAILURE_LIMIT\s*=\s*(\d+)  → Django axes failure limit
Grep: AXES_COOLOFF_TIME\s*=\s*(?:timedelta\(hours?=(\d+)\)|(\d+))  → Django axes cooloff
```

**Use in policy text:**
- Instead of: "Account lockout mechanisms are implemented"
- Write: "Accounts are locked after **5 consecutive failed login attempts** for **15 minutes** (see `src/middleware/rateLimit.ts:31-32`)."

### Rate Limiting

Extract rate limit thresholds, window durations, and protected endpoints.

**Find files:**
```
Glob: **/middleware/**/*.{ts,js,py,go}, **/config/**/*.{ts,js,py,go,json,yaml,yml}, **/*rate*limit*.*, **/*throttl*.*, **/nginx/**/*.conf
```

**Extract values:**
```
Grep: windowMs\s*:\s*(\d+).*?max\s*:\s*(\d+)  → express-rate-limit (window ms, max requests) — use multiline
Grep: limit_req_zone.*rate=(\d+r/[sm])  → Nginx rate limit
Grep: limit_req.*burst=(\d+)  → Nginx burst count
Grep: rate\.NewLimiter\((\d+),\s*(\d+)\)  → Go rate limiter (rate, burst)
Grep: (?:DEFAULT_THROTTLE_RATES|throttle_rates).*['"](\w+)['"]\s*:\s*['"](\d+/\w+)['"]  → Django DRF throttle (scope, rate)
Grep: @limiter\.limit\(['"](\d+/\w+)['"]\)  → FastAPI rate limit
Grep: throttling_rate_limit\s*=\s*(\d+)  → Terraform API Gateway rate
```

**Use in policy text:**
- Instead of: "API rate limiting is implemented"
- Write: "API rate limiting is enforced at **100 requests per 15-minute window** for general endpoints and **10 requests per 15-minute window** for authentication endpoints (see `src/middleware/rateLimit.ts:5-15`)."

## Example Evidence Table

| Control | Extracted Value | File | Line | Raw Evidence |
|---------|----------------|------|------|-------------|
| Password minimum length | **12 characters** | src/validation/password.ts | 18 | `minLength: 12` |
| Password hashing | **bcrypt, 12 rounds** | src/services/auth.ts | 45 | `bcrypt.hash(password, 12)` |
| RBAC roles | **Admin, Editor, Viewer, Billing** | src/models/user.ts | 12 | `enum Role { ADMIN, EDITOR, VIEWER, BILLING }` |
| Session timeout | **30 min** | src/config/session.ts | 8 | `maxAge: 1800000` |
| JWT access token expiry | **15 min** | src/config/auth.ts | 12 | `expiresIn: '15m'` |
| Account lockout | **5 attempts, 15 min** | src/middleware/rateLimit.ts | 31-32 | `maxAttempts: 5, lockoutDuration: 900` |
| Rate limit (general) | **100 req / 15 min** | src/middleware/rateLimit.ts | 5-7 | `windowMs: 900000, max: 100` |

## Cloud Scanning Cross-Reference

For live infrastructure evidence related to access control:
- AWS: IAM password policy, MFA status, IAM roles -- see [aws.md](aws.md#access-control-cc61-63)
- GCP: Organization/project IAM policies -- see [gcp.md](gcp.md#access-control-cc61-63)
- Azure: Conditional access policies, RBAC assignments -- see [azure.md](azure.md#access-control-cc61-63)
