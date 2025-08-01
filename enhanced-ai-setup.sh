#!/bin/bash

# Enhanced AI Server Setup Script - Integrates Local AI Packaged services
# This script merges your existing srv-AI-01 configuration with coleam00/local-ai-packaged

set -e

echo "🚀 Enhanced AI Server Setup - Combining srv-AI-01 + Local AI Packaged"
echo "====================================================================="

# Create directory structure
echo "📁 Creating enhanced directory structure..."
mkdir -p enhanced-ai-server/{config,docker,data,logs}
cd enhanced-ai-server

# Create combined docker-compose.yml
echo "🔧 Creating enhanced docker-compose configuration..."
cat > docker-compose.yml << 'EOF'
version: '3.8'

networks:
  ai-network:
    driver: bridge

volumes:
  postgres_data:
  redis_data:
  minio_data:
  milvus_data:
  ollama_data:
  openwebui_data:
  n8n_data:
  langfuse_data:
  flowise_data:
  neo4j_data:
  qdrant_data:
  supabase_data:
  searxng_data:
  caddy_data:

x-common-env: &common-env
  TZ: ${TZ:-UTC}

services:
  # ============ Core Infrastructure ============
  
  postgres:
    image: postgres:15
    container_name: ai-postgres
    restart: unless-stopped
    environment:
      <<: *common-env
      POSTGRES_USER: ${POSTGRES_USER:-aiserver}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-changeme}
      POSTGRES_DB: ${POSTGRES_DB:-aiserver}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - ai-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-aiserver}"]
      interval: 30s
      timeout: 10s
      retries: 5

  redis:
    image: redis:7-alpine
    container_name: ai-redis
    restart: unless-stopped
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    networks:
      - ai-network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

  minio:
    image: minio/minio:latest
    container_name: ai-minio
    restart: unless-stopped
    command: server /data --console-address ":9001"
    environment:
      <<: *common-env
      MINIO_ROOT_USER: ${MINIO_ROOT_USER:-minioadmin}
      MINIO_ROOT_PASSWORD: ${MINIO_ROOT_PASSWORD:-changeme}
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - minio_data:/data
    networks:
      - ai-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 30s
      timeout: 20s
      retries: 3

  # ============ AI/ML Core Services ============
  
  ollama:
    image: ollama/ollama:latest
    container_name: ai-ollama
    restart: unless-stopped
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    environment:
      <<: *common-env
      OLLAMA_HOST: 0.0.0.0:11434
      OLLAMA_NUM_PARALLEL: ${OLLAMA_NUM_PARALLEL:-4}
      OLLAMA_MAX_LOADED_MODELS: ${OLLAMA_MAX_LOADED_MODELS:-4}
      NVIDIA_VISIBLE_DEVICES: ${NVIDIA_VISIBLE_DEVICES:-all}
      NVIDIA_DRIVER_CAPABILITIES: ${NVIDIA_DRIVER_CAPABILITIES:-compute,utility}
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama
    networks:
      - ai-network

  openwebui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: ai-openwebui
    restart: unless-stopped
    environment:
      <<: *common-env
      OLLAMA_BASE_URL: http://ollama:11434
      WEBUI_AUTH_TYPE: ${WEBUI_AUTH_TYPE:-}
      WEBUI_AUTH: ${WEBUI_AUTH:-True}
      ENABLE_RAG: ${ENABLE_RAG:-True}
      ENABLE_WEBUI_AUTH: ${ENABLE_WEBUI_AUTH:-True}
    ports:
      - "3000:8080"
    volumes:
      - openwebui_data:/app/backend/data
    networks:
      - ai-network
    depends_on:
      - ollama

  # ============ Workflow & Automation ============
  
  n8n:
    image: n8nio/n8n:latest
    container_name: ai-n8n
    restart: unless-stopped
    environment:
      <<: *common-env
      N8N_BASIC_AUTH_ACTIVE: ${N8N_BASIC_AUTH_ACTIVE:-true}
      N8N_BASIC_AUTH_USER: ${N8N_BASIC_AUTH_USER:-admin}
      N8N_BASIC_AUTH_PASSWORD: ${N8N_BASIC_AUTH_PASSWORD:-changeme}
      N8N_ENCRYPTION_KEY: ${N8N_ENCRYPTION_KEY:-super-secret-key}
      N8N_USER_MANAGEMENT_JWT_SECRET: ${N8N_USER_MANAGEMENT_JWT_SECRET:-even-more-secret}
      N8N_HOST: ${N8N_HOST:-localhost}
      N8N_PORT: 5678
      N8N_PROTOCOL: ${N8N_PROTOCOL:-http}
      DB_TYPE: postgres
      DB_POSTGRESDB_HOST: postgres
      DB_POSTGRESDB_PORT: 5432
      DB_POSTGRESDB_DATABASE: n8n
      DB_POSTGRESDB_USER: ${POSTGRES_USER:-aiserver}
      DB_POSTGRESDB_PASSWORD: ${POSTGRES_PASSWORD:-changeme}
      EXECUTIONS_PROCESS: main
    ports:
      - "5678:5678"
    volumes:
      - n8n_data:/home/node/.n8n
    networks:
      - ai-network
    depends_on:
      - postgres
      - redis

  flowise:
    image: flowiseai/flowise:latest
    container_name: ai-flowise
    restart: unless-stopped
    environment:
      <<: *common-env
      FLOWISE_USERNAME: ${FLOWISE_USERNAME:-admin}
      FLOWISE_PASSWORD: ${FLOWISE_PASSWORD:-changeme}
      DATABASE_TYPE: postgres
      DATABASE_HOST: postgres
      DATABASE_PORT: 5432
      DATABASE_NAME: flowise
      DATABASE_USER: ${POSTGRES_USER:-aiserver}
      DATABASE_PASSWORD: ${POSTGRES_PASSWORD:-changeme}
      LANGFUSE_HOST: http://langfuse-web:3000
      REDIS_HOST: redis
      REDIS_PORT: 6379
    ports:
      - "3002:3000"
    volumes:
      - flowise_data:/root/.flowise
    networks:
      - ai-network
    depends_on:
      - postgres
      - redis

  # ============ Vector & Graph Databases ============
  
  milvus:
    image: milvusdb/milvus:latest
    container_name: ai-milvus
    restart: unless-stopped
    environment:
      <<: *common-env
      ETCD_ENDPOINTS: etcd:2379
      MINIO_ADDRESS: minio:9000
      MINIO_ACCESS_KEY: ${MINIO_ROOT_USER:-minioadmin}
      MINIO_SECRET_KEY: ${MINIO_ROOT_PASSWORD:-changeme}
    ports:
      - "19530:19530"
      - "9091:9091"
    volumes:
      - milvus_data:/var/lib/milvus
    networks:
      - ai-network
    depends_on:
      - etcd
      - minio

  etcd:
    image: quay.io/coreos/etcd:v3.5.5
    container_name: ai-etcd
    restart: unless-stopped
    environment:
      ETCD_AUTO_COMPACTION_MODE: revision
      ETCD_AUTO_COMPACTION_RETENTION: 1000
      ETCD_QUOTA_BACKEND_BYTES: 4294967296
    command: etcd -listen-client-urls http://0.0.0.0:2379 -advertise-client-urls http://etcd:2379
    networks:
      - ai-network

  qdrant:
    image: qdrant/qdrant:latest
    container_name: ai-qdrant
    restart: unless-stopped
    ports:
      - "6333:6333"
    volumes:
      - qdrant_data:/qdrant/storage
    networks:
      - ai-network

  neo4j:
    image: neo4j:5
    container_name: ai-neo4j
    restart: unless-stopped
    environment:
      <<: *common-env
      NEO4J_AUTH: ${NEO4J_AUTH:-neo4j/changeme}
      NEO4J_PLUGINS: '["apoc", "graph-data-science"]'
      NEO4J_dbms_security_procedures_unrestricted: apoc.*,gds.*
    ports:
      - "7474:7474"
      - "7687:7687"
    volumes:
      - neo4j_data:/data
    networks:
      - ai-network

  # ============ Observability & Monitoring ============
  
  langfuse-web:
    image: langfuse/langfuse:latest
    container_name: ai-langfuse-web
    restart: unless-stopped
    environment:
      <<: *common-env
      DATABASE_URL: postgresql://${POSTGRES_USER:-aiserver}:${POSTGRES_PASSWORD:-changeme}@postgres:5432/langfuse
      NEXTAUTH_SECRET: ${LANGFUSE_NEXTAUTH_SECRET:-changeme}
      LANGFUSE_SALT: ${LANGFUSE_SALT:-changeme}
      NEXTAUTH_URL: ${LANGFUSE_NEXTAUTH_URL:-http://localhost:3001}
      TELEMETRY_ENABLED: ${TELEMETRY_ENABLED:-false}
      LANGFUSE_ENABLE_EXPERIMENTAL_FEATURES: ${LANGFUSE_ENABLE_EXPERIMENTAL_FEATURES:-false}
    ports:
      - "3001:3000"
    volumes:
      - langfuse_data:/app/data
    networks:
      - ai-network
    depends_on:
      - postgres

  prometheus:
    image: prom/prometheus:latest
    container_name: ai-prometheus
    restart: unless-stopped
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/usr/share/prometheus/console_libraries'
      - '--web.console.templates=/usr/share/prometheus/consoles'
    ports:
      - "9090:9090"
    volumes:
      - ./config/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus_data:/prometheus
    networks:
      - ai-network

  grafana:
    image: grafana/grafana:latest
    container_name: ai-grafana
    restart: unless-stopped
    environment:
      <<: *common-env
      GF_SECURITY_ADMIN_PASSWORD: ${GF_SECURITY_ADMIN_PASSWORD:-changeme}
      GF_USERS_ALLOW_SIGN_UP: false
    ports:
      - "3003:3000"
    volumes:
      - grafana_data:/var/lib/grafana
    networks:
      - ai-network
    depends_on:
      - prometheus

  # ============ Search & Web Services ============
  
  searxng:
    image: searxng/searxng:latest
    container_name: ai-searxng
    restart: unless-stopped
    environment:
      <<: *common-env
      SEARXNG_BASE_URL: ${SEARXNG_BASE_URL:-http://localhost:8080}
    ports:
      - "8080:8080"
    volumes:
      - searxng_data:/etc/searxng
    networks:
      - ai-network

  # ============ Reverse Proxy ============
  
  caddy:
    image: caddy:latest
    container_name: ai-caddy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - caddy_data:/data
      - ./config/Caddyfile:/etc/caddy/Caddyfile
    networks:
      - ai-network
    depends_on:
      - openwebui
      - n8n
      - flowise
      - langfuse-web
      - grafana

  # ============ Additional from Local AI Packaged ============
  
  # Supabase services would go here if needed
  # (Note: Supabase is complex and requires multiple containers)
  # Consider if you need this vs your existing PostgreSQL setup

volumes:
  prometheus_data:
  grafana_data:

EOF

# Create enhanced .env.example
echo "📝 Creating enhanced environment configuration template..."
cat > .env.example << 'EOF'
# Enhanced AI Server Environment Configuration
# This combines srv-AI-01 + Local AI Packaged settings

# ============ Core Database ============
POSTGRES_USER=aiserver
POSTGRES_PASSWORD=your_very_secure_postgres_password_here
POSTGRES_DB=aiserver

# ============ MinIO Object Storage ============
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=your_very_secure_minio_password_here

# ============ n8n Workflow Automation ============
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=your_very_secure_n8n_password_here
N8N_ENCRYPTION_KEY=your_32_character_encryption_key_here
N8N_USER_MANAGEMENT_JWT_SECRET=your_jwt_secret_key_here_32_chars
N8N_HOST=localhost
N8N_PROTOCOL=http

# ============ Flowise AI ============
FLOWISE_USERNAME=admin
FLOWISE_PASSWORD=your_very_secure_flowise_password_here

# ============ Langfuse Observability ============
LANGFUSE_NEXTAUTH_SECRET=your_very_secure_nextauth_secret_here
LANGFUSE_SALT=your_very_secure_salt_here_16_chars_min
LANGFUSE_NEXTAUTH_URL=http://localhost:3001
TELEMETRY_ENABLED=false
LANGFUSE_ENABLE_EXPERIMENTAL_FEATURES=false

# ============ Grafana Monitoring ============
GF_SECURITY_ADMIN_PASSWORD=your_very_secure_grafana_password_here

# ============ Neo4j Graph Database ============
NEO4J_AUTH=neo4j/your_very_secure_neo4j_password_here

# ============ Ollama AI Model Server ============
OLLAMA_NUM_PARALLEL=4
OLLAMA_MAX_LOADED_MODELS=4
OLLAMA_HOST=0.0.0.0:11434

# ============ GPU Configuration ============
NVIDIA_VISIBLE_DEVICES=all
NVIDIA_DRIVER_CAPABILITIES=compute,utility

# ============ Open WebUI ============
WEBUI_AUTH=True
ENABLE_RAG=True
ENABLE_WEBUI_AUTH=True

# ============ Timezone ============
TZ=UTC

# ============ Domains (for Caddy) ============
# Uncomment and configure if using custom domains
# DOMAIN_OPENWEBUI=ai-chat.yourdomain.com
# DOMAIN_N8N=workflows.yourdomain.com
# DOMAIN_FLOWISE=ai-builder.yourdomain.com
# DOMAIN_LANGFUSE=ai-monitoring.yourdomain.com
# DOMAIN_GRAFANA=metrics.yourdomain.com
EOF

# Create Caddyfile for reverse proxy
echo "🌐 Creating Caddy reverse proxy configuration..."
mkdir -p config
cat > config/Caddyfile << 'EOF'
# Caddy reverse proxy configuration for AI services

# Default configuration for local access
:80 {
    # Open WebUI (AI Chat Interface)
    handle_path /chat* {
        reverse_proxy openwebui:8080
    }
    
    # n8n (Workflow Automation)
    handle_path /workflows* {
        reverse_proxy n8n:5678
    }
    
    # Flowise (AI Builder)
    handle_path /ai-builder* {
        reverse_proxy flowise:3000
    }
    
    # Langfuse (AI Monitoring)
    handle_path /monitoring* {
        reverse_proxy langfuse-web:3000
    }
    
    # Grafana (System Metrics)
    handle_path /metrics* {
        reverse_proxy grafana:3000
    }
    
    # Default root
    handle {
        respond "AI Server - Available Services:
        /chat - Open WebUI
        /workflows - n8n
        /ai-builder - Flowise
        /monitoring - Langfuse
        /metrics - Grafana
        " 200
    }
}

# Custom domain configuration (uncomment and modify as needed)
# {$DOMAIN_OPENWEBUI:localhost} {
#     reverse_proxy openwebui:8080
# }
# 
# {$DOMAIN_N8N:localhost} {
#     reverse_proxy n8n:5678
# }
EOF

# Create Prometheus configuration
echo "📊 Creating Prometheus monitoring configuration..."
cat > config/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'ollama'
    static_configs:
      - targets: ['ollama:11434']
    metrics_path: /metrics

  - job_name: 'milvus'
    static_configs:
      - targets: ['milvus:9091']

  - job_name: 'qdrant'
    static_configs:
      - targets: ['qdrant:6333']
    metrics_path: /metrics

  - job_name: 'neo4j'
    static_configs:
      - targets: ['neo4j:2004']

  - job_name: 'node'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']
EOF

# Create enhanced management script
echo "🔧 Creating enhanced management script..."
cat > manage.sh << 'EOF'
#!/bin/bash

# Enhanced AI Server Management Script
# Manages all AI services from srv-AI-01 + Local AI Packaged

set -e

COMPOSE_FILE="docker-compose.yml"
SERVICES=(postgres redis minio ollama openwebui n8n flowise milvus qdrant neo4j langfuse-web prometheus grafana searxng caddy)

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Functions
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

case "$1" in
    start)
        print_status "Starting all AI services..."
        docker-compose up -d
        print_status "All services started!"
        echo ""
        echo "🌐 Service URLs:"
        echo "   Open WebUI (AI Chat): http://localhost:3000"
        echo "   n8n (Workflows): http://localhost:5678"
        echo "   Flowise (AI Builder): http://localhost:3002"
        echo "   Langfuse (Monitoring): http://localhost:3001"
        echo "   Grafana (Metrics): http://localhost:3003"
        echo "   Neo4j Browser: http://localhost:7474"
        echo "   Qdrant Dashboard: http://localhost:6333/dashboard"
        echo "   MinIO Console: http://localhost:9001"
        echo "   SearXNG: http://localhost:8080"
        echo "   Prometheus: http://localhost:9090"
        ;;
        
    stop)
        print_status "Stopping all AI services..."
        docker-compose down
        print_status "All services stopped!"
        ;;
        
    restart)
        print_status "Restarting all AI services..."
        docker-compose restart
        print_status "All services restarted!"
        ;;
        
    status)
        print_status "AI Service Status:"
        docker-compose ps
        ;;
        
    logs)
        if [ -z "$2" ]; then
            docker-compose logs --tail=50 --follow
        else
            docker-compose logs --tail=50 --follow "$2"
        fi
        ;;
        
    update)
        print_status "Updating all Docker images..."
        docker-compose pull
        print_status "Images updated! Restart services to apply."
        ;;
        
    cleanup)
        print_warning "Cleaning up unused Docker resources..."
        docker system prune -a --volumes
        print_status "Cleanup complete!"
        ;;
        
    health)
        print_status "Checking service health..."
        for service in "${SERVICES[@]}"; do
            if docker ps | grep -q "ai-$service"; then
                echo -e "   $service: ${GREEN}✓ Running${NC}"
            else
                echo -e "   $service: ${RED}✗ Not running${NC}"
            fi
        done
        ;;
        
    gpu-test)
        print_status "Testing GPU support..."
        docker run --rm --gpus all nvidia/cuda:11.8-base-ubuntu20.04 nvidia-smi
        ;;
        
    backup)
        print_status "Creating backup of all data volumes..."
        timestamp=$(date +%Y%m%d_%H%M%S)
        backup_dir="backups/backup_$timestamp"
        mkdir -p "$backup_dir"
        
        for volume in $(docker volume ls -q | grep '^ai-'); do
            print_status "Backing up volume: $volume"
            docker run --rm -v "$volume:/data" -v "$PWD/$backup_dir:/backup" alpine tar czf "/backup/${volume}.tar.gz" -C /data .
        done
        
        print_status "Backup complete! Location: $backup_dir"
        ;;
        
    *)
        echo "Enhanced AI Server Management"
        echo ""
        echo "Usage: $0 {start|stop|restart|status|logs|update|cleanup|health|gpu-test|backup}"
        echo ""
        echo "Commands:"
        echo "  start     - Start all AI services"
        echo "  stop      - Stop all AI services"
        echo "  restart   - Restart all AI services"
        echo "  status    - Show service status"
        echo "  logs      - View logs (optionally specify service)"
        echo "  update    - Update all Docker images"
        echo "  cleanup   - Clean unused Docker resources"
        echo "  health    - Check service health"
        echo "  gpu-test  - Test GPU support"
        echo "  backup    - Backup all data volumes"
        exit 1
        ;;
