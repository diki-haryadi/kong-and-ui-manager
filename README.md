# Kong Gateway API Documentation

## Basic CRUD Operations

### Services
# List all services
curl -X GET http://localhost:8001/services

# Create a service
curl -X POST http://localhost:8001/services \
  --data "name=my-service" \
  --data "url=http://example.com"

# Get service details
curl -X GET http://localhost:8001/services/{service_name_or_id}

# Update service
curl -X PATCH http://localhost:8001/services/{service_name_or_id} \
  --data "url=http://new-example.com"

# Delete service
curl -X DELETE http://localhost:8001/services/{service_name_or_id}

### Routes 
# List all routes
curl -X GET http://localhost:8001/routes

# Create a route
curl -X POST http://localhost:8001/services/{service_name}/routes \
  --data "name=my-route" \
  --data "paths[]=/api" \
  --data "hosts[]=example.com"

# Get route details
curl -X GET http://localhost:8001/routes/{route_id}

# Update route
curl -X PATCH http://localhost:8001/routes/{route_id} \
  --data "paths[]=/new-api"

# Delete route
curl -X DELETE http://localhost:8001/routes/{route_id}

### Consumers
# List all consumers
curl -X GET http://localhost:8001/consumers

# Create a consumer
curl -X POST http://localhost:8001/consumers \
  --data "username=user123" \
  --data "custom_id=custom123"

# Get consumer details
curl -X GET http://localhost:8001/consumers/{consumer_id}

# Update consumer
curl -X PATCH http://localhost:8001/consumers/{consumer_id} \
  --data "username=newuser123"

# Delete consumer
curl -X DELETE http://localhost:8001/consumers/{consumer_id}

### Plugins
# List all plugins
curl -X GET http://localhost:8001/plugins

# Create a plugin
curl -X POST http://localhost:8001/plugins \
  --data "name=cors" \
  --data "config.origins[]=*"

# Get plugin details
curl -X GET http://localhost:8001/plugins/{plugin_id}

# Update plugin
curl -X PATCH http://localhost:8001/plugins/{plugin_id} \
  --data "config.origins[]=https://example.com"

# Delete plugin
curl -X DELETE http://localhost:8001/plugins/{plugin_id}

### Upstreams
# List all upstreams
curl -X GET http://localhost:8001/upstreams

# Create an upstream
curl -X POST http://localhost:8001/upstreams \
  --data "name=my-upstream" \
  --data "algorithm=round-robin"

# Add target to upstream
curl -X POST http://localhost:8001/upstreams/{upstream_name}/targets \
  --data "target=service1:8000" \
  --data "weight=100"

# Get upstream details
curl -X GET http://localhost:8001/upstreams/{upstream_name}

# Update upstream
curl -X PATCH http://localhost:8001/upstreams/{upstream_name} \
  --data "algorithm=least-connections"

# Delete upstream
curl -X DELETE http://localhost:8001/upstreams/{upstream_name}

### Certificates
# List all certificates
curl -X GET http://localhost:8001/certificates

# Create a certificate
curl -X POST http://localhost:8001/certificates \
  --data "cert=@/path/to/cert.pem" \
  --data "key=@/path/to/key.pem"

# Get certificate details
curl -X GET http://localhost:8001/certificates/{certificate_id}

# Update certificate
curl -X PATCH http://localhost:8001/certificates/{certificate_id} \
  --data "cert=@/path/to/new-cert.pem" \
  --data "key=@/path/to/new-key.pem"

# Delete certificate
curl -X DELETE http://localhost:8001/certificates/{certificate_id}

### SNIs (Server Name Indications)
# List all SNIs
curl -X GET http://localhost:8001/snis

# Create an SNI
curl -X POST http://localhost:8001/snis \
  --data "name=example.com" \
  --data "certificate_id={certificate_id}"

# Get SNI details
curl -X GET http://localhost:8001/snis/{sni_name_or_id}

# Update SNI
curl -X PATCH http://localhost:8001/snis/{sni_name_or_id} \
  --data "certificate_id={new_certificate_id}"

# Delete SNI
curl -X DELETE http://localhost:8001/snis/{sni_name_or_id}

### Vaults
# List all vaults
curl -X GET http://localhost:8001/vaults

