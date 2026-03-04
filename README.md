# Honda Smart Talk — Device Binaries

Pre-built binaries for the Honda Smart Talk voice assistant running on **Qualcomm SA8155P** (Android 14 / AAOS).

## What's Included

| File | Size | Purpose |
|------|------|---------|
| `apk/app-debug.apk` | 20M | Debug APK (arm64-v8a) |
| `models/stt/ggml-base.en.bin` | 141M | Whisper Base — English speech-to-text |
| `models/tts/en_US-lessac-medium.onnx` | 60M | Piper TTS — English voice synthesis |
| `models/tts/en_US-lessac-medium.onnx.json` | 5K | Piper TTS model config |
| `models/tts/espeak-ng-data.tar.gz` | 25M | eSpeak-NG phoneme data |

**Total: ~246M** — Everything needed for a fully working on-device voice pipeline.

## Pipeline

```
Mic → Whisper STT → Hybrid NLU (~870 regex patterns) → Action Dispatch → Piper TTS → Speaker
```

All inference runs locally. No cloud, no network required. The NLU engine uses regex patterns (no LLM model needed) and supports **62 voice actions**: 12 HVAC, 7 vehicle controls, 6 lighting, 4 doors, 3 mirrors, 4 seats, 3 display/parking, 5 media, 4 other IVI, 13 queries, 1 smart home. Bilingual: English + Japanese. Brand toggle: Honda / Konfluence.

## Quick Setup

### One-command deploy

```bash
./scripts/push-to-device.sh
```

### Manual setup

```bash
# 1. Install the APK
adb install apk/app-debug.apk

# 2. Push models (AAOS uses user 10)
DEST=/data/user/10/com.ivi.voiceagent/files/models

adb push models/stt/ggml-base.en.bin       $DEST/
adb push models/tts/en_US-lessac-medium.onnx      $DEST/
adb push models/tts/en_US-lessac-medium.onnx.json  $DEST/
adb push models/tts/espeak-ng-data.tar.gz  $DEST/

# 3. Extract espeak-ng-data on device
adb shell "cd $DEST && tar xzf espeak-ng-data.tar.gz && rm espeak-ng-data.tar.gz"
```

## Cloning (requires Git LFS)

Large files are stored with Git LFS. Make sure it's installed:

```bash
# Install Git LFS (one-time)
git lfs install

# Clone with all binary files
git clone https://github.com/vinodalat-arch/demo-bins.git
```

## Target Hardware

**Qualcomm SA8155P**: 8-core Kryo 485 (4x A76 @ 2.84GHz + 4x A55 @ 1.78GHz), 8GB LPDDR4x, Android 14 AAOS.

## Try It

After pushing to device, launch the app and tap the orb. Try:

- *"Set temperature to 22 degrees"*
- *"Play some jazz"*
- *"Navigate to Starbucks"*
- *"Turn on the AC"*
- *"Open the sunroof"*
- *"Turn on the headlights"*
- *"Fold the mirrors"*
- *"Lock all doors"*
- *"Move the seat forward"*
- *"What's the fuel level?"*
- *"What's the tire pressure?"*
- *"Call John"*
