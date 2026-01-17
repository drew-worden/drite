#!/bin/bash
# Drite CLI Tool Installer
# This script installs the 'drite' command to /usr/local/bin

set -e

# ANSI color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo ""
echo "╔══════════════════════════════════════╗"
echo "║   Drite CLI Tool Installer           ║"
echo "╚══════════════════════════════════════╝"
echo ""

# Check if Drite.app is installed
if [ ! -d "/Applications/Drite.app" ]; then
    echo -e "${RED}✗ Error: Drite.app not found in /Applications${NC}"
    echo ""
    echo "Please install Drite.app first:"
    echo "1. Drag Drite.app to /Applications"
    echo "2. Then run this installer again"
    echo ""
    read -p "Press Enter to exit..."
    exit 1
fi

# Check if CLI tool already exists
if [ -f "/usr/local/bin/drite" ]; then
    echo -e "${YELLOW}! The 'drite' command is already installed${NC}"
    echo ""
    read -p "Do you want to reinstall it? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
fi

# Get the CLI tool from the app bundle
CLI_SOURCE="/Applications/Drite.app/Contents/Resources/bin/drite"

if [ ! -f "$CLI_SOURCE" ]; then
    echo -e "${RED}✗ Error: CLI tool not found in Drite.app${NC}"
    echo "Expected location: $CLI_SOURCE"
    echo ""
    echo "Your Drite.app may be outdated or corrupted."
    echo "Please download the latest version from GitHub."
    echo ""
    read -p "Press Enter to exit..."
    exit 1
fi

echo "Installing 'drite' command to /usr/local/bin..."
echo ""
echo -e "${YELLOW}This requires administrator privileges.${NC}"
echo "You may be prompted for your password."
echo ""

# Install the CLI tool
sudo mkdir -p /usr/local/bin
sudo cp "$CLI_SOURCE" /usr/local/bin/drite
sudo chmod +x /usr/local/bin/drite

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ Successfully installed 'drite' command!${NC}"
    echo ""
    echo "You can now run 'drite' from any terminal:"
    echo "  $ drite"
    echo ""
    echo "To verify installation:"
    echo "  $ which drite"
    echo ""
else
    echo ""
    echo -e "${RED}✗ Installation failed${NC}"
    echo ""
    read -p "Press Enter to exit..."
    exit 1
fi

# Check if /usr/local/bin is in PATH
if [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
    echo -e "${YELLOW}⚠ Warning: /usr/local/bin is not in your PATH${NC}"
    echo ""
    echo "Add this line to your shell profile (~/.zshrc or ~/.bashrc):"
    echo "  export PATH=\"/usr/local/bin:\$PATH\""
    echo ""
fi

read -p "Press Enter to close..."
