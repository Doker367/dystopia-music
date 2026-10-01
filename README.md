# DYSTOPIA 🎵

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-3.47+-02569B?logo=flutter&logoColor=white" alt="Flutter Version" />
  <img src="https://img.shields.io/badge/Dart-3.13+-0175C2?logo=dart&logoColor=white" alt="Dart Version" />
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white" alt="Platform" />
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License" />
</div>

A modern, premium music player for Android built with Flutter, featuring a sleek dark cyberpunk aesthetic.

## ✨ Features

- **Offline music playback**: Listen to your favorite tracks anywhere.
- **Background audio & MediaSession**: Seamless playback control outside the app.
- **Lock screen controls**: Control your music without unlocking your device.
- **Download management**: Save tracks for offline listening.
- **Playlists, favorites, & history**: Organize and rediscover your music.
- **Search with provider abstraction**: Extensible search system supporting multiple music sources.
- **Dark cyberpunk UI theme**: A unique, immersive visual experience.
- **Queue management**: Full control with shuffle, repeat, and custom queues.
- **Artist and album browsing**: Easily navigate your music library.

## 📱 Screenshots

> *Screenshots coming soon!*

## 🏗️ Architecture

DYSTOPIA is built using **Clean Architecture** principles to separate concerns, improve maintainability, and ensure testability. The application is divided into three main layers:

```text
+---------------------+
| Presentation Layer  |  UI (Widgets), State Management (Riverpod), Routing
+---------+-----------+
          | (Depends on)
          v
+---------------------+
|    Domain Layer     |  Entities, Repositories (Interfaces), Usecases
+---------+-----------+
          ^ (Implements)
          |
+---------------------+
|     Data Layer      |  Data Sources (API/Hive), Repositories (Implementations)
+---------------------+
```

- **Domain**: The core business logic and entities. It contains no Flutter dependencies.
- **Data**: Responsible for data retrieval and storage (local Hive storage, network requests). It implements the interfaces defined in the domain layer.
- **Presentation**: The UI components and Riverpod providers that connect the UI to the domain layer.

## 📁 Project Structure

```text
lib/
├── core/                   # App-wide configurations, constants, theme
│   ├── theme/              # Cyberpunk dark theme definitions
│   ├── errors/             # Error handling and failure classes
│   └── utils/              # Helper functions and extensions
├── domain/                 # Business logic & interfaces
│   ├── entities/           # Core data models (Track, Playlist, etc.)
│   ├── repositories/       # Interfaces for data layer
│   └── usecases/           # Encapsulated business rules
├── data/                   # Data implementation
│   ├── models/             # DTOs and Hive models
│   ├── data_sources/       # Remote (API) and local (Hive) sources
│   └── repositories/       # Implementations of domain repositories
├── presentation/           # UI and State
│   ├── screens/            # Full-screen Flutter widgets
│   ├── widgets/            # Reusable UI components
│   ├── providers/          # Riverpod state management
│   └── router/             # GoRouter configuration
├── services/               # Background services (just_audio, audio_service)
└── main.dart               # Application entry point
```

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed:
- [Flutter 3.47+](https://flutter.dev/docs/get-started/install) (Stable)
- [Dart 3.13+](https://dart.dev/get-dart)
- Android Studio or VS Code
- Android SDK 24+

### Installation

1. Clone the repository:
   ```bash
   git clone <repo>
   cd dystopia
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Build Release APK

To build a release APK for Android:
```bash
flutter build apk --release
```

## 🔌 Adding a New MusicProvider

DYSTOPIA uses a provider abstraction to support multiple music sources. To add a new source:

1. Create a class implementing `MusicProviderInterface`.
2. Implement all required methods for searching and fetching track details.
3. Register the new provider in your dependency injection or provider setup (`app_providers.dart`).
4. Set it as the active provider in the app settings.

**Example:**
```dart
import 'package:dystopia/domain/repositories/music_provider_interface.dart';
import 'package:dystopia/domain/entities/track.dart';

class MyCustomMusicProvider implements MusicProviderInterface {
  @override
  Future<List<Track>> searchTracks(String query) async {
    // Implement API call to your music source
    return [];
  }
  
  @override
  Future<Track> getTrackDetails(String id) async {
    // Implement API call
    throw UnimplementedError();
  }
  
  // ... implement other required methods
}
```

## 📦 Dependencies

- **[just_audio](https://pub.dev/packages/just_audio)**: Feature-rich audio player.
- **[audio_service](https://pub.dev/packages/audio_service)**: Background audio support, lock screen controls.
- **[flutter_riverpod](https://pub.dev/packages/flutter_riverpod)**: Robust state management.
- **[go_router](https://pub.dev/packages/go_router)**: Declarative routing for Flutter.
- **[hive](https://pub.dev/packages/hive) & [hive_flutter](https://pub.dev/packages/hive_flutter)**: Lightweight, fast local NoSQL database.
- **[equatable](https://pub.dev/packages/equatable)**: Value equality for Dart objects.

## 🔐 Environment Variables

Create a `.env` file in the root of the project to store sensitive configuration like API keys:

```env
CUSTOM_API_KEY=your_api_key_here
```
*(Ensure `flutter_dotenv` is configured to load this on app startup)*

## 🔥 Firebase (FCM)

To enable push notifications:
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Create a new project and add an Android app with the package name matching DYSTOPIA.
3. Download the `google-services.json` file and place it in `android/app/`.
4. The necessary Firebase packages and initialization code are included in the project.

## 🛠️ Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **Design System**: Material 3 (Dark Cyberpunk Theme)
- **State Management**: Riverpod (Manual)
- **Routing**: GoRouter
- **Audio**: just_audio, audio_service
- **Storage**: Hive

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👏 Credits

Built by the **Dystopia Team**.