esac
EOF

chmod +x manage.sh

# Create model installation script
echo "🤖 Creating model installation script..."
cat > install-models.sh << 'EOF'
#!/bin/bash

# Enhanced AI Model Installation Script

echo "🤖 Installing AI Models..."

# Core models from original setup
models=(
    "llama3.2:3b"
    "phi3.5:3.8b"
    "qwen2.5:7b"
    "codellama:7b"
    "nomic-embed-text"
    "llava:7b"
)

# Additional models for enhanced capabilities
enhanced_models=(
    "mistral:7b"
    "neural-chat:7b"
    "starling-lm:7b"
    "openhermes:7b"
    "deepseek-coder:6.7b"
)

echo "📦 Installing core models..."
for model in "${models[@]}"; do
    echo "Installing $model..."
    docker exec ai-ollama ollama pull "$model"
done

echo ""
echo "❓ Would you like to install enhanced models? (y/n)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "📦 Installing enhanced models..."
    for model in "${enhanced_models[@]}"; do
        echo "Installing $model..."
        docker exec ai-ollama ollama pull "$model"
    done
fi

echo ""
echo "✅ Model installation complete!"
echo "📋 To see installed models: docker exec ai-ollama ollama list"
EOF

chmod +x install-models.sh

# Create clean interactive setup script
echo "🚀 Creating clean interactive setup script..."
cat > setup.sh << 'EOF'
#!/bin/bash

