# Dokumentasi Curl Command untuk Kong API Gateway

## Status Check
```bash
# Memeriksa status Kong
curl -s http://localhost:8001/status
```

## Manajemen Consumer

### Membuat Consumer Baru
```bash
curl -i -X POST http://localhost:8001/consumers \
  --data "username=kong_admin" \
  --data "custom_id=kong_admin"
```

### Mendapatkan Consumer
```bash
curl -s -X GET http://localhost:8001/consumers/kong_admin
```

## Autentikasi Basic Auth

### Membuat Kredensial Basic Auth
```bash
curl -i -X POST http://localhost:8001/consumers/{consumer_id}/basic-auth \
  --data "username=admin" \
  --data "password=your_password" \
  --data "tags[]=kong-manager-auth"
```

## RBAC (Role Based Access Control)

### Membuat Token RBAC
```bash
curl -s -X POST http://localhost:8001/rbac/tokens \
  --data "name=kong_admin_token" \
  --data "user_token={consumer_id}"
```

### Membuat Role
```bash
curl -s -X POST http://localhost:8001/rbac/roles \
  --data "name=super-admin" \
  --data "comment=Super Admin Role"
```

### Menambahkan Izin untuk Role
```bash
curl -s -X POST http://localhost:8001/rbac/roles/super-admin/endpoints \
  --data "endpoint=*" \
  --data "workspace=default" \
  --data "actions=*"
```

### Menetapkan Role ke User
```bash
curl -s -X POST http://localhost:8001/rbac/users \
  --data "name=kong_admin" \
  --data "user_token={consumer_id}" \
  --data "roles=super-admin"
```

## Manajemen Service

### Membuat Service
```bash
curl -i -X POST http://localhost:8001/services \
  --data "name=kong-manager" \
  --data "url=http://localhost:8002"
```

### Membuat Route untuk Service
```bash
curl -i -X POST http://localhost:8001/services/kong-manager/routes \
  --data "name=kong-manager-route" \
  --data "hosts[]=koung.ragam.io" \
  --data "protocols[]=http" \
  --data "protocols[]=https"
```

## Plugin Management

### Mengaktifkan Plugin CORS
```bash
curl -X POST http://localhost:8001/services/kong-admin/plugins \
  --data "name=cors" \
  --data "config.origins[]=https://koung.ragam.io" \
  --data "config.methods[]=GET" \
  --data "config.methods[]=HEAD" \
  --data "config.methods[]=PUT" \
  --data "config.methods[]=PATCH" \
  --data "config.methods[]=POST" \
  --data "config.methods[]=DELETE" \
  --data "config.methods[]=OPTIONS" \
  --data "config.headers[]=Accept" \
  --data "config.headers[]=Accept-Version" \
  --data "config.headers[]=Content-Length" \
  --data "config.headers[]=Content-MD5" \
  --data "config.headers[]=Content-Type" \
  --data "config.headers[]=Date" \
  --data "config.headers[]=Authorization" \
  --data "config.exposed_headers[]=*" \
  --data "config.credentials=true" \
  --data "config.max_age=86400"
```

### Update Plugin CORS
```bash
curl -X PATCH http://localhost:8001/plugins/f6395bbc-0910-4b07-a83e-04db6ebd0d40 \
  --data "name=cors" \
  --data "config.origins[]=https://koung.ragam.io" \
  --data "config.origins[]=https://*.ragam.io" \
  --data "config.methods[]=GET" \
  --data "config.methods[]=HEAD" \
  --data "config.methods[]=PUT" \
  --data "config.methods[]=PATCH" \
  --data "config.methods[]=POST" \
  --data "config.methods[]=DELETE" \
  --data "config.methods[]=OPTIONS" \
  --data "config.headers[]=Accept" \
  --data "config.headers[]=Accept-Version" \
  --data "config.headers[]=Content-Length" \
  --data "config.headers[]=Content-MD5" \
  --data "config.headers[]=Content-Type" \
  --data "config.headers[]=Date" \
  --data "config.headers[]=Authorization" \
  --data "config.exposed_headers[]=*" \
  --data "config.credentials=true" \
  --data "config.max_age=86400"
```
