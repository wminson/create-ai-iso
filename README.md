# Custom Ubuntu Server ISO for AI Infrastructure

This directory contains the complete custom Ubuntu Server ISO with embedded AI infrastructure configuration from `srv-AI-01`.

## 🎯 Project Status: ✅ COMPLETED

Your custom Ubuntu Server AI ISO has been successfully created and is ready for deployment!

## 📁 Clean Project Structure

### 🔧 Build Scripts
- **`manual-build.sh`** - ISO builder script (tested and working)
- **`enhanced-ai-setup.sh`** - AI configuration generator
- **`preseed.cfg`** - Automated installation configuration
- **`package-list.txt`** - Additional packages specification

### 📦 ISO Files  
- **`ubuntu-24.04.2-live-server-amd64.iso`** - Original Ubuntu Server ISO (3.1GB)
- **`ubuntu-24.04.2-server-ai-amd64.iso`** - **YOUR CUSTOM AI SERVER ISO** (3.1GB) ✅
- **`ubuntu-24.04.2-server-ai-amd64.iso.md5`** - MD5 checksum
- **`ubuntu-24.04.2-server-ai-amd64.iso.sha256`** - SHA256 checksum

### 📚 Documentation
- **`README.md`** - Project overview and quick start
- **`HOW-TO-USE.md`** - Complete installation and usage guide

## 🚀 What's Included in Your Custom ISO

### 🤖 AI Server Features
- **Complete srv-AI-01 Configuration**: All Docker services, configs, and scripts embedded
- **Automated Installation**: Preseed configuration for unattended setup
- **AI-Optimized Partitioning**: Dedicated storage for Docker and AI data
- **GPU Ready**: NVIDIA drivers and container toolkit included
- **Security Hardened**: Firewall rules and SSH configuration
- **System Optimized**: Memory management and network tuning for AI workloads

### 🛠️ Embedded AI Services (Enhanced Configuration)

#### Original srv-AI-01 Services:
- **Ollama**: AI model server with GPU support
- **Open WebUI**: Web interface for AI models  
- **n8n**: Workflow automation platform
- **Milvus**: Vector database for RAG
- **Langfuse**: LLM observability and monitoring
- **Flowise**: Low-code AI application builder
- **PostgreSQL, Redis, MinIO**: Supporting services
- **Grafana, Prometheus**: Monitoring and metrics

#### Additional Services from Local AI Packaged:
- **Qdrant**: High-performance vector database (alternative to Milvus)
- **Neo4j**: Knowledge graph engine for GraphRAG, LightRAG
- **SearXNG**: Privacy-focused metasearch engine (229 search services)
- **Caddy**: Automatic HTTPS reverse proxy with SSL
- **Enhanced n8n**: 400+ integrations and advanced AI components
- **Enhanced Flowise**: Better integration with other services
- **Supabase**: Open-source database and authentication (optional)

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

# Interactive AI services configuration (NEW!)
cd ~/ai-setup
./setup.sh  # 🎯 Interactive wizard with auto-generated passwords!
./manage.sh start
```

**🆕 Interactive Setup Features**:
- **Auto-generates secure passwords** for all services  
- **GPU optimization** for RTX 3090 + 198GB RAM
- **Simple guided prompts** for configuration
- **No manual .env editing required!**

### 4. Access AI Services
After setup completion:

#### Core AI Services:
- **Open WebUI**: http://server-ip:3000 (AI chat interface)
- **n8n**: http://server-ip:5678 (Workflow automation with 400+ integrations)
- **Langfuse**: http://server-ip:3001 (LLM observability)
- **Flowise**: http://server-ip:3002 (Low-code AI)
- **Grafana**: http://server-ip:3003 (Monitoring)
- **MinIO**: http://server-ip:9001 (Object storage)

#### Additional Enhanced Services:
- **Neo4j Browser**: http://server-ip:7474 (Knowledge graph)
- **Qdrant Dashboard**: http://server-ip:6333/dashboard (Vector DB)
- **SearXNG**: http://server-ip:8080 (Private search)
- **Prometheus**: http://server-ip:9090 (Metrics)
- **Caddy**: http://server-ip (Reverse proxy dashboard)

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

**MD5**: `750a8f699aa002c533c86e5cc3c5368d`  
**SHA256**: `7109d22691476dcb192688f819d5d98bddfbb92a8d47245c323c4a15f2631428`

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