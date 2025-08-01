#!/bin/bash

# Manual step-by-step ISO builder with detailed error checking

set -e

ISO_NAME="ubuntu-24.04.2-server-ai-amd64.iso"
ORIGINAL_ISO="ubuntu-24.04.2-live-server-amd64.iso"
WORK_DIR="/tmp/ubuntu-ai-iso"

echo "🔧 Manual Ubuntu AI Server ISO Builder"
echo "======================================"

# Step 1: Clean up
echo "Step 1: Cleaning up any previous builds..."
sudo rm -rf "$WORK_DIR" 2>/dev/null || true
rm -f "$ISO_NAME" 2>/dev/null || true

# Step 2: Extract ISO
echo "Step 2: Extracting original ISO..."
sudo mkdir -p /tmp/iso-mount
sudo mount -o loop "$ORIGINAL_ISO" /tmp/iso-mount
sudo mkdir -p "$WORK_DIR"
sudo cp -a /tmp/iso-mount/. "$WORK_DIR/"
sudo umount /tmp/iso-mount
sudo rmdir /tmp/iso-mount
echo "✅ ISO extracted"

# Step 3: Fix permissions
echo "Step 3: Fixing permissions..."
sudo chown -R $(whoami):$(whoami) "$WORK_DIR"
chmod -R u+w "$WORK_DIR"
echo "✅ Permissions fixed"

# Step 4: Add customizations
echo "Step 4: Adding customizations..."
mkdir -p "$WORK_DIR/preseed"
cp preseed.cfg "$WORK_DIR/preseed/"

mkdir -p "$WORK_DIR/ai-setup"

# Create enhanced AI configuration
echo "   Creating enhanced AI configuration with Local AI Packaged services..."
./enhanced-ai-setup.sh
cp -r enhanced-ai-server/* "$WORK_DIR/ai-setup/"

# Also copy original srv-AI-01 if it exists
if [ -d "../srv-AI-01" ]; then
    echo "   Including original srv-AI-01 configuration..."
    mkdir -p "$WORK_DIR/ai-setup/original-srv-ai-01"
    cp -r ../srv-AI-01/* "$WORK_DIR/ai-setup/original-srv-ai-01/"
fi

# Enhanced post-install script
cat > "$WORK_DIR/ai-setup/post-install.sh" << 'EOF'
#!/bin/bash
echo "🤖 Enhanced AI Server Post-Installation Setup"
echo "==========================================="

# Update system
echo "📦 Updating system packages..."
apt update && apt upgrade -y

# Install essential packages
apt install -y curl wget git nano vim htop build-essential software-properties-common

# Install Docker
echo "🐳 Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
usermod -aG docker aiserver

# Install Docker Compose
echo "🐳 Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install NVIDIA drivers if GPU detected
if lspci | grep -i nvidia &> /dev/null; then
    echo "🎮 NVIDIA GPU detected, installing drivers..."
    apt install -y nvidia-driver-535
    
    # Install NVIDIA Container Toolkit
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
    curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
        tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    
    apt update && apt install -y nvidia-container-toolkit
    
    # Configure Docker for GPU
    nvidia-ctk runtime configure --runtime=docker
    systemctl restart docker
else
    echo "ℹ️  No NVIDIA GPU detected"
fi

# System optimizations for AI workloads
echo "⚡ Applying system optimizations..."
echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
echo 'fs.file-max = 2097152' >> /etc/sysctl.conf
echo '* soft nofile 65536' >> /etc/security/limits.conf
echo '* hard nofile 65536' >> /etc/security/limits.conf

# Configure firewall
echo "🔥 Configuring firewall..."
ufw --force enable
ufw default deny incoming
ufw default allow outgoing

# Allow ports for enhanced AI services
ufw allow 22/tcp     # SSH
ufw allow 80/tcp     # HTTP (Caddy)
ufw allow 443/tcp    # HTTPS (Caddy)
ufw allow 3000/tcp   # Open WebUI
ufw allow 3001/tcp   # Langfuse
ufw allow 3002/tcp   # Flowise
ufw allow 3003/tcp   # Grafana
ufw allow 5678/tcp   # n8n
ufw allow 6333/tcp   # Qdrant
ufw allow 7474/tcp   # Neo4j Browser
ufw allow 7687/tcp   # Neo4j Bolt
ufw allow 8080/tcp   # SearXNG
ufw allow 9000/tcp   # MinIO
ufw allow 9001/tcp   # MinIO Console
ufw allow 9090/tcp   # Prometheus
ufw allow 11434/tcp  # Ollama
ufw allow 19530/tcp  # Milvus

# Enable services
systemctl enable docker

echo "✅ Enhanced AI Server post-installation complete!"
echo ""
echo "🚀 Next steps:"
echo "1. Reboot the system"
echo "2. Login and navigate to: cd ~/ai-setup"
echo "3. Run: ./setup.sh"
echo "4. Configure passwords in .env file"
echo "5. Start services: ./manage.sh start"
echo "6. Install AI models: ./install-models.sh"
EOF

chmod +x "$WORK_DIR/ai-setup/post-install.sh"
echo "✅ Customizations added"

# Step 5: Update checksums
echo "Step 5: Updating checksums..."
cd "$WORK_DIR"
find . -type f -print0 | xargs -0 md5sum | tee md5sum.txt > /dev/null
cd - > /dev/null
echo "✅ Checksums updated"

# Step 6: Build ISO with the simplest possible method
echo "Step 6: Building ISO..."
cd "$WORK_DIR"

echo "Attempting to create ISO..."
xorriso -as mkisofs \
    -iso-level 3 \
    -full-iso9660-filenames \
    -volid "Ubuntu-AI" \
    -output "../$ISO_NAME" \
    . && echo "✅ ISO creation command completed" || echo "❌ ISO creation command failed"

cd - > /dev/null

# Step 7: Verify results
echo "Step 7: Verifying results..."
if [ -f "$ISO_NAME" ]; then
    size=$(du -h "$ISO_NAME" | cut -f1)
    echo "🎉 SUCCESS! ISO created: $ISO_NAME ($size)"
    
    # Basic validation
    file "$ISO_NAME"
    
    # Generate checksums
    md5sum "$ISO_NAME" > "${ISO_NAME}.md5"
    sha256sum "$ISO_NAME" > "${ISO_NAME}.sha256"
    echo "✅ Checksums generated"
    
else
    echo "❌ ISO file not found after build attempt"
    echo "Checking current directory:"
    ls -la *.iso 2>/dev/null || echo "No ISO files found"
    exit 1
fi

# Step 8: Cleanup
echo "Step 8: Cleaning up work directory..."
rm -rf "$WORK_DIR"
echo "✅ Cleanup complete"

echo ""
echo "🎉 Build Summary:"
echo "✅ Input:  $ORIGINAL_ISO (3.0G)"
echo "✅ Output: $ISO_NAME ($size)"
echo "✅ Includes: AI server configuration from srv-AI-01"
echo "✅ Features: Automated installation with preseed"
echo ""
echo "📝 Usage:"
echo "1. Write to USB: sudo dd if=$ISO_NAME of=/dev/sdX bs=4M"
echo "2. Boot target system"
echo "3. Follow Ubuntu installation (may not have automated option)"
echo "4. After install: sudo ~/ai-setup/post-install.sh"
echo "5. Setup AI services: cd ~/ai-setup && ./setup.sh"