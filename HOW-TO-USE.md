# How to Use Your Custom Ubuntu Server AI ISO

This guide explains how to use the custom Ubuntu Server AI ISO that was created specifically for your AI infrastructure deployment.

## 📋 Prerequisites

### Hardware Requirements
- **CPU**: AMD Ryzen 7+ or Intel i7+ (8+ cores recommended)
- **RAM**: 32GB minimum (64GB+ recommended for large AI models)
- **GPU**: NVIDIA RTX series with 8GB+ VRAM (RTX 3090 optimal)
- **Storage**: 1TB+ NVMe SSD (2TB+ recommended)
- **Network**: Gigabit Ethernet connection
- **USB Drive**: 8GB+ for ISO writing (if installing on hardware)

### What You Have
✅ **Custom ISO**: `ubuntu-24.04.2-server-ai-amd64.iso` (3.0GB)  
✅ **Checksums**: MD5 and SHA256 files for verification  
✅ **AI Configuration**: Complete srv-AI-01 setup embedded  

---

## 🚀 Method 1: Hardware Installation (Recommended)

### Step 1: Prepare Installation Media

#### Option A: Create Bootable USB Drive (Linux)
```bash
# Verify ISO integrity first
md5sum -c ubuntu-24.04.2-server-ai-amd64.iso.md5

# Find your USB device
lsblk

# Write ISO to USB (replace /dev/sdX with your USB device)
sudo dd if=ubuntu-24.04.2-server-ai-amd64.iso of=/dev/sdX bs=4M status=progress oflag=sync

# Verify write completed successfully
sync
```

#### Option B: Create Bootable USB Drive (Windows)
1. Download **Rufus** from https://rufus.ie/
2. Insert USB drive (8GB+)
3. Open Rufus
4. Select your USB device
5. Click "SELECT" and choose `ubuntu-24.04.2-server-ai-amd64.iso`
6. Partition scheme: **GPT**
7. Target system: **UEFI (non CSM)**
8. Click "START" and wait for completion

#### Option C: Burn to DVD
Use your preferred DVD burning software to burn the ISO to a DVD-R.

### Step 2: Boot Target System

1. **Insert** USB drive or DVD into target system
2. **Power on** and enter BIOS/UEFI settings (usually F2, F12, or Delete key)
3. **Configure boot settings**:
   - Enable UEFI boot mode (recommended)
   - Disable Secure Boot (may be required)
   - Set USB/DVD as first boot device
4. **Save and exit** BIOS/UEFI
5. **System should boot** from your installation media

### Step 3: Installation Process

#### Ubuntu Installation Wizard
1. **Language Selection**: Choose your preferred language
2. **Keyboard Layout**: Select keyboard layout
3. **Network Configuration**: 
   - Configure network connection (wired recommended)
   - System will download updates during installation
4. **Storage Configuration**:
   - **Use entire disk** (recommended for dedicated AI server)
   - Or **Manual partitioning** if you need custom layout
5. **Profile Setup**:
   - **Name**: AI Server Administrator
   - **Username**: `aiserver` (or your preference)
   - **Password**: Create a strong password (replace default)
6. **SSH Setup**: Enable OpenSSH server (recommended)
7. **Featured Server Snaps**: Skip (Docker will be installed via post-install script)
8. **Installation**: Wait for completion (15-30 minutes)

### Step 4: First Boot Setup

1. **Remove installation media** when prompted
2. **System reboots** automatically
3. **Login**: Use the credentials you created during installation
4. **Update system** (recommended):
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

---

## 💻 Method 2: Virtual Machine Installation

Perfect for testing before hardware deployment.

### Step 1: VM Configuration

#### VMware Workstation/vSphere
```
- Memory: 16GB minimum (32GB+ recommended)
- CPU: 8+ cores with VT-x/AMD-V enabled
- Disk: 100GB+ (thin provisioned acceptable)
- Network: Bridged or NAT with internet access
- Boot: UEFI firmware (recommended)
- Graphics: Enable 3D acceleration if available
```

#### VirtualBox
```
- Memory: 16GB minimum
- CPU: 8+ cores with VT-x/AMD-V enabled
- Disk: 100GB+ VDI dynamic
- Network: Bridged Adapter
- System: Enable EFI
- Acceleration: Enable VT-x/AMD-V
```

