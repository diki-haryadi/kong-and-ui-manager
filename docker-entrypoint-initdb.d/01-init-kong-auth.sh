#!/bin/bash

# Wait for Kong to be ready
sleep 30

# Create a Kong consumer for admin access
curl -i -X POST http://kong:8001/consumers \
  --data "username=kong_admin" \
  --data "custom_id=kong_admin"

# Create basic-auth credentials for the consumer
curl -i -X POST http://kong:8001/consumers/kong_admin/basic-auth \
  --data "username=admin" \
  --data "password=admin123"

# Create RBAC role and permissions
curl -i -X POST http://kong:8001/rbac/roles \
  --data "name=super-admin"

curl -i -X POST http://kong:8001/rbac/roles/super-admin/endpoints \
  --data "endpoint=*" \
  --data "workspace=default" \
  --data "actions=*"

# Assign role to consumer
curl -i -X POST http://kong:8001/rbac/users \
  --data "name=kong_admin" \
  --data "user_token=kong_admin" \
  --data "roles=super-admin"