# AI Server Interactive Setup Script

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}$1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Generate secure password
generate_password() {
    openssl rand -base64 ${1:-24} | tr -d "=+/" | cut -c1-${1:-24}
}

# Prompt for input
prompt_input() {
    local prompt="$1"
    local default="$2"
    local secure="$3"
    local value
    
    if [ "$secure" = "true" ]; then
        echo -n -e "${BLUE}$prompt${NC}"
        echo -n " [press Enter for auto-generated]: "
        read -s value
        echo
        [ -z "$value" ] && value="$default"
    else
        echo -n -e "${BLUE}$prompt${NC}"
        echo -n " [$default]: "
        read value
        [ -z "$value" ] && value="$default"
    fi
    
    echo "$value"
}

print_header "🤖 AI Server Interactive Setup"
print_header "==============================="
echo ""

# Check existing .env
if [ -f .env ]; then
    print_warning ".env file already exists!"
    echo -n "Recreate it? (y/N): "
    read recreate
    if [[ ! "$recreate" =~ ^[Yy]$ ]]; then
        print_success "Keeping existing .env file"
        exit 0
    fi
fi

print_header "🔐 Database Configuration"
POSTGRES_USER=$(prompt_input "PostgreSQL username" "aiserver" "false")
POSTGRES_PASSWORD=$(prompt_input "PostgreSQL password" "$(generate_password 20)" "true")
POSTGRES_DB=$(prompt_input "Database name" "aiserver" "false")