#### QEMU/KVM
```bash
# Create disk image
qemu-img create -f qcow2 ai-server.qcow2 100G

# Start VM
qemu-system-x86_64 \
    -m 16384 \
    -smp 8 \
    -cpu host \
    -enable-kvm \
    -drive file=ai-server.qcow2,format=qcow2 \
    -cdrom ubuntu-24.04.2-server-ai-amd64.iso \
    -boot d \
    -netdev user,id=net0 \
    -device virtio-net,netdev=net0 \
    -display gtk
```

### Step 2: VM Installation
Follow the same installation steps as hardware installation above.

---

## ⚙️ Post-Installation Setup

### Step 1: Run AI Server Post-Install Script

Your ISO includes a comprehensive post-installation script:

```bash
# Navigate to AI setup directory
cd ~/ai-setup

# Run post-installation script
sudo ./post-install.sh
```

**What this script does**:
- ✅ Installs Docker CE and Docker Compose
- ✅ Installs NVIDIA drivers (if GPU detected)
- ✅ Installs NVIDIA Container Toolkit
- ✅ Configures Docker for GPU support
- ✅ Applies system optimizations for AI workloads
- ✅ Configures firewall for AI services
- ✅ Sets up file descriptor limits
- ✅ Enables required services

### Step 2: Interactive Configuration

```bash
# Run interactive configuration wizard
./setup.sh
```

**What this interactive script does**:
- 🔐 **Auto-generates secure passwords** for all services
- 💬 **Simple prompts** for usernames and settings
- 🎯 **GPU optimization** for RTX 3090 hardware
- 📄 **Creates .env file automatically**
- ✅ **Validates Docker installation**

**Interactive prompts include**:
- Database and storage credentials  
- Service usernames and passwords
- AI model configuration
- System settings (timezone, GPU)

**Alternative manual method**:
```bash
# If you prefer manual configuration
cp .env.example .env
nano .env  # Edit with your own secure passwords
```

### Step 3: Initialize AI Services

```bash
# Run initial setup
./setup.sh

# Start all AI services
./manage.sh start

# Verify services are running
./manage.sh status
```

### Step 4: Install AI Models

```bash
# Install recommended AI models
./install-models.sh

# This will install:
# - llama3.2:3b (general purpose)
# - phi3.5:3.8b (efficient model)
# - qwen2.5:7b (multilingual)
# - nomic-embed-text (embeddings for RAG)
```

---

## 🌐 Accessing Your AI Services

After successful setup, access your AI services through web browser:

### Core AI Services
- **🤖 Open WebUI**: http://your-server-ip:3000
  - Main AI chat interface
  - Upload documents for RAG
  - Model management
  
- **🔧 n8n**: http://your-server-ip:5678
  - Workflow automation with 400+ integrations
  - Advanced AI components
  - Login: admin / [your_n8n_password]
  
- **📊 Langfuse**: http://your-server-ip:3001
  - LLM observability and monitoring
  - Agent performance tracking
  - Create account on first visit

### Advanced AI Tools
- **🌊 Flowise**: http://your-server-ip:3002
  - Low-code AI application builder
  - Drag-and-drop AI workflows
  - Login: admin / [your_flowise_password]

### Vector & Graph Databases
- **🧠 Neo4j Browser**: http://your-server-ip:7474
  - Knowledge graph visualization
  - GraphRAG capabilities
  - Login: neo4j / [your_neo4j_password]
  
- **🎯 Qdrant Dashboard**: http://your-server-ip:6333/dashboard
  - High-performance vector search
  - Collection management
  - API documentation

### Search & Web Services
- **🔍 SearXNG**: http://your-server-ip:8080
  - Privacy-focused metasearch
  - Aggregates 229 search engines
  - No tracking or profiling

### Monitoring & Storage
- **📈 Grafana**: http://your-server-ip:3003
  - System monitoring dashboards
  - AI performance metrics
  - Login: admin / [your_grafana_password]
  
- **📊 Prometheus**: http://your-server-ip:9090
  - Metrics collection and queries
  - Alert management
  
