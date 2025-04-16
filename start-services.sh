#!/bin/bash

# Fungsi untuk memeriksa status Kong
check_kong_status() {
    local max_attempts=10
    local attempt=1
    local wait_time=10

    while [ $attempt -le $max_attempts ]; do
        if curl -s http://localhost:8001/status > /dev/null; then
            echo "Kong Admin API siap"
            return 0
        fi
        echo "Menunggu Kong Admin API siap (percobaan $attempt/$max_attempts)..."
        sleep $wait_time
        attempt=$((attempt + 1))
    done

    echo "Kong Admin API tidak dapat diakses setelah $max_attempts percobaan"
    return 1
}

# Fungsi untuk mengatur autentikasi Kong Manager
setup_kong_auth() {
    echo "Mengatur autentikasi Kong Manager..."
    
    # Periksa status Kong
    if ! check_kong_status; then
        echo "Kong belum siap, membatalkan konfigurasi"
        return 1
    fi

    # Cek apakah consumer sudah ada
    echo "Memeriksa consumer..."
    EXISTING_CONSUMER=$(curl -s -X GET http://localhost:8001/consumers/kong_admin)
    CONSUMER_ID=$(echo "$EXISTING_CONSUMER" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)

    if [ -z "$CONSUMER_ID" ]; then
        echo "Membuat consumer baru..."
        CONSUMER_RESPONSE=$(curl -s -i -X POST http://localhost:8001/consumers \
            --data "username=kong_admin" \
            --data "custom_id=kong_admin")
        
        RESPONSE_BODY=$(echo "$CONSUMER_RESPONSE" | awk 'BEGIN{RS="\n\n"} {print $0}' | tail -n 1)
        CONSUMER_ID=$(echo "$RESPONSE_BODY" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
        
        if [ -z "$CONSUMER_ID" ]; then
            echo "Gagal membuat consumer. Response body: $RESPONSE_BODY"
            return 1
        fi
        echo "Consumer berhasil dibuat dengan ID: $CONSUMER_ID"
    else
        echo "Consumer sudah ada dengan ID: $CONSUMER_ID"
    fi

    # Hapus plugin basic-auth yang ada
    echo "Menghapus plugin basic-auth yang ada..."
    EXISTING_PLUGINS=$(curl -s http://localhost:8001/plugins?name=basic-auth)
    PLUGIN_ID=$(echo "$EXISTING_PLUGINS" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
    if [ ! -z "$PLUGIN_ID" ]; then
        curl -s -X DELETE http://localhost:8001/plugins/$PLUGIN_ID
    fi

    # Aktifkan plugin basic-auth untuk Kong Manager
    echo "Mengaktifkan plugin basic-auth untuk Kong Manager..."
    curl -s -X POST http://localhost:8001/plugins \
        --data "name=basic-auth" \
        --data "config.hide_credentials=false" \
        --data "config.anonymous=" \
        --data "tags[]=kong-manager-auth"

    # Hapus kredensial basic-auth yang ada
    echo "Menghapus kredensial basic-auth yang ada..."
    EXISTING_CREDENTIALS=$(curl -s http://localhost:8001/consumers/$CONSUMER_ID/basic-auth)
    CREDENTIAL_ID=$(echo "$EXISTING_CREDENTIALS" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
    if [ ! -z "$CREDENTIAL_ID" ]; then
        curl -s -X DELETE http://localhost:8001/consumers/$CONSUMER_ID/basic-auth/$CREDENTIAL_ID
    fi

    # Buat kredensial basic-auth untuk consumer
    echo "Membuat kredensial basic-auth..."
    curl -s -X POST http://localhost:8001/consumers/$CONSUMER_ID/basic-auth \
        --data "username=admin" \
        --data "password=Beranekaragam2024" \
        --data "tags[]=kong-manager-auth"

    # Aktifkan RBAC token
    echo "Mengaktifkan RBAC token..."
    curl -s -X POST http://localhost:8001/rbac/tokens \
        --data "name=kong_admin_token" \
        --data "user_token=$CONSUMER_ID"

    # Buat role super-admin
    echo "Membuat role super-admin..."
    ROLE_RESPONSE=$(curl -s -X POST http://localhost:8001/rbac/roles \
        --data "name=super-admin" \
        --data "comment=Super Admin Role")

    # Tambahkan izin untuk role
    echo "Menambahkan izin untuk role..."
    curl -s -X POST http://localhost:8001/rbac/roles/super-admin/endpoints \
        --data "endpoint=*" \
        --data "workspace=default" \
        --data "actions=*"

    # Tetapkan peran ke consumer
    echo "Menetapkan peran ke consumer..."
    curl -s -X POST http://localhost:8001/rbac/users \
        --data "name=kong_admin" \
        --data "user_token=$CONSUMER_ID" \
        --data "roles=super-admin"

    echo "Konfigurasi autentikasi Kong Manager selesai"
}

# Fungsi untuk menjalankan Kong dan database
setup_kong_routing() {
    echo "Setting up Kong routing for koung.ragam.io and koung-listen.ragam.io..."
    
    # Create a service for Kong Manager
    curl -i -X POST http://localhost:8001/services \
        --data "name=kong-manager" \
        --data "url=http://localhost:8002"

    # Create a route for Kong Manager
    curl -i -X POST http://localhost:8001/services/kong-manager/routes \
        --data "name=kong-manager-route" \
        --data "hosts[]=koung.ragam.io" \
        --data "protocols[]=http" \
        --data "protocols[]=https"

    # Create a service for Kong Admin API
    curl -i -X POST http://localhost:8001/services \
        --data "name=kong-admin" \
        --data "url=http://localhost:8001"

    # Create a route for Kong Admin API
    curl -i -X POST http://localhost:8001/services/kong-admin/routes \
        --data "name=kong-admin-route" \
        --data "hosts[]=koung-listen.ragam.io" \
        --data "protocols[]=http" \
        --data "protocols[]=https"

    echo "Kong routing configuration completed"
}

# Fungsi untuk memperbarui plugin yang ada
update_plugin() {
    local plugin_name=$1
    local plugin_id=$(curl -s "http://localhost:8001/plugins?name=$plugin_name" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
    
    if [ ! -z "$plugin_id" ]; then
        echo "Memperbarui plugin $plugin_name dengan ID: $plugin_id..."
        # Gunakan PATCH untuk memperbarui konfigurasi plugin yang ada
        curl -X PATCH http://localhost:8001/plugins/$plugin_id \
            --data "$2"
        echo "Plugin $plugin_name berhasil diperbarui"
    else
        echo "Plugin $plugin_name tidak ditemukan"
        return 1
    fi
}

# Fungsi untuk mengatur CORS pada Kong Admin API
setup_cors() {
    echo "Mengatur CORS untuk Kong Admin API..."
    # Cek apakah plugin CORS sudah ada
    local cors_config="name=cors&config.origins[]=https://koung.ragam.io&config.methods[]=GET&config.methods[]=HEAD&config.methods[]=PUT&config.methods[]=PATCH&config.methods[]=POST&config.methods[]=DELETE&config.methods[]=OPTIONS&config.origins_regex[]=.*\.ragam\.io&config.headers[]=Accept&config.headers[]=Accept-Version&config.headers[]=Content-Length&config.headers[]=Content-MD5&config.headers[]=Content-Type&config.headers[]=Date&config.headers[]=Authorization&config.headers[]=Access-Control-Allow-Origin&config.headers[]=Access-Control-Allow-Methods&config.headers[]=Access-Control-Allow-Headers&config.headers[]=Access-Control-Allow-Credentials&config.exposed_headers[]=*&config.credentials=true&config.max_age=86400&config.preflight_continue=false"
    
    if ! update_plugin "cors" "$cors_config"; then
        echo "Plugin CORS tidak ditemukan, membuat plugin baru..."
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
        --data "config.origins_regex[]=.*\.ragam\.io" \
        --data "config.headers[]=Accept" \
        --data "config.headers[]=Accept-Version" \
        --data "config.headers[]=Content-Length" \
        --data "config.headers[]=Content-MD5" \
        --data "config.headers[]=Content-Type" \
        --data "config.headers[]=Date" \
        --data "config.headers[]=Authorization" \
        --data "config.headers[]=Access-Control-Allow-Origin" \
        --data "config.headers[]=Access-Control-Allow-Methods" \
        --data "config.headers[]=Access-Control-Allow-Headers" \
        --data "config.headers[]=Access-Control-Allow-Credentials" \
        --data "config.exposed_headers[]=*" \
        --data "config.credentials=true" \
        --data "config.max_age=86400" \
        --data "config.preflight_continue=false"
    echo "Konfigurasi CORS selesai"
}

# Modify the start_kong function to include the new setup
start_kong() {
    echo "Starting Kong and database..."
    docker-compose -f docker-compose.yml up -d
    echo "Waiting for database and Kong to be ready..."
    sleep 15
    setup_kong_auth
    setup_kong_routing
    setup_cors
}

# Menu utama
case "$1" in
    start-all)
        start_kong
        ;;
    start-kong)
        start_kong
        ;;
    stop-all)
        echo "Menghentikan semua layanan..."
        docker-compose -f docker-compose.yml down
        ;;
    stop-kong)
        echo "Menghentikan Kong..."
        docker-compose -f docker-compose.yml down
        ;;
    *)
        echo "Penggunaan: $0 {start-all|start-kong|stop-all|stop-kong}"
        echo "  start-all   : Menjalankan Kong dan database"
        echo "  start-kong  : Menjalankan Kong dan database"
        echo "  stop-all    : Menghentikan semua layanan"
        echo "  stop-kong   : Menghentikan Kong dan database"
        exit 1
        ;;
esac