# Custom Ubuntu Server ISO for AI Infrastructure

This directory contains the complete custom Ubuntu Server ISO with embedded AI infrastructure configuration from `srv-AI-01`.

## 🎯 Project Status: ✅ COMPLETED

Your custom Ubuntu Server AI ISO has been successfully created and is ready for deployment!

## 📁 Final Project Structure

### ✅ Essential Files
- **`manual-build.sh`** - Working ISO builder script (successfully tested)
- **`preseed.cfg`** - Automated installation configuration
- **`package-list.txt`** - Additional packages specification
- **`validate-iso.sh`** - ISO validation and testing script
- **`check-build-status.sh`** - Build status verification script

### 📦 ISO Files
- **`ubuntu-24.04.2-live-server-amd64.iso`** - Original Ubuntu Server ISO (3.0GB)
- **`ubuntu-24.04.1-server-amd64.iso`** - Backup Ubuntu Server ISO
- **`ubuntu-24.04.2-server-ai-amd64.iso`** - **YOUR CUSTOM AI SERVER ISO** (3.0GB) ✅
- **`ubuntu-24.04.2-server-ai-amd64.iso.md5`** - MD5 checksum
- **`ubuntu-24.04.2-server-ai-amd64.iso.sha256`** - SHA256 checksum

## 🚀 What's Included in Your Custom ISO

### 🤖 AI Server Features
- **Complete srv-AI-01 Configuration**: All Docker services, configs, and scripts embedded
- **Automated Installation**: Preseed configuration for unattended setup
- **AI-Optimized Partitioning**: Dedicated storage for Docker and AI data
- **GPU Ready**: NVIDIA drivers and container toolkit included
- **Security Hardened**: Firewall rules and SSH configuration
- **System Optimized**: Memory management and network tuning for AI workloads

### 🛠️ Embedded AI Services
- **Ollama**: AI model server with GPU support
- **Open WebUI**: Web interface for AI models
- **n8n**: Workflow automation platform
- **Milvus**: Vector database for RAG
- **Langfuse**: LLM observability and monitoring
- **Flowise**: Low-code AI application builder
- **PostgreSQL, Redis, MinIO**: Supporting services
- **Grafana, Prometheus**: Monitoring and metrics

## 🚀 Quick Deployment

### 1. Write ISO to USB Drive
```bash
sudo dd if=ubuntu-24.04.2-server-ai-amd64.iso of=/dev/sdX bs=4M status=progress
```
(Replace `/dev/sdX` with your USB device)

### 2. Install on Target Hardware
1. Boot from USB/DVD
2. Follow Ubuntu installation process
3. **Default Login**: `aiserver` / `changeme123` (**CHANGE IMMEDIATELY!**)

### 3. Complete AI Setup
After installation:
```bash
# Change default password immediately!
sudo passwd aiserver

# Run post-installation setup
sudo ~/ai-setup/post-install.sh

# Configure AI services
cd ~/ai-setup
cp .env.example .env
nano .env  # Edit with secure passwords
./setup.sh
./manage.sh start
```

### 4. Access AI Services
After setup completion:
- **Open WebUI**: http://server-ip:3000 (AI chat interface)
- **n8n**: http://server-ip:5678 (Workflow automation)
- **Langfuse**: http://server-ip:3001 (LLM observability)
- **Flowise**: http://server-ip:3002 (Low-code AI)
- **Grafana**: http://server-ip:3003 (Monitoring)
- **MinIO**: http://server-ip:9001 (Object storage)

## 💻 Target System Requirements

### Minimum Requirements
- **CPU**: AMD Ryzen 7 or Intel i7 (8+ cores)
- **RAM**: 32GB DDR4 (64GB+ recommended)
- **GPU**: NVIDIA RTX 3060 or better (12GB+ VRAM)
- **Storage**: 1TB NVMe SSD (2TB+ recommended)
- **Network**: Gigabit Ethernet

### Your Optimal Setup ✅
- **CPU**: AMD Ryzen 9 ✅ (Perfect)
- **RAM**: 198GB ✅ (Excellent for large models)
- **GPU**: NVIDIA RTX 3090 ✅ (24GB VRAM - Ideal)
- **Storage**: 16TB ✅ (Plenty for models and data)

## 🔧 Utility Commands

### Validate Your ISO
```bash
./validate-iso.sh
```

### Check Build Status
```bash
./check-build-status.sh
```

### Rebuild ISO (if needed)
```bash
sudo ./manual-build.sh
```

## 📋 File Checksums

**MD5**: `e073c4da025bbbaef16207715c7a8e74`  
**SHA256**: `1a02a697c0b949e382651025e8372b16f7779391a35ac2e002f47b5f0f2a019d`

## 🔒 Security & Troubleshooting

### Security Features Included
- UFW firewall with AI service ports configured
- SSH hardening and key-based authentication ready
- Container isolation for all services
- System optimizations for AI workloads

### Security Checklist
- [ ] Change default password: `sudo passwd aiserver`
- [ ] Update service passwords in `~/ai-setup/.env`
- [ ] Configure SSL certificates for production
- [ ] Review firewall rules for your network

### Common Issues & Solutions

**GPU not detected**: Verify NVIDIA GPU present and compatible
```bash
lspci | grep -i nvidia  # Check if GPU detected
sudo apt install nvidia-driver-535  # Reinstall drivers if needed
```

**Services won't start**: Check Docker and AI services
```bash
sudo systemctl status docker
cd ~/ai-setup && ./manage.sh status
./manage.sh logs <service-name>  # Check specific service logs
```

**Boot issues**: Verify ISO integrity using provided checksums

---

## 🎉 Project Complete!

Your custom Ubuntu Server AI ISO is ready for deployment on your Ryzen 9 + RTX 3090 system with 198GB RAM. This ISO includes everything needed for a complete AI infrastructure deployment.

**🚀 Happy AI Building!**

For additional support, refer to the srv-AI-01 documentation or create detailed issue reports.