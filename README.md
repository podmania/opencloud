# opencloud

Secure, private file storage, access, and sharing platform.

Upstream: [opencloud-eu/opencloud](https://github.com/opencloud-eu/opencloud)  
Documentation: [docs.opencloud.eu](https://docs.opencloud.eu/)

## Ports

- `9200` — Web UI / API

## Volumes

- `/var/lib/opencloud` — Data and configuration

## Environment Variables

OpenCloud uses a microservice architecture. Variables prefixed with `OC_` are global; service-specific prefixes (e.g. `PROXY_*`, `STORAGE_USERS_*`) override global settings for that service.

### Core

| Variable | Default | Description |
| --- | --- | --- |
| `OC_URL` | `https://localhost:9200` | Public-facing URL of the OpenCloud frontend |
| `OC_LOG_LEVEL` | `error` | Log level: `panic`, `fatal`, `error`, `warn`, `info`, `debug`, `trace` |
| `OC_LOG_PRETTY` | `false` | Human-readable log output |
| `OC_LOG_COLOR` | `false` | Colorized log output |
| `OC_LOG_FILE` | _(empty)_ | Path to log file |
| `OC_INSECURE` | `false` | Disable TLS certificate validation |
| `OC_CONFIG_DIR` | _(empty)_ | Override config directory path |
| `OC_DEFAULT_LANGUAGE` | _(English)_ | Default language (ISO 639-1 code) |
| `OC_JWT_SECRET` | _(empty)_ | Secret for JWT tokens |
| `OC_MACHINE_AUTH_API_KEY` | _(empty)_ | API key for internal service requests |
| `OC_TRANSFER_SECRET` | _(empty)_ | Storage transfer secret |
| `OC_ADMIN_USER_ID` | _(empty)_ | User ID to receive admin privileges |
| `OC_ASYNC_UPLOADS` | `true` | Enable asynchronous file uploads |
| `OC_DISABLE_VERSIONING` | `false` | Disable file versioning |
| `OC_ENABLE_OCM` | `false` | Include OCM sharees in user listings |
| `OC_SHOW_USER_EMAIL_IN_RESULTS` | `false` | Include emails in search results |

### OIDC / Identity Provider

| Variable | Default | Description |
| --- | --- | --- |
| `OC_OIDC_ISSUER` | `https://localhost:9200` | OIDC issuer URL |
| `OC_OIDC_CLIENT_ID` | `web` | OIDC client ID |
| `OC_OIDC_CLIENT_SCOPES` | `[openid profile email offline_access]` | OIDC scopes to request |
| `WEB_OIDC_CLIENT_ID` | `web` | OIDC client ID for web client |
| `WEB_OIDC_SCOPE` | `openid profile email` | OIDC scopes for web auth |

### LDAP

| Variable | Default | Description |
| --- | --- | --- |
| `OC_LDAP_URI` | `ldaps://localhost:9235` | LDAP server URI |
| `OC_LDAP_BIND_DN` | `uid=reva,ou=sysusers,o=libregraph-idm` | Bind DN |
| `OC_LDAP_BIND_PASSWORD` | _(empty)_ | Bind password |
| `OC_LDAP_CACERT` | `/var/lib/opencloud/idm/ldap.crt` | Root CA cert for LDAP TLS |
| `OC_LDAP_INSECURE` | `false` | Disable TLS cert validation |
| `OC_LDAP_SERVER_WRITE_ENABLED` | `true` | Allow LDAP writes via GRAPH API |
| `OC_LDAP_USER_BASE_DN` | `ou=users,o=libregraph-idm` | User search base DN |
| `OC_LDAP_USER_OBJECTCLASS` | `inetOrgPerson` | User object class |
| `OC_LDAP_USER_SCHEMA_ID` | `openCloudUUID` | User ID attribute |
| `OC_LDAP_USER_SCHEMA_DISPLAYNAME` | `displayname` | User display name attribute |
| `OC_LDAP_USER_SCHEMA_MAIL` | `mail` | User email attribute |
| `OC_LDAP_USER_SCHEMA_USERNAME` | `uid` | Username attribute |
| `OC_LDAP_GROUP_BASE_DN` | `ou=groups,o=libregraph-idm` | Group search base DN |
| `OC_LDAP_GROUP_OBJECTCLASS` | `groupOfNames` | Group object class |
| `OC_LDAP_GROUP_SCHEMA_ID` | `openCloudUUID` | Group ID attribute |
| `OC_LDAP_GROUP_SCHEMA_DISPLAYNAME` | `cn` | Group display name attribute |
| `OC_LDAP_GROUP_SCHEMA_MEMBER` | `member` | Group member attribute |

### Proxy Service

| Variable | Default | Description |
| --- | --- | --- |
| `PROXY_OIDC_REWRITE_WELLKNOWN` | _(empty)_ | Expose IDP's `.well-known` via OpenCloud URL |
| `PROXY_USER_OIDC_CLAIM` | _(empty)_ | OIDC claim for user identification |
| `PROXY_AUTOPROVISION_ACCOUNTS` | _(empty)_ | Auto-create accounts on first login |
| `PROXY_ROLE_ASSIGNMENT_DRIVER` | `default` | Role assignment: `default` or `oidc` |
| `PROXY_ROLE_ASSIGNMENT_OIDC_CLAIM` | `roles` | OIDC claim for role assignment |

### Storage

| Variable | Default | Description |
| --- | --- | --- |
| `STORAGE_USERS_DRIVER` | `posix` | Storage driver: `posix`, `decomposed`, `decomposeds3` |
| `STORAGE_USERS_POSIX_ROOT` | _(empty)_ | Root directory for PosixFS storage |
| `STORAGE_USERS_POSIX_WATCH_FS` | `false` | Enable real-time filesystem watching |
| `OC_SPACES_MAX_QUOTA` | `0` | Global max quota for spaces in bytes (0 = unlimited) |

### S3 Storage (DecomposedS3)

| Variable | Default | Description |
| --- | --- | --- |
| `DECOMPOSEDS3_ENDPOINT` | `http://minio:9000` | S3 endpoint |
| `DECOMPOSEDS3_REGION` | `default` | S3 region |
| `DECOMPOSEDS3_ACCESS_KEY` | `opencloud` | S3 access key |
| `DECOMPOSEDS3_SECRET_KEY` | `opencloud-secret-key` | S3 secret key |
| `DECOMPOSEDS3_BUCKET` | `opencloud` | S3 bucket name |

### Cache

| Variable | Default | Description |
| --- | --- | --- |
| `OC_CACHE_STORE` | `noop` | Cache type: `memory`, `redis-sentinel`, `nats-js-kv`, `noop` |
| `OC_CACHE_STORE_NODES` | `[127.0.0.1:9233]` | Cache store nodes |
| `OC_CACHE_DATABASE` | `cache-providers` | Cache database name |
| `OC_CACHE_TTL` | `5m` | Default cache TTL |
| `OC_PERSISTENT_STORE` | `memory` | Persistent store type |
| `OC_PERSISTENT_STORE_NODES` | `[]` | Persistent store nodes |
| `OC_PERSISTENT_STORE_TTL` | `336h` | Persistent store TTL (2 weeks) |

### Events

| Variable | Default | Description |
| --- | --- | --- |
| `OC_EVENTS_ENDPOINT` | `127.0.0.1:9233` | Event system address |
| `OC_EVENTS_CLUSTER` | `opencloud-cluster` | Event cluster ID |
| `OC_EVENTS_ENABLE_TLS` | `false` | Enable TLS for event broker |
| `OC_EVENTS_AUTH_USERNAME` | _(empty)_ | Event broker username |
| `OC_EVENTS_AUTH_PASSWORD` | _(empty)_ | Event broker password |

### SMTP / Notifications

| Variable | Default | Description |
| --- | --- | --- |
| `SMTP_HOST` | _(empty)_ | SMTP hostname |
| `SMTP_PORT` | `0` | SMTP port |
| `SMTP_SENDER` | _(empty)_ | Sender email address |
| `SMTP_USERNAME` | _(empty)_ | SMTP username |
| `SMTP_PASSWORD` | _(empty)_ | SMTP password |
| `SMTP_AUTHENTICATION` | _(empty)_ | Auth method: `login`, `plain`, `crammd5`, `none`, `auto` |
| `SMTP_TRANSPORT_ENCRYPTION` | `none` | Encryption: `starttls`, `ssltls`, `none` |

### Sharing

| Variable | Default | Description |
| --- | --- | --- |
| `OC_SHARING_PUBLIC_SHARE_MUST_HAVE_PASSWORD` | `true` | Require passwords on public shares |
| `OC_SHARING_PUBLIC_WRITEABLE_SHARE_MUST_HAVE_PASSWORD` | `false` | Require passwords on writable shares |

### Password Policy

| Variable | Default | Description |
| --- | --- | --- |
| `OC_PASSWORD_POLICY_DISABLED` | `false` | Disable password complexity checks |
| `OC_PASSWORD_POLICY_MIN_CHARACTERS` | `8` | Minimum password length |
| `OC_PASSWORD_POLICY_MIN_LOWERCASE_CHARACTERS` | `1` | Minimum lowercase letters |
| `OC_PASSWORD_POLICY_MIN_UPPERCASE_CHARACTERS` | `1` | Minimum uppercase letters |
| `OC_PASSWORD_POLICY_MIN_DIGITS` | `1` | Minimum digits |
| `OC_PASSWORD_POLICY_MIN_SPECIAL_CHARACTERS` | `1` | Minimum special characters |

### Service Management

| Variable | Default | Description |
| --- | --- | --- |
| `OC_RUN_SERVICES` | _(empty)_ | Explicitly define which services to start |
| `OC_EXCLUDE_RUN_SERVICES` | _(empty)_ | Services to exclude from startup |
| `OC_ADD_RUN_SERVICES` | _(empty)_ | Additional services to include |
| `IDM_CREATE_DEMO_USERS` | `false` | Create demo users |

### Frontend

| Variable | Default | Description |
| --- | --- | --- |
| `FRONTEND_CHECK_FOR_UPDATES` | `true` | Check for newer versions |
| `FRONTEND_READONLY_USER_ATTRIBUTES` | _(empty)_ | Read-only user attributes in admin UI |

### CORS

| Variable | Default | Description |
| --- | --- | --- |
| `OC_CORS_ALLOW_CREDENTIALS` | `true` | Allow credentials for CORS |
| `OC_CORS_ALLOW_ORIGINS` | `[*]` | Allowed CORS origins |

### TLS

| Variable | Default | Description |
| --- | --- | --- |
| `OC_HTTP_TLS_ENABLED` | `false` | Enable TLS for HTTP services |
| `OC_HTTP_TLS_CERTIFICATE` | _(empty)_ | Path to TLS certificate (PEM) |
| `OC_HTTP_TLS_KEY` | _(empty)_ | Path to TLS key (PEM) |
| `OC_GRPC_CLIENT_TLS_MODE` | _(empty)_ | GRPC TLS mode: `off`, `insecure`, `on` |

<a href="https://www.buymeacoffee.com/bhoehn" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>