echo ""
print_header "🗄️ Storage Configuration"
MINIO_ROOT_USER=$(prompt_input "MinIO username" "minioadmin" "false")
MINIO_ROOT_PASSWORD=$(prompt_input "MinIO password" "$(generate_password 16)" "true")

echo ""
print_header "🔄 Service Passwords"
N8N_BASIC_AUTH_USER=$(prompt_input "n8n username" "admin" "false")
N8N_BASIC_AUTH_PASSWORD=$(prompt_input "n8n password" "$(generate_password 12)" "true")
N8N_ENCRYPTION_KEY=$(generate_password 32)
N8N_USER_MANAGEMENT_JWT_SECRET=$(generate_password 32)

FLOWISE_USERNAME=$(prompt_input "Flowise username" "admin" "false")
FLOWISE_PASSWORD=$(prompt_input "Flowise password" "$(generate_password 12)" "true")

LANGFUSE_NEXTAUTH_SECRET=$(generate_password 32)
LANGFUSE_SALT=$(generate_password 16)

GF_SECURITY_ADMIN_PASSWORD=$(prompt_input "Grafana password" "$(generate_password 12)" "true")

NEO4J_PASSWORD=$(prompt_input "Neo4j password" "$(generate_password 12)" "true")
NEO4J_AUTH="neo4j/$NEO4J_PASSWORD"

