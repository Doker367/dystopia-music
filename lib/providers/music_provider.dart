import 'package:dystopia/domain/repositories/music_repository.dart';

/// Abstract interface for music providers (e.g., local files, streaming APIs).
abstract class MusicProviderInterface implements MusicRepository {
  /// User-friendly name of the provider.
  String get providerName;

  /// Unique identifier for the provider.
  String get providerId;

  /// Whether this provider supports downloading tracks for offline playback.
  bool get supportsDownload;

  /// Whether this provider supports streaming tracks.
  bool get supportsStreaming;

  /// Checks if the provider is currently available (e.g., has network connection or local permissions).
  Future<bool> isAvailable();
}
