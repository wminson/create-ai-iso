# Manual Build Script Guide

## 📋 Overview

The `manual-build.sh` script creates a custom Ubuntu Server ISO with embedded AI infrastructure configuration. This guide explains how to use it effectively.

## 🎯 What It Does

The script performs these operations:
1. **Extracts** the original Ubuntu Server ISO
2. **Customizes** with AI server configuration
3. **Embeds** interactive setup scripts and Docker services
4. **Builds** a new bootable ISO file
5. **Generates** checksums for verification

## 📁 Prerequisites

### Required Files
- `ubuntu-24.04.2-live-server-amd64.iso` - Source Ubuntu ISO
- `enhanced-ai-setup.sh` - AI configuration generator
- `preseed.cfg` - Automated installation configuration
- `package-list.txt` - Additional packages list

### System Requirements
- **OS**: Ubuntu/Debian Linux
- **Storage**: 10GB+ free space
- **RAM**: 4GB+ available
- **Packages**: `xorriso`, `mount`, `sudo access`

### Install Dependencies
```bash
sudo apt update
sudo apt install xorriso genisoimage curl wget
```

## 🚀 Basic Usage

### Simple Build
```bash
# Make executable
chmod +x manual-build.sh

# Run the build
sudo ./manual-build.sh
```

### Build Process Output
```
🔧 Manual Ubuntu AI Server ISO Builder
======================================
Step 1: Cleaning up any previous builds...
Step 2: Extracting original ISO...
✅ ISO extracted
Step 3: Fixing permissions...
✅ Permissions fixed
Step 4: Adding customizations...
   Creating enhanced AI configuration...
✅ Customizations added
Step 5: Updating checksums...
✅ Checksums updated
Step 6: Building ISO...
✅ ISO creation command completed
Step 7: Verifying results...
🎉 SUCCESS! ISO created: ubuntu-24.04.2-server-ai-amd64.iso (3.1GB)
✅ Checksums generated
Step 8: Cleaning up work directory...
✅ Cleanup complete
```

## 🔧 Advanced Usage

### Environment Variables
```bash
# Custom ISO name
ISO_NAME="my-custom-ai-server.iso" sudo ./manual-build.sh

# Custom work directory
WORK_DIR="/tmp/my-build" sudo ./manual-build.sh

# Use different source ISO
ORIGINAL_ISO="ubuntu-24.04.1-live-server-amd64.iso" sudo ./manual-build.sh
```

### Manual Customization
Before running the script, you can modify:

**AI Configuration**:
```bash
# Edit the AI setup generator
nano enhanced-ai-setup.sh
```

**Installation Settings**:
```bash
# Modify automated installation
nano preseed.cfg
```

**Additional Packages**:
```bash
# Add/remove packages
nano package-list.txt
```

## 📊 Build Process Details

### Step-by-Step Breakdown

**Step 1: Cleanup**
- Removes previous build artifacts
- Clears work directories
- Ensures clean build environment

**Step 2: ISO Extraction**
- Mounts source Ubuntu ISO as read-only
- Copies all contents to work directory
- Unmounts source ISO

**Step 3: Permissions**
- Changes ownership to current user
- Makes files writable for customization
- Prepares for modifications

**Step 4: Customizations**
- Runs `enhanced-ai-setup.sh` to generate AI configuration
- Copies AI setup scripts to `/ai-setup/` directory
- Adds preseed configuration for automated installation
- Creates post-installation script

**Step 5: Checksums**
- Updates internal ISO checksums
- Ensures file integrity

**Step 6: ISO Building**
- Uses `xorriso` to create bootable ISO
- Maintains Ubuntu compatibility
- Creates UEFI-bootable image

**Step 7: Verification**
- Confirms ISO creation success
- Generates MD5 and SHA256 checksums
- Reports final file size

**Step 8: Cleanup**
- Removes temporary work directory
- Leaves only final ISO and checksums

## 🛠️ Customization Options

### AI Services Configuration
The script automatically includes these services:
- **Ollama** - AI model server
- **Open WebUI** - AI chat interface
- **n8n** - Workflow automation
- **Flowise** - Low-code AI builder
- **Milvus** - Vector database
- **Qdrant** - Alternative vector database
- **Neo4j** - Graph database
- **Langfuse** - AI observability
- **Grafana/Prometheus** - Monitoring
- **MinIO** - Object storage
- **SearXNG** - Private search
- **Caddy** - Reverse proxy

