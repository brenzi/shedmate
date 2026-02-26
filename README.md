# ShedMate

A mobile practice companion for jazz musicians. Built with Flutter and Material 3.

## Features

**Random Note Generator** — Generates random piano notes at a configurable tempo. Set a tonal range (with presets for Tenor Sax and Alto Flute), beats per note, and BPM. Toggle piano sound and metronome clicks independently.

**Metronome** — Standalone metronome with customizable beat, bar and section accents.

**Polyrhythm Trainer** — Practice polyrhythmic patterns with independent click layers.

All features use sample-accurate fluidsynth MIDI playback via SoundFont samples (Salamander piano, click, drums) with real-time parameter changes that maintain strict timing.

## Getting Started

### Prerequisites

- Flutter SDK (3.38+, Dart ^3.10.8) don't use snap!
- Android Studio with Flutter plugin
- JDK 17
- Android SDK
 
```bash
curl -LO https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.32.2-stable.tar.xz
  tar xf flutter_linux_3.32.2-stable.tar.xz

# Add to your ~/.bashrc or ~/.zshrc:
export PATH="$HOME/flutter/bin:$PATH"

flutter doctor
```

### Build & Run

```bash
flutter pub get
flutter run
```

### Development

```bash
flutter analyze
flutter test
dart format .
flutter build apk
```

## Architecture

Feature-first organization with Riverpod state management.

```
lib/
  main.dart
  src/
    app.dart
    common/          # Shared audio service, MIDI utilities, mixer, widgets
    features/
      note_generator/  # Random note generation
      metronome/       # Standalone metronome
      polyrhythms/     # Polyrhythm trainer
```

Each feature follows the pattern: `domain/` (models) → `providers/` (Riverpod state) → `services/` (logic) → `ui/` (widgets).

Audio is handled through a common `AudioService` backed by [flutter_midi_pro](https://github.com/brenzi/flutter_midi_pro) with three MIDI channels: piano, click, and drums.

## License

[GPLv3](LICENSE)
