# ESP32 Pipecat Client SDK - Development Guide

This file provides essential information for AI assistants working with the ESP32 Pipecat codebase.

## Overview

ESP32 client SDK for connecting to Pipecat bots via WebRTC. Supports real-time voice interaction using the RTVI protocol on ESP32-S3 hardware and Linux.

## Environment Setup

Required environment variables:
```bash
export WIFI_SSID=your_wifi_name
export WIFI_PASSWORD=your_wifi_password
export PIPECAT_SMALLWEBRTC_URL=http://192.168.1.10:7860/api/offer
```

## Common Commands

### Build Commands
```bash
# Load ESP-IDF tools (run from terminal)
source PATH_TO_ESP_IDF/export.sh

# Set target (esp32s3 or linux)
idf.py --preview set-target esp32s3

# Build the project
idf.py build

# Run on Linux (after building for linux target)
./build/src.elf
```

### Flash Commands
```bash
# Linux
idf.py -p /dev/ttyACM0 flash

# macOS
idf.py flash
```

### Monitor Serial Output
```bash
idf.py -p /dev/ttyACM0 monitor
```

## Project Structure

Three device implementations sharing common architecture:
- `esp32-s3-box-3/` - ESP32-S3-BOX-3 with touchscreen UI
- `esp32-m5stack-atoms3r/` - M5Stack AtomS3R device
- `esp32-m5stack-cores3/` - M5Stack CoreS3 device

Each device directory contains:
- `CMakeLists.txt` - Build configuration
- `sdkconfig.defaults` - ESP-IDF settings
- `src/` - Device-specific implementation
- `components/` - Shared components (srtp, peer, esp-libopus)

## Architecture

### Key Components
1. **WebRTC Stack** (`components/peer/`) - Handles WebRTC peer connections
2. **SRTP** (`components/srtp/`) - Secure RTP implementation
3. **Audio Pipeline** - Capture → Encode (Opus) → RTP → SRTP → Network
4. **RTVI Protocol** - Real-time voice interface for bot communication
5. **UI Layer** (ESP32-S3-BOX-3 only) - LVGL-based touchscreen interface

### Main Entry Points
- `src/main.c` - Application initialization
- `src/main.h` - Central API definitions
- `src/wifi.c` - WiFi connection management
- `src/webrtc.c` - WebRTC signaling and media handling
- `src/rtvi.c` - RTVI protocol implementation
- `src/audio_*.c` - Audio capture/encode/decode modules

### RTVI Callbacks
The SDK implements these callbacks for bot interaction:
- `on_bot_started_speaking()` - Bot begins audio output
- `on_bot_stopped_speaking()` - Bot stops audio output
- `on_bot_tts_text(const char *text)` - Bot's spoken text

## Important Configuration

### sdkconfig.defaults
- TLS verification disabled (needs production fix)
- DTLS-SRTP enabled for secure media
- Large stack size (16KB) for libpeer
- CPU frequency set to 240MHz
- Compiler optimizations enabled

### Build Requirements
- ESP-IDF v5.4.2 (esp32-s3-box-3 requires this specific version)
- esp-box-3 component v3.0.0 (for ESP32-S3-BOX-3)
- Recursive clone required for submodules

## Testing with Pipecat

Run a Pipecat bot with ESP32 support:
```bash
python examples/foundational/07-interruptible.py --host YOUR_IP --esp32
```

Then set `PIPECAT_SMALLWEBRTC_URL` to `http://YOUR_IP:7860/api/offer`

## Common Issues

1. **Build fails with missing environment variables**: Ensure WIFI_SSID, WIFI_PASSWORD, and PIPECAT_SMALLWEBRTC_URL are exported
2. **Flash permission denied**: Add user to dialout group on Linux: `sudo usermod -a -G dialout $USER`
3. **Audio issues**: Check I2S pin configuration in device-specific audio_capture.c
4. **WebRTC connection fails**: Verify network connectivity and bot URL accessibility

## Development Notes

- The codebase uses ESP-IDF's CMake build system
- Linux builds use stub components for testing without hardware
- Audio uses 16kHz sampling rate with Opus codec
- WebRTC implementation is lightweight, optimized for embedded systems
- UI code (ESP32-S3-BOX-3) uses LVGL for graphics