# Create a vault
curl -X POST http://localhost:8001/vaults \
  --data "name=my-vault" \
  --data "prefix=my-prefix" \
  --data "description=My Vault Description" \
  --data "config.prefix=my-prefix" \
  --data "config.token=my-token" \
  --data "config.host=vault.example.com" \
  --data "config.port=8200" \
  --data "config.protocol=https" \
  --data "config.tls_verify=true" \
  --data "config.tls_server_name=vault.example.com"

# Get vault details
curl -X GET http://localhost:8001/vaults/{vault_name_or_id}

# Update vault
curl -X PATCH http://localhost:8001/vaults/{vault_name_or_id} \
  --data "config.token=new-token" \
  --data "config.host=new-vault.example.com"

# Delete vault
curl -X DELETE http://localhost:8001/vaults/{vault_name_or_id}

# Create vault entity
curl -X POST http://localhost:8001/vaults/{vault_name_or_id}/entities \
  --data "name=my-entity" \
  --data "tags[]=tag1" \
  --data "tags[]=tag2"

# Get vault entity
curl -X GET http://localhost:8001/vaults/{vault_name_or_id}/entities/{entity_name_or_id}

# Update vault entity
curl -X PATCH http://localhost:8001/vaults/{vault_name_or_id}/entities/{entity_name_or_id} \
  --data "tags[]=new-tag"

# Delete vault entity
curl -X DELETE http://localhost:8001/vaults/{vault_name_or_id}/entities/{entity_name_or_id}

## Common Parameters
### Service Parameters
- name : The service name
- url : The URL of the upstream service
- protocol : http/https
- host : The upstream hostname
- port : The upstream port
- path : The path to be used in requests
- connect_timeout : Timeout in milliseconds for establishing TCP connection
- write_timeout : Timeout in milliseconds for sending request
- read_timeout : Timeout in milliseconds for reading response

### Route Parameters
- name : The route name
- protocols : Array of protocols (http, https)
- hosts : Array of domain names
- paths : Array of paths
- methods : Array of HTTP methods
- strip_path : Boolean to strip path
- preserve_host : Boolean to preserve host header
- regex_priority : Priority for regex matching
- https_redirect_status_code : Status code for HTTPS redirects

### Plugin Parameters
- name : Plugin name
- config : Plugin-specific configuration
- enabled : Boolean to enable/disable
- service_id : Optional service ID
- route_id : Optional route ID
- consumer_id : Optional consumer ID
- protocols : Array of protocols plugin will run on

### Upstream Parameters
- name : Upstream name
- algorithm : Load balancing algorithm
- hash_on : Hash-based load balancing key
- hash_fallback : Secondary hash key
- hash_on_cookie_path : Cookie path
- slots : Number of slots in the load balancer (10-65536)
- healthchecks : Health check configuration
- tags : Array of tags

### Consumer Parameters
- username : The unique username
- custom_id : Custom identifier
- tags : Array of tags

### Certificate Parameters
- cert : PEM-encoded public certificate
- key : PEM-encoded private key
- tags : Array of tags
- snis : Array of SNI names

### SNI Parameters
- name : The SNI name (domain name)
- certificate_id : The certificate ID to associate
- tags : Array of tags

## Examples
### Create Service with Route and Plugin
```
# Create service
curl -X POST http://localhost:8001/services \
  --data "name=example-service" \
  --data "url=http://example.com"

# Add route to service
curl -X POST http://localhost:8001/services/example-service/routes \
  --data "name=example-route" \
  --data "hosts[]=api.example.com"

# Add plugin to service
curl -X POST http://localhost:8001/services/example-service/plugins \
  --data "name=rate-limiting" \
  --data "config.minute=5" \
  --data "config.policy=local"
```

### Setup Basic Authentication
```
# Create a consumer
curl -X POST http://localhost:8001/consumers \
  --data "username=user123"

# Create basic-auth credentials
curl -X POST http://localhost:8001/consumers/user123/basic-auth \
  --data "username=user123" \
  --data "password=secret"

# Enable basic-auth plugin
curl -X POST http://localhost:8001/plugins \
  --data "name=basic-auth" \
  --data "config.hide_credentials=true"
```

### Setup SSL/TLS
```
# Upload certificate
curl -X POST http://localhost:8001/certificates \
  --data "cert=@/path/to/cert.pem" \
  --data "key=@/path/to/key.pem"

# Create SNI
curl -X POST http://localhost:8001/snis \
  --data "name=secure.example.com" \
  --data "certificate_id={certificate_id}"
```