echo ""
print_header "🤖 AI Configuration"
OLLAMA_NUM_PARALLEL=$(prompt_input "Ollama parallel requests" "4" "false")
OLLAMA_MAX_LOADED_MODELS=$(prompt_input "Ollama max models" "4" "false")

TZ=$(prompt_input "Timezone" "UTC" "false")

print_header "🔐 Creating configuration..."

# Create .env file
cat > .env << ENV_EOF
# AI Server Configuration - Generated $(date)

# Database
POSTGRES_USER=$POSTGRES_USER
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
POSTGRES_DB=$POSTGRES_DB

# Storage  
MINIO_ROOT_USER=$MINIO_ROOT_USER
MINIO_ROOT_PASSWORD=$MINIO_ROOT_PASSWORD

# n8n
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=$N8N_BASIC_AUTH_USER
N8N_BASIC_AUTH_PASSWORD=$N8N_BASIC_AUTH_PASSWORD
N8N_ENCRYPTION_KEY=$N8N_ENCRYPTION_KEY
N8N_USER_MANAGEMENT_JWT_SECRET=$N8N_USER_MANAGEMENT_JWT_SECRET
N8N_HOST=localhost
N8N_PROTOCOL=http

# Flowise
FLOWISE_USERNAME=$FLOWISE_USERNAME
FLOWISE_PASSWORD=$FLOWISE_PASSWORD

