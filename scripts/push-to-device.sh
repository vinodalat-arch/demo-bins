#!/usr/bin/env bash
# Push Smart Talk binaries to SA8155P device (AAOS user 10)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
PKG=com.ivi.voiceagent
DEST=/data/user/10/$PKG/files/models

# Check adb connection
if ! adb devices | grep -q "device$"; then
    echo "ERROR: No device connected. Connect via adb first."
    exit 1
fi

echo "=== Smart Talk — Device Setup ==="
echo ""

# 1. Install APK
echo "[1/6] Installing APK..."
adb install -r "$REPO_DIR/apk/app-debug.apk"

# 2. Create models directory
echo "[2/6] Creating models directory..."
adb shell "mkdir -p $DEST"

# 3. Push STT model
echo "[3/6] Pushing Whisper STT model (141M)..."
adb push "$REPO_DIR/models/stt/ggml-base.en.bin" "$DEST/"

# 4. Push TTS models
echo "[4/6] Pushing Piper TTS models (85M)..."
adb push "$REPO_DIR/models/tts/en_US-lessac-medium.onnx" "$DEST/"
adb push "$REPO_DIR/models/tts/en_US-lessac-medium.onnx.json" "$DEST/"
adb push "$REPO_DIR/models/tts/espeak-ng-data.tar.gz" "$DEST/"

# 5. Extract espeak-ng-data on device
echo "[5/6] Extracting espeak-ng-data on device..."
adb shell "cd $DEST && tar xzf espeak-ng-data.tar.gz && rm espeak-ng-data.tar.gz"

# 6. Fix ownership — adb push writes as shell user, app needs its own UID
echo "[6/6] Fixing file permissions..."
APP_UID=$(adb shell stat -c %u /data/user/10/$PKG/files)
adb shell chown -R "$APP_UID:$APP_UID" "$DEST"
adb shell chmod -R 755 "$DEST"

echo ""
echo "=== Done! Launch Smart Talk and tap the orb. ==="
