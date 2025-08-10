## Deploying Enroute API (Traccar) to Fly.io

This guide helps you deploy the Java backend (Traccar-based) with device protocol ports to Fly.io.

### Prerequisites

- Fly CLI installed: `curl -L https://fly.io/install.sh | sh`
- Logged in: `fly auth login`
- Docker available locally (for local build) or enable remote build (`fly deploy --remote-only`)

### 1) Create the Fly app

```
# From repo root
echo "Pick a unique app name (letters, numbers, dashes)"
fly apps create enroute-api
```

If you already have an app, update `fly.toml` `app = "your-app-name"`.

### 2) Database options

You can use either Fly Postgres (recommended) or an external MySQL.

- Fly Postgres:

```
fly postgres create --name enroute-db --vm-size shared-cpu-1x --region iad --volume-size 10
fly postgres attach --app enroute-api enroute-db
```

This sets `DATABASE_URL` in the app.

- External MySQL:
  Set these secrets manually:

```
fly secrets set DATABASE_URL="mysql://user:pass@host:3306/db" \
                 MYSQLUSER="user" MYSQLPASSWORD="pass"
```

Notes:

- For Postgres, set:

```
fly secrets set DATABASE_DRIVER="org.postgresql.Driver"
```

- For MySQL, driver defaults via Dockerfile to `com.mysql.cj.jdbc.Driver`. You can override via secret:

```
fly secrets set DATABASE_DRIVER="com.mysql.cj.jdbc.Driver"
```

### 3) Deploy

```
# Local build
fly deploy
# Or remote build if local Docker not available
fly deploy --remote-only
```

### 4) Verify

```
fly status
fly logs
# Health
curl -I https://$(fly apps list | awk '/enroute-api/ {print $1}').fly.dev/api/server
```

### 5) Expose more device ports (optional)

- In `production.xml`, add:

```
<entry key='gps103.port'>5001</entry>
<entry key='osmand.port'>5055</entry>
```

- In `fly.toml`, add a new service block per port:

```
[[services]]
  protocol = "tcp"
  internal_port = 5001
  [[services.ports]]
    port = 5001
```

- Redeploy: `fly deploy`

### 6) Environment variables used

- `PORT`: HTTP port (set to 8080 in `fly.toml`)
- `CONFIG_USE_ENVIRONMENT_VARIABLES=true`: enables env-based config resolution
- `DATABASE_URL`: JDBC-style or scheme URL, passed to Hikari via Traccar
- `DATABASE_DRIVER`: `org.postgresql.Driver` or `com.mysql.cj.jdbc.Driver`
- `MYSQLUSER` / `MYSQLPASSWORD`: mapped to `DATABASE_USER` / `DATABASE_PASSWORD`

### 7) Resources

- Scale memory/CPU:

```
fly scale memory 1024
fly scale vm shared-cpu-2x
```

### Default admin login

- Username: `admin`
- Password: `admin` (change immediately)
