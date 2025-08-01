#!/bin/bash

# Script to check if the ISO build was successful

echo "🔍 Checking ISO Build Status"
echo "============================"

ISO_FILE="ubuntu-24.04.2-server-ai-amd64.iso"
ORIGINAL_ISO="ubuntu-24.04.2-live-server-amd64.iso"

# Check if original ISO exists
if [ -f "$ORIGINAL_ISO" ]; then
    original_size=$(du -h "$ORIGINAL_ISO" | cut -f1)
    echo "✅ Original ISO: $ORIGINAL_ISO ($original_size)"
else
    echo "❌ Original ISO not found: $ORIGINAL_ISO"
fi

# Check if custom ISO was created
if [ -f "$ISO_FILE" ]; then
    custom_size=$(du -h "$ISO_FILE" | cut -f1)
    custom_date=$(date -r "$ISO_FILE" "+%Y-%m-%d %H:%M:%S")
    echo "✅ Custom ISO: $ISO_FILE ($custom_size)"
    echo "   Created: $custom_date"
    
    # Basic ISO validation
    if file "$ISO_FILE" | grep -q "ISO 9660"; then
        echo "✅ Valid ISO 9660 format"
    else
        echo "❌ Invalid ISO format"
    fi
    
    # Check if ISO is bootable
    if xorriso -indev "$ISO_FILE" -report_el_torito as_mkisofs 2>/dev/null | grep -q "El Torito"; then
        echo "✅ ISO is bootable"
    else
        echo "⚠️  Bootability unclear"
    fi
    
    # Generate checksums
    echo ""
    echo "📋 Generating checksums..."
    md5sum "$ISO_FILE" > "${ISO_FILE}.md5"
    sha256sum "$ISO_FILE" > "${ISO_FILE}.sha256"
    echo "✅ Checksums saved:"
    echo "   MD5: $(cat ${ISO_FILE}.md5)"
    echo "   SHA256: $(cat ${ISO_FILE}.sha256)"
    
else
    echo "❌ Custom ISO not found: $ISO_FILE"
    echo ""
    echo "📝 To build the ISO, run one of these commands:"
    echo "   sudo ./build-robust.sh"
    echo "   sudo ./build-ai-iso.sh"
    echo "   sudo ./build-ai-iso-noninteractive.sh"
    exit 1
fi

# Check for other generated files
echo ""
echo "📁 Other generated files:"
for file in "AI-Server-Installation-Guide.md" "VM-Test-Config.md"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file (not created)"
    fi
done

# Check work directory cleanup
if [ -d "/tmp/ubuntu-ai-iso" ]; then
    echo "⚠️  Work directory still exists: /tmp/ubuntu-ai-iso"
    echo "   You may want to clean it up: sudo rm -rf /tmp/ubuntu-ai-iso"
else
    echo "✅ Work directory cleaned up"
fi

echo ""
echo "🎉 ISO Build Status Summary:"
if [ -f "$ISO_FILE" ]; then
    echo "   Status: ✅ SUCCESS"
    echo "   Output: $ISO_FILE ($custom_size)"
    echo ""
    echo "📝 Next steps:"
    echo "   1. Run './validate-iso.sh' for detailed validation"
    echo "   2. Write ISO to USB or use in VM"
    echo "   3. Test installation"
else
    echo "   Status: ❌ FAILED"
    echo "   The ISO was not created successfully"
fi