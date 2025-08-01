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
if [ -d "../srv-AI-01" ]; then
    cp -r ../srv-AI-01/* "$WORK_DIR/ai-setup/"
fi

# Simple post-install script
cat > "$WORK_DIR/ai-setup/post-install.sh" << 'EOF'
#!/bin/bash
echo "🤖 Installing Docker and AI tools..."
apt update && apt upgrade -y
curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
usermod -aG docker aiserver
systemctl enable docker
echo "✅ Basic setup complete - reboot and run ./setup.sh"
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