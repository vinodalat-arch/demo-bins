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
echo "[1/8] Installing APK..."
adb install -r "$REPO_DIR/apk/app-debug.apk"

# 2. Create models directory
echo "[2/8] Creating models directory..."
adb shell "mkdir -p $DEST"

# 3. Push STT models
echo "[3/8] Pushing Whisper STT models..."
adb push "$REPO_DIR/models/stt/ggml-base.en.bin" "$DEST/"   # English (141M)
adb push "$REPO_DIR/models/stt/ggml-base.bin" "$DEST/"      # Multilingual/Japanese (141M)

# 4. Push TTS models
echo "[4/8] Pushing Piper TTS models..."
adb push "$REPO_DIR/models/tts/en_US-lessac-medium.onnx" "$DEST/"
adb push "$REPO_DIR/models/tts/en_US-lessac-medium.onnx.json" "$DEST/"
adb push "$REPO_DIR/models/tts/espeak-ng-data.tar.gz" "$DEST/"

# 5. Extract espeak-ng-data on device
echo "[5/8] Extracting espeak-ng-data on device..."
adb shell "cd $DEST && tar xzf espeak-ng-data.tar.gz && rm espeak-ng-data.tar.gz"

# 6. Push LLM model (optional — Hybrid NLU works without it)
echo "[6/8] Pushing LLM model..."
if [ -f "$REPO_DIR/models/llm/qwen2.5-0.5b-instruct-q4_k_m.gguf" ]; then
    adb push "$REPO_DIR/models/llm/qwen2.5-0.5b-instruct-q4_k_m.gguf" "$DEST/"
else
    echo "  Skipped — no LLM model found (Hybrid NLU mode still works)"
fi

# 7. Fix ownership — adb push writes as shell user, app needs its own UID
echo "[7/8] Fixing file permissions..."
APP_UID=$(adb shell stat -c %u /data/user/10/$PKG/files)
adb shell chown -R "$APP_UID:$APP_UID" "$DEST"
adb shell chmod -R 755 "$DEST"

# 8. Verify
echo "[8/8] Verifying..."
adb shell "ls -lh $DEST/"

echo ""
echo "=== Done! Launch Smart Talk and tap the orb. ==="
echo "    Hybrid NLU mode: works immediately (no LLM needed)"
echo "    LLM mode: select model in Settings (5-tap orb)"