- **🗄️ MinIO Console**: http://your-server-ip:9001
  - Object storage management
  - S3-compatible API
  - Login: minioadmin / [your_minio_password]

### Reverse Proxy
- **🌐 Caddy**: http://your-server-ip
  - Automatic HTTPS certificates
  - Service routing dashboard
  - Custom domain management

---

## 🔧 System Management

### Service Management Commands

```bash
# Check status of all services
./manage.sh status

# Start/stop/restart services
./manage.sh start
./manage.sh stop
./manage.sh restart

# View logs
./manage.sh logs [service-name]
./manage.sh logs ollama        # Example: view Ollama logs

# Update Docker images
./manage.sh update

# Cleanup unused resources
./manage.sh cleanup

# System health check
./manage.sh health

# Backup data
./manage.sh backup

# Restore from backup
./manage.sh restore backup-file.tar.gz
```

### AI Model Management

```bash
# List installed models
docker exec ai-ollama ollama list

# Install additional models
docker exec ai-ollama ollama pull llama3.2:70b
docker exec ai-ollama ollama pull codellama:7b

# Remove models
docker exec ai-ollama ollama rm model-name

# Check model status
docker exec ai-ollama ollama ps
```

### System Monitoring

```bash
# Check GPU usage
nvidia-smi

# Monitor system resources
htop

# Check Docker status
docker system df
docker stats

# View container logs
docker logs ai-ollama
docker logs ai-openwebui
```

---

## 🔒 Security Configuration

### Essential Security Steps

1. **Change Default Passwords**:
   ```bash
   # Change user password
   sudo passwd aiserver
   
   # Update all service passwords in .env file
   nano ~/ai-setup/.env
   ```

2. **Configure SSH Key Authentication**:
   ```bash
   # Generate SSH key (on your client machine)
   ssh-keygen -t ed25519 -C "your-email@example.com"
   
   # Copy key to server
   ssh-copy-id aiserver@your-server-ip
   
   # Disable password authentication (optional but recommended)
   sudo nano /etc/ssh/sshd_config
   # Set: PasswordAuthentication no
   sudo systemctl restart sshd
   ```

3. **Review Firewall Rules**:
   ```bash
   # Check current rules
   sudo ufw status verbose
   
   # Add custom rules if needed
   sudo ufw allow from your-trusted-ip to any port 22
   
   # Remove rules if needed
   sudo ufw delete allow 3000/tcp
   ```

### SSL Certificate Setup (Production)

For production deployment, set up SSL certificates:

```bash
# Install Certbot
sudo apt install certbot

# Get certificates (replace with your domain)
sudo certbot certonly --standalone -d your-domain.com

# Configure reverse proxy with SSL (nginx example)
sudo apt install nginx
# Configure nginx with SSL - see nginx documentation
```

---

## 🚨 Troubleshooting

### Common Issues and Solutions

#### GPU Not Detected
```bash
# Check if GPU is visible
lspci | grep -i nvidia

# Verify NVIDIA drivers
nvidia-smi

# Reinstall drivers if needed
sudo apt purge nvidia-* && sudo apt autoremove
sudo apt install nvidia-driver-535
sudo reboot

# Check Docker GPU support
docker run --rm --gpus all nvidia/cuda:11.8-base-ubuntu20.04 nvidia-smi
```

#### Services Won't Start
```bash
# Check Docker daemon
sudo systemctl status docker

# Restart Docker if needed
sudo systemctl restart docker

# Check individual service logs
./manage.sh logs ollama
./manage.sh logs postgres

# Verify ports aren't in use
sudo netstat -tulpn | grep :3000
```

#### Out of Memory Issues
```bash
# Check memory usage
free -h

# Check swap
swapon --show

# Add swap if needed (temporary)
sudo fallocate -l 16G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Reduce concurrent models
# Edit OLLAMA_MAX_LOADED_MODELS in .env file
```

#### Network Issues
```bash
# Check network connectivity
ping google.com

# Check DNS resolution
nslookup github.com

# Restart networking
sudo systemctl restart systemd-networkd
```