# Langfuse
LANGFUSE_NEXTAUTH_SECRET=$LANGFUSE_NEXTAUTH_SECRET
LANGFUSE_SALT=$LANGFUSE_SALT
LANGFUSE_NEXTAUTH_URL=http://localhost:3001
TELEMETRY_ENABLED=false

# Grafana
GF_SECURITY_ADMIN_PASSWORD=$GF_SECURITY_ADMIN_PASSWORD

# Neo4j
NEO4J_AUTH=$NEO4J_AUTH

# Ollama
OLLAMA_NUM_PARALLEL=$OLLAMA_NUM_PARALLEL
OLLAMA_MAX_LOADED_MODELS=$OLLAMA_MAX_LOADED_MODELS
OLLAMA_HOST=0.0.0.0:11434

# GPU
NVIDIA_VISIBLE_DEVICES=all
NVIDIA_DRIVER_CAPABILITIES=compute,utility

# WebUI
WEBUI_AUTH=True
ENABLE_RAG=True
ENABLE_WEBUI_AUTH=True

# System
TZ=$TZ
ENV_EOF

chmod 600 .env

print_success ".env file created!"
echo ""

# Create directories
mkdir -p config data logs backups

# Check Docker
if ! command -v docker &> /dev/null; then
    print_warning "Docker not installed - install it first"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    print_warning "Docker Compose not installed - install it first"
    exit 1
