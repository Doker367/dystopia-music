import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class LocalStreamServer {
  static HttpServer? _server;
  static int _port = 0;
  static final YoutubeExplode _yt = YoutubeExplode();

  // In-memory cache for resolved stream URLs and sizes
  static final Map<String, _CachedStreamMeta> _metaCache = {};

  static Completer<void>? _startCompleter;

  static int get port => _port;
  static bool get isRunning => _server != null;

  /// Start the local loopback HTTP streaming server
  static Future<void> start() async {
    if (_server != null) return;
    if (_startCompleter != null) return _startCompleter!.future;
    
    final completer = Completer<void>();
    _startCompleter = completer;

    try {
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      _port = _server!.port;
      debugPrint('[LocalStreamServer] Running on http://127.0.0.1:$_port');

      _server!.listen(_handleRequest, onError: (e) {
        debugPrint('[LocalStreamServer] Server error: $e');
      });
      completer.complete();
    } catch (e) {
      debugPrint('[LocalStreamServer] Failed to bind server: $e');
      completer.completeError(e);
      _startCompleter = null;
    }
  }

  /// Get the local proxy URL for a YouTube video ID
  static String getStreamUrl(String videoId) {
    if (_port == 0) {
      return 'http://127.0.0.1:8089/stream/$videoId';
    }
    return 'http://127.0.0.1:$_port/stream/$videoId';
  }

  /// Stop server
  static Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    _port = 0;
  }

  /// Clear the metadata cache so audio quality changes or expired streams refresh immediately
  static void clearMetaCache([String? videoId]) {
    if (videoId != null) {
      _metaCache.remove(videoId);
    } else {
      _metaCache.clear();
    }
  }

  /// Resolve stream metadata (direct URL and total size)
  static Future<_CachedStreamMeta?> _resolveMeta(String videoId) async {
    final cached = _metaCache[videoId];
    if (cached != null && !cached.isExpired) {
      return cached;
    }

    try {
      final manifest = await _yt.videos.streamsClient.getManifest(
        videoId,
        requireWatchPage: false,
        ytClients: [YoutubeApiClient.androidSdkless],
      );

      final StreamInfo streamInfo = manifest.muxed.firstWhereOrNull((s) => s.tag == 18) ??
          (manifest.muxed.isNotEmpty ? manifest.muxed.first : manifest.audioOnly.withHighestBitrate());

      final meta = _CachedStreamMeta(
        url: streamInfo.url.toString(),
        totalBytes: streamInfo.size.totalBytes,
        container: streamInfo.container.name,
        streamInfo: streamInfo,
        expiresAt: DateTime.now().add(const Duration(hours: 4)),
      );
      _metaCache[videoId] = meta;
      return meta;
    } catch (e) {
      debugPrint('[LocalStreamServer] Error resolving stream for $videoId: $e');
      return null;
    }
  }

  /// Handle incoming HTTP request from ExoPlayer / just_audio
  static Future<void> _handleRequest(HttpRequest request) async {
    final pathSegments = request.uri.pathSegments;
    if (pathSegments.isEmpty || pathSegments.first != 'stream') {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }

    final videoId = pathSegments.length > 1 ? pathSegments[1] : '';
    if (videoId.isEmpty) {
      request.response.statusCode = HttpStatus.badRequest;
      await request.response.close();
      return;
    }

    // 1. Check if we already have the fully downloaded or cached file
    File? cachedFile = await _getCachedFile(videoId);
    if (cachedFile != null && await cachedFile.exists() && await cachedFile.length() > 100000) {
      await _serveLocalFile(request, cachedFile);
      return;
    }

    // 2. Resolve YouTube stream metadata
    var meta = await _resolveMeta(videoId);
    if (meta == null) {
      request.response.statusCode = HttpStatus.serviceUnavailable;
      await request.response.close();
      return;
    }

    final totalSize = meta.totalBytes;
    final rangeHeader = request.headers.value(HttpHeaders.rangeHeader);

    int start = 0;
    int end = totalSize - 1;
    bool isRange = false;

    if (rangeHeader != null && rangeHeader.startsWith('bytes=')) {
      isRange = true;
      final parts = rangeHeader.substring(6).split('-');
      if (parts[0].isNotEmpty) {
        start = int.tryParse(parts[0]) ?? 0;
      }
      if (parts.length > 1 && parts[1].isNotEmpty) {
        end = int.tryParse(parts[1]) ?? (totalSize - 1);
      }
    }

    if (start >= totalSize || end >= totalSize || start > end) {
      request.response.statusCode = HttpStatus.requestedRangeNotSatisfiable;
      request.response.headers.set(HttpHeaders.contentRangeHeader, 'bytes */$totalSize');
      await request.response.close();
      return;
    }

    final contentLength = end - start + 1;

    try {
      if (isRange) {
        request.response.statusCode = HttpStatus.partialContent;
        request.response.headers.set(HttpHeaders.contentRangeHeader, 'bytes $start-$end/$totalSize');
      } else {
        request.response.statusCode = HttpStatus.ok;
      }

      request.response.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');
      request.response.headers.set(HttpHeaders.contentTypeHeader, 'video/mp4');
      request.response.headers.contentLength = contentLength;
      request.response.headers.set('Cache-Control', 'no-cache');

      // If ExoPlayer sent a HEAD request
      if (request.method == 'HEAD') {
        await request.response.close();
        return;
      }

      final client = HttpClient();
      final req = await client.getUrl(Uri.parse(meta.url));
      req.headers.set('User-Agent', 'com.google.android.youtube/20.10.38 (Linux; U; Android 11) gzip');
      if (isRange) {
        req.headers.set('Range', 'bytes=$start-$end');
      }
      final resp = await req.close();

      final tempDir = await getTemporaryDirectory();
      final cacheFile = File('${tempDir.path}/dystopia_cache_$videoId.mp4');
      final partFile = File('${tempDir.path}/dystopia_cache_$videoId.mp4.part');
      IOSink? diskSink;
      if (start == 0) {
        try {
          diskSink = partFile.openWrite();
        } catch (_) {}
      }

      try {
        await for (final chunk in resp) {
          request.response.add(chunk);
          diskSink?.add(chunk);
        }
      } catch (e) {
        debugPrint('[LocalStreamServer] Stream chunk transfer: $e');
      } finally {
        client.close();
        if (diskSink != null) {
          try {
            await diskSink.flush();
            await diskSink.close();
            if (await partFile.exists() && await partFile.length() > 500000) {
              if (await cacheFile.exists()) await cacheFile.delete();
              await partFile.rename(cacheFile.path);
              debugPrint('[LocalStreamServer] Cached track $videoId on disk (${await cacheFile.length()} bytes)');
            }
          } catch (_) {}
        }
        try {
          await request.response.close();
        } catch (_) {}
      }
    } catch (e) {
      try {
        await request.response.close();
      } catch (_) {}
    }
  }

  /// Serve local file with HTTP Range support
  static Future<void> _serveLocalFile(HttpRequest request, File file) async {
    final totalSize = await file.length();
    final rangeHeader = request.headers.value(HttpHeaders.rangeHeader);

    int start = 0;
    int end = totalSize - 1;
    bool isRange = false;

    if (rangeHeader != null && rangeHeader.startsWith('bytes=')) {
      isRange = true;
      final parts = rangeHeader.substring(6).split('-');
      if (parts[0].isNotEmpty) {
        start = int.tryParse(parts[0]) ?? 0;
      }
      if (parts.length > 1 && parts[1].isNotEmpty) {
        end = int.tryParse(parts[1]) ?? (totalSize - 1);
      }
    }

    final contentLength = end - start + 1;
    if (isRange) {
      request.response.statusCode = HttpStatus.partialContent;
      request.response.headers.set(HttpHeaders.contentRangeHeader, 'bytes $start-$end/$totalSize');
    } else {
      request.response.statusCode = HttpStatus.ok;
    }

    request.response.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');
    request.response.headers.set(HttpHeaders.contentTypeHeader, 'audio/mp4');
    request.response.headers.contentLength = contentLength;

    if (request.method == 'HEAD') {
      await request.response.close();
      return;
    }

    final raf = await file.open(mode: FileMode.read);
    await raf.setPosition(start);
    int remaining = contentLength;
    const bufferSize = 64 * 1024;

    try {
      while (remaining > 0) {
        final toRead = min(bufferSize, remaining);
        final bytes = await raf.read(toRead);
        if (bytes.isEmpty) break;
        request.response.add(bytes);
        await request.response.flush();
        remaining -= bytes.length;
      }
    } catch (_) {
      // Client disconnected
    } finally {
      await raf.close();
      try {
        await request.response.close();
      } catch (_) {}
    }
  }

  static Future<File?> _getCachedFile(String videoId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      // Check persistent music download
      final persistentMp4 = File('${appDir.path}/Dystopia/Music/$videoId.mp4');
      if (persistentMp4.existsSync() && persistentMp4.lengthSync() > 100000) return persistentMp4;

      final persistentM4a = File('${appDir.path}/Dystopia/Music/$videoId.m4a');
      if (persistentM4a.existsSync() && persistentM4a.lengthSync() > 100000) return persistentM4a;

      final persistentMp3 = File('${appDir.path}/Dystopia/Music/$videoId.mp3');
      if (persistentMp3.existsSync() && persistentMp3.lengthSync() > 100000) return persistentMp3;

      // Check temporary cache
      final tempDir = await getTemporaryDirectory();
      final cachedMp4 = File('${tempDir.path}/dystopia_cache_$videoId.mp4');
      if (cachedMp4.existsSync() && cachedMp4.lengthSync() > 100000) return cachedMp4;

      final cachedM4a = File('${tempDir.path}/dystopia_cache_$videoId.m4a');
      if (cachedM4a.existsSync() && cachedM4a.lengthSync() > 100000) return cachedM4a;
    } catch (_) {}
    return null;
  }
}

class _CachedStreamMeta {
  final String url;
  final int totalBytes;
  final String container;
  final StreamInfo streamInfo;
  final DateTime expiresAt;

  _CachedStreamMeta({
    required this.url,
    required this.totalBytes,
    required this.container,
    required this.streamInfo,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

