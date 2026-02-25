#!/usr/bin/env bash
# Push Honda Smart Talk binaries to SA8155P device (AAOS user 10)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
DEST=/data/user/10/com.ivi.voiceagent/files/models

# Check adb connection
if ! adb devices | grep -q "device$"; then
    echo "ERROR: No device connected. Connect via adb first."
    exit 1
fi

echo "=== Honda Smart Talk — Device Setup ==="
echo ""

# 1. Install APK
echo "[1/5] Installing APK..."
adb install -r "$REPO_DIR/apk/app-debug.apk"

# 2. Create models directory
echo "[2/5] Creating models directory..."
adb shell "mkdir -p $DEST"

# 3. Push STT model
echo "[3/5] Pushing Whisper STT model (141M)..."
adb push "$REPO_DIR/models/stt/ggml-base.en.bin" "$DEST/"

# 4. Push TTS models
echo "[4/5] Pushing Piper TTS models (85M)..."
adb push "$REPO_DIR/models/tts/en_US-lessac-medium.onnx" "$DEST/"
adb push "$REPO_DIR/models/tts/en_US-lessac-medium.onnx.json" "$DEST/"
adb push "$REPO_DIR/models/tts/espeak-ng-data.tar.gz" "$DEST/"

# 5. Extract espeak-ng-data on device
echo "[5/5] Extracting espeak-ng-data on device..."
adb shell "cd $DEST && tar xzf espeak-ng-data.tar.gz && rm espeak-ng-data.tar.gz"

echo ""
echo "=== Done! Launch Honda Smart Talk and tap the orb. ==="