### Hardware Optimization
Automatically optimized for:
- **GPU**: NVIDIA RTX series support
- **RAM**: 32GB+ memory configurations
- **Storage**: NVMe SSD optimizations
- **Network**: Gigabit Ethernet tuning

## 🔍 Troubleshooting

### Common Issues

**Permission Denied**
```bash
# Solution: Run with sudo
sudo ./manual-build.sh
```

**ISO Not Found**
```bash
# Check source ISO exists
ls -la ubuntu-24.04.2-live-server-amd64.iso

# Download if missing
wget https://releases.ubuntu.com/24.04.2/ubuntu-24.04.2-live-server-amd64.iso
```

**Insufficient Space**
```bash
# Check available space (need 10GB+)
df -h .

# Clean up if needed
sudo apt autoremove && sudo apt clean
```

**Mount Errors**
```bash
# Check if ISO is already mounted
mount | grep iso

# Unmount if needed
sudo umount /tmp/iso-mount
```

**Build Failures**
```bash
# Check for required tools
which xorriso
which genisoimage

# Install if missing
sudo apt install xorriso genisoimage
```

### Debug Mode
```bash
# Run with verbose output
bash -x ./manual-build.sh
```

### Manual Cleanup
```bash
# If build fails, clean up manually
sudo rm -rf /tmp/ubuntu-ai-iso
sudo umount /tmp/iso-mount 2>/dev/null || true
sudo rmdir /tmp/iso-mount 2>/dev/null || true
```

## 📋 Verification

### Check ISO Integrity
```bash
# Verify checksums
md5sum -c ubuntu-24.04.2-server-ai-amd64.iso.md5
sha256sum -c ubuntu-24.04.2-server-ai-amd64.iso.sha256
```

### Test ISO File
```bash
# Check file type
file ubuntu-24.04.2-server-ai-amd64.iso

# Should output: ISO 9660 CD-ROM filesystem data
```

### Verify Bootability
```bash
# Test with QEMU (if installed)
qemu-system-x86_64 -cdrom ubuntu-24.04.2-server-ai-amd64.iso -m 4096 -boot d
```

## ⚙️ Performance Tips

### Faster Builds
```bash
# Use RAM disk for work directory (if you have 16GB+ RAM)
sudo mkdir /tmp/ramdisk
sudo mount -t tmpfs -o size=8G tmpfs /tmp/ramdisk
WORK_DIR="/tmp/ramdisk/build" sudo ./manual-build.sh
```

### Parallel Processing
The script automatically uses available CPU cores for:
- File copying operations
- Compression tasks
- Checksum generation

### SSD Optimization
```bash
# For SSD systems, enable TRIM
sudo fstrim -av
```

## 🔄 Rebuilding

### Clean Rebuild
```bash
# Remove previous ISO
rm -f ubuntu-24.04.2-server-ai-amd64.iso*

# Run fresh build
sudo ./manual-build.sh
```

### Incremental Changes
```bash
# Modify configuration
nano enhanced-ai-setup.sh

# Rebuild with changes
sudo ./manual-build.sh
```

## 📁 Output Files

After successful build:
```
ubuntu-24.04.2-server-ai-amd64.iso        # Custom AI Server ISO (3.1GB)
ubuntu-24.04.2-server-ai-amd64.iso.md5    # MD5 checksum
ubuntu-24.04.2-server-ai-amd64.iso.sha256 # SHA256 checksum
```

## 🎯 Next Steps

After building the ISO:

1. **Verify** integrity with checksums
2. **Write** to USB drive or DVD
3. **Boot** target system
4. **Follow** installation prompts
5. **Run** `~/ai-setup/setup.sh` after installation

## 📞 Support

### Log Files
Build logs are displayed in real-time. For issues:
1. Copy the error output
2. Check file permissions
3. Verify available disk space
4. Ensure all prerequisites are met

### Common Solutions
- **Permission issues**: Run with `sudo`
- **Space issues**: Free up 10GB+ disk space
- **Tool issues**: Install missing dependencies
- **Source issues**: Verify Ubuntu ISO integrity

---

**Your custom AI server ISO builder is ready to use!** 🚀