#### Container Issues
```bash
# Restart specific container
docker restart ai-ollama

# Rebuild container
docker-compose down
docker-compose up -d

# Clean up Docker system
docker system prune -a
```

---

## 📊 Performance Optimization

### For High-Performance Scenarios

1. **Increase Concurrent Models**:
   ```bash
   # Edit .env file
   nano ~/ai-setup/.env
   
   # Increase values based on your RAM
   OLLAMA_NUM_PARALLEL=6
   OLLAMA_MAX_LOADED_MODELS=6
   ```

2. **SSD Cache for Models**:
   ```bash
   # Move model storage to fastest SSD
   sudo systemctl stop docker
   sudo mv /var/lib/docker /path/to/faster/ssd/docker
   sudo ln -s /path/to/faster/ssd/docker /var/lib/docker
   sudo systemctl start docker
   ```

### For Resource-Constrained Scenarios

1. **Use Smaller Models**:
   ```bash
   # Install lightweight models
   docker exec ai-ollama ollama pull llama3.2:1b
   docker exec ai-ollama ollama pull phi3.5:3.8b
   ```

2. **Reduce Resource Usage**:
   ```bash
   # Edit .env file
   OLLAMA_NUM_PARALLEL=2
   OLLAMA_MAX_LOADED_MODELS=2
   ```

---

## 🔄 Maintenance and Updates

### Regular Maintenance Tasks

#### Weekly
```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Update Docker images
cd ~/ai-setup
./manage.sh update

# Check disk space
df -h

# Review service logs for errors
./manage.sh logs | grep -i error
```

#### Monthly
```bash
# Clean up Docker system
docker system prune -a

# Backup configuration and data
./manage.sh backup

# Update AI models
docker exec ai-ollama ollama pull llama3.2:3b
docker exec ai-ollama ollama pull qwen2.5:7b
```

#### Quarterly
```bash
# Review and update security patches
sudo apt update && sudo apt upgrade -y

# Review firewall rules
sudo ufw status

# Update SSL certificates (if using)
sudo certbot renew

# Performance review and optimization
```

---

## 📈 Monitoring and Analytics

### Built-in Monitoring

1. **Grafana Dashboards**:
   - Access at http://your-server-ip:3003
   - Pre-configured dashboards for system metrics
   - AI model performance monitoring

2. **Langfuse Analytics**:
   - Access at http://your-server-ip:3001
   - Track AI model usage and performance
   - Monitor token consumption

3. **System Commands**:
   ```bash
   # Real-time GPU monitoring
   watch -n 1 nvidia-smi
   
   # System resource monitoring
   htop
   
   # Docker container monitoring
   docker stats
   ```

---

## 🆘 Getting Help

### Log Files and Diagnostics

```bash
# System logs
sudo journalctl -xe

# Service-specific logs
./manage.sh logs ollama
./manage.sh logs postgres
./manage.sh logs n8n

# Docker daemon logs
sudo journalctl -u docker.service

# System health check
./manage.sh health
```

### Creating Support Reports

When seeking help, include:

1. **System Information**:
   ```bash
   uname -a
   lsb_release -a
   nvidia-smi
   docker --version
   docker-compose --version
   ```

2. **Service Status**:
   ```bash
   ./manage.sh status > service-status.txt
   ```

3. **Error Logs**:
   ```bash
   # Recent system errors
   sudo journalctl --since "1 hour ago" --priority=err
   
   # Service errors
   ./manage.sh logs [problematic-service]
   ```

---

## 🎉 Congratulations!

You now have a fully functional AI server running on Ubuntu with:

✅ **Multiple AI Models** ready for inference  
✅ **Web-based AI Chat Interface** (Open WebUI)  
✅ **Workflow Automation** (n8n)  
✅ **Vector Database** for RAG applications (Milvus)  
✅ **AI Observability** and monitoring (Langfuse)  
✅ **Low-code AI Development** (Flowise)  
✅ **Comprehensive Monitoring** (Grafana + Prometheus)  
✅ **Production-ready Infrastructure** with Docker orchestration  

**Your AI infrastructure is now ready for production use!** 🚀

---

*For additional support and advanced configurations, refer to the individual service documentation or the srv-AI-01 project documentation.*