fi

# GPU optimization
if command -v nvidia-smi &> /dev/null; then
    print_success "NVIDIA GPU detected"
    echo -n "Optimize for RTX 3090? (y/N): "
    read optimize_gpu
    if [[ "$optimize_gpu" =~ ^[Yy]$ ]]; then
        sed -i "s/OLLAMA_NUM_PARALLEL=$OLLAMA_NUM_PARALLEL/OLLAMA_NUM_PARALLEL=6/" .env
        sed -i "s/OLLAMA_MAX_LOADED_MODELS=$OLLAMA_MAX_LOADED_MODELS/OLLAMA_MAX_LOADED_MODELS=6/" .env
        print_success "GPU settings optimized!"
    fi
fi

echo ""
print_header "✅ Setup Complete!"
echo ""
print_success "Next steps:"
echo "1. ./manage.sh start"
echo "2. ./install-models.sh"
echo "3. Open http://localhost:3000"
echo ""
print_success "Login credentials stored in .env file"
EOF

chmod +x setup.sh

# Create README for the enhanced setup
echo "📖 Creating documentation..."
cat > README.md << 'EOF'
# Enhanced AI Server - srv-AI-01 + Local AI Packaged

This enhanced configuration combines the best of both worlds:
- Original srv-AI-01 production-ready setup
- Additional services from coleam00/local-ai-packaged

## 🚀 New Services Added

### From Local AI Packaged:
- **Qdrant**: High-performance vector database (alternative to Milvus)
- **Neo4j**: Knowledge graph engine for GraphRAG
- **SearXNG**: Privacy-focused metasearch engine
- **Caddy**: Automatic HTTPS reverse proxy
- **Enhanced n8n**: Additional AI components and integrations
- **Enhanced Flowise**: Better integration with other services

## 🌐 Service URLs

### Core AI Services
- **Open WebUI** (AI Chat): http://localhost:3000
- **n8n** (Workflows): http://localhost:5678
- **Flowise** (AI Builder): http://localhost:3002

### Databases
- **Neo4j Browser**: http://localhost:7474
- **Qdrant Dashboard**: http://localhost:6333/dashboard
- **MinIO Console**: http://localhost:9001

### Monitoring & Search
- **Langfuse** (AI Monitoring): http://localhost:3001
- **Grafana** (Metrics): http://localhost:3003
- **Prometheus**: http://localhost:9090
- **SearXNG** (Search): http://localhost:8080

## 🔧 Quick Start

1. **Setup**:
   ```bash
   ./setup.sh
   ```

2. **Configure** (edit with secure passwords):
   ```bash
   nano .env
   ```

3. **Start Services**:
   ```bash
   ./manage.sh start
   ```

4. **Install AI Models**:
   ```bash
   ./install-models.sh
   ```

## 📊 Enhanced Features

### Dual Vector Database Support
- **Milvus**: Production-grade vector database
- **Qdrant**: High-performance alternative with rich API

### Knowledge Graph Capabilities
- **Neo4j**: Enable GraphRAG and advanced relationship queries
- **Graph algorithms** and data science tools included

### Enhanced Search
- **SearXNG**: Aggregate results from 200+ search engines
- **Privacy-focused**: No tracking or user profiling

### Better Integration
- **Caddy**: Automatic SSL certificates for custom domains
- **Unified authentication**: Shared auth between services
- **Cross-service communication**: Optimized network setup

## 🔒 Security Notes

1. **Change ALL default passwords** in `.env` file
2. **Use Caddy** for SSL termination in production
3. **Configure firewall** rules as needed
4. **Regular backups**: Use `./manage.sh backup`

## 🚀 Performance Tips

### For Your Hardware (Ryzen 9 + RTX 3090 + 198GB RAM)
- Increase `OLLAMA_NUM_PARALLEL` to 6-8
- Increase `OLLAMA_MAX_LOADED_MODELS` to 6-8
- Enable both Milvus and Qdrant for different use cases
- Use Neo4j for complex relationship queries

### Resource Allocation
- PostgreSQL: 8GB RAM
- Neo4j: 16GB RAM
- Milvus + Qdrant: 32GB RAM combined
- Ollama: 64GB+ RAM for models
- Remaining: System and Docker services

## 📝 Management Commands

```bash
./manage.sh start|stop|restart|status|logs|update|cleanup|health|gpu-test|backup
```

## 🎯 Use Cases

1. **Advanced RAG**: Use both vector databases for different document types
2. **Knowledge Graphs**: Build relationship-aware AI applications
3. **Multi-Agent Workflows**: Complex n8n + Flowise automations
4. **Private Search**: SearXNG for web data without tracking
5. **Production Deployment**: Caddy for automatic SSL

---

**Enjoy your enhanced AI infrastructure!** 🚀
EOF

echo ""
echo "✅ Enhanced AI Server configuration created!"
echo ""
echo "📁 Created files:"
echo "   - docker-compose.yml (combined services)"
echo "   - .env.example (environment template)"
echo "   - manage.sh (management script)"
echo "   - setup.sh (setup script)"
echo "   - install-models.sh (model installer)"
echo "   - config/Caddyfile (reverse proxy)"
echo "   - config/prometheus.yml (monitoring)"
echo "   - README.md (documentation)"
echo ""
echo "📝 Next steps:"
echo "1. cd enhanced-ai-server"
echo "2. Review the configuration"
echo "3. Copy to your ISO build for inclusion"