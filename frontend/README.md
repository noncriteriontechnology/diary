# Lawyer's Diary Flutter App

## Quick Start Guide

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run the App
```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter devices  # List available devices
flutter run -d <device-id>

# Run on Chrome (web)
flutter run -d chrome
```

### 3. Build for Production
```bash
# Android APK
flutter build apk

# Android App Bundle
flutter build appbundle

# iOS (requires macOS and Xcode)
flutter build ios
```

## Development Setup

### Prerequisites
- Flutter SDK installed and added to PATH
- Android Studio or VS Code with Flutter extension
- Android SDK for Android development
- Xcode for iOS development (macOS only)

### Check Flutter Installation
```bash
flutter doctor
```

This command will show you what's missing and needs to be installed.

### Device Setup

**Android:**
- Enable Developer Options on your Android device
- Enable USB Debugging
- Connect via USB or use Android Emulator

**iOS (macOS only):**
- Connect iPhone/iPad via USB
- Trust the computer on your device
- Or use iOS Simulator

**Web:**
- Any modern web browser
- Run with: `flutter run -d chrome`

## Project Structure

```
lib/
├── main.dart           # App entry point
├── models/            # Data models
├── services/          # API services
├── providers/         # State management
├── screens/           # UI screens
├── widgets/           # Reusable widgets
└── utils/            # Utilities and themes
```

## Features

- ✅ User Authentication
- ✅ Client Management
- ✅ Appointment Scheduling
- ✅ Notes with Voice Recording
- ✅ Material Design 3 UI
- ✅ Cross-platform (Android, iOS, Web)

## API Configuration

Update the API base URL in `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'http://localhost:5000/api';
```

For Android emulator, use:
```dart
static const String baseUrl = 'http://10.0.2.2:5000/api';
```

## Troubleshooting

**Common Issues:**

1. **Flutter not recognized:**
   - Make sure Flutter is added to your PATH
   - Restart your terminal/command prompt

2. **No devices found:**
   - Enable USB debugging on Android
   - Start an emulator
   - For web: `flutter run -d chrome`

3. **Build errors:**
   - Run `flutter clean`
   - Run `flutter pub get`
   - Check `flutter doctor` for issues

4. **API connection issues:**
   - Make sure backend server is running
   - Check the API base URL configuration
   - For Android emulator, use `10.0.2.2` instead of `localhost`
