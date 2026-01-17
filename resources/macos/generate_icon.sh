#!/bin/bash
# Generate macOS app icon from a source PNG
# Usage: ./generate_icon.sh input.png

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input.png>"
    echo "Input image should be at least 1024x1024 pixels"
    exit 1
fi

INPUT="$1"
ICONSET="icon.iconset"

if [ ! -f "$INPUT" ]; then
    echo "Error: Input file '$INPUT' not found"
    exit 1
fi

echo "Generating icon from $INPUT..."

# Create iconset directory
mkdir -p "$ICONSET"

# Generate all required sizes
sips -z 16 16     "$INPUT" --out "$ICONSET/icon_16x16.png"
sips -z 32 32     "$INPUT" --out "$ICONSET/icon_16x16@2x.png"
sips -z 32 32     "$INPUT" --out "$ICONSET/icon_32x32.png"
sips -z 64 64     "$INPUT" --out "$ICONSET/icon_32x32@2x.png"
sips -z 128 128   "$INPUT" --out "$ICONSET/icon_128x128.png"
sips -z 256 256   "$INPUT" --out "$ICONSET/icon_128x128@2x.png"
sips -z 256 256   "$INPUT" --out "$ICONSET/icon_256x256.png"
sips -z 512 512   "$INPUT" --out "$ICONSET/icon_256x256@2x.png"
sips -z 512 512   "$INPUT" --out "$ICONSET/icon_512x512.png"
sips -z 1024 1024 "$INPUT" --out "$ICONSET/icon_512x512@2x.png"

# Convert to icns
iconutil -c icns "$ICONSET" -o AppIcon.icns

echo "Icon generated: AppIcon.icns"
echo "Cleaning up..."
rm -rf "$ICONSET"

echo "Done!"
