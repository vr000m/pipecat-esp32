#!/bin/bash

# ESP32 M5Stack AtomS3R Build and Flash Script
set -e

# Parse command line arguments
CLEAN_BUILD=false
if [ "$1" = "--clean" ] || [ "$1" = "-c" ]; then
    CLEAN_BUILD=true
fi

echo "🔧 ESP32 M5Stack AtomS3R Build and Flash Script"
echo "================================================"

# Show usage if help requested
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -c, --clean    Perform a full clean build (removes all build files)"
    echo "  -h, --help     Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0             # Normal incremental build"
    echo "  $0 --clean     # Clean build from scratch"
    exit 0
fi

# Change to the correct directory
cd "$(dirname "$0")"
echo "📁 Working directory: $(pwd)"

# Source environment variables
echo "🌍 Loading environment variables..."
if [ -f "../.env" ]; then
    set -a  # Automatically export all variables
    source ../.env
    set +a  # Stop auto-exporting
    echo "✅ Environment variables loaded"
    echo "   WIFI_SSID: $WIFI_SSID"
    echo "   WIFI_PASSWORD: [HIDDEN]"
    echo "   PIPECAT_SMALLWEBRTC_URL: $PIPECAT_SMALLWEBRTC_URL"
else
    echo "❌ Error: .env file not found in parent directory"
    exit 1
fi

# Source ESP-IDF environment
echo "🛠️  Setting up ESP-IDF environment..."
if [ -f "../../esp-idf/export.sh" ]; then
    source ../../esp-idf/export.sh
    echo "✅ ESP-IDF environment loaded"
else
    echo "❌ Error: ESP-IDF export.sh not found"
    echo "   Expected path: ../../esp-idf/export.sh"
    exit 1
fi

# Clean build if requested
if [ "$CLEAN_BUILD" = true ]; then
    echo "🧹 Cleaning previous build..."
    idf.py fullclean
else
    echo "🔄 Performing incremental build..."
fi

# Build the project
echo "🔨 Building project..."
idf.py build

# Flash to device
echo "⚡ Flashing to device..."
idf.py -p /dev/cu.usbmodem2101 flash

# Start monitor
echo "📺 Starting serial monitor..."
echo "   Press Ctrl+] to exit monitor"
echo ""
idf.py -p /dev/cu.usbmodem2101 monitor