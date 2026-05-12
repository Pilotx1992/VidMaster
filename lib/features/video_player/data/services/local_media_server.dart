// lib/features/video_player/data/services/local_media_server.dart
//
// Phase 6.2 — Local HTTP media server foundation for Chromecast casting.
//
// WHY THIS EXISTS
// ───────────────
// Chromecast cannot read files from the phone's filesystem directly. The
// receiver needs an HTTP URL that's reachable over the LAN. This service is
// the bridge: it serves registered local files over HTTP with proper Range
// support so the Cast receiver can seek aggressively.
//
// NOT YET INCLUDED (intentionally — comes in later sub-phases):
//   • Subtitle serving (Phase 6.8).
//   • Thumbnail serving (later).
//   • Cast session / device picker (Phase 6.4).
//   • Music cast refactor (Phase 6.9).
//
// MANUAL TEST PROCEDURE
// ─────────────────────
// 1. Make sure the test device is on the same Wi-Fi as your dev machine.
// 2. From anywhere in the app (e.g. a debug button), do:
//       final server = LocalMediaServer();
//       await server.start();
//       final ticket = await server.register('/storage/.../some_video.mp4');
//       debugPrint(ticket.url);   // → http://192.168.x.y:PORT/v/<token>
// 3. On the dev laptop (same Wi-Fi), exercise the URL:
//
//       curl -I http://192.168.x.y:PORT/v/<token>
//
//    Expect:  HTTP/1.1 200 OK
//             Content-Type: video/mp4
//             Content-Length: ......
//             Accept-Ranges: bytes
//
// 4. Range probe (mimics what Chromecast does when seeking):
//
//       curl -i -H "Range: bytes=1048576-2097151" http://.../v/<token> -o /dev/null
//
//    Expect:  HTTP/1.1 206 Partial Content
//             Content-Range: bytes 1048576-2097151/<total>
//             Content-Length: 1048576
//
// 5. Open the same URL in VLC ("Open Network Stream") — the file should
//    stream and seek smoothly.
//
// 6. Token expiry sanity check:
//       await server.register(path, ttl: Duration(seconds: 5));
//       // wait 6 s …
//       curl -I http://.../v/<token>     // → 404 Token expired
//
// 7. Shutdown: `await server.stop();` — subsequent requests fail at the TCP
//    layer, no leaked file descriptors.
//
// SECURITY NOTES
// ──────────────
// • Tokens are 24 random bytes (Random.secure) → 32-char base64url. Knowing
//   the token is required to fetch the file.
// • The server binds to all interfaces (0.0.0.0). On a hostile network this
//   would leak files to LAN peers if they guessed a token. The threat model
//   here is "trusted home Wi-Fi with a Chromecast on it".
// • No file path is ever exposed in URLs — only opaque tokens.
//
// LIMITATIONS
// ───────────
// • Only filesystem paths today. Android content URIs are not supported yet.
// • One handler per request; large concurrent fan-out would benefit from a
//   pooled `RandomAccessFile` cache but that's an optimization for later.
// • IPv6 not exposed (anyIPv4 binding).

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import '../../domain/utils/video_mime_utils.dart';

/// Handle returned by [LocalMediaServer.register]: contains the public URL
/// the Cast receiver should fetch, plus the metadata derived at registration.
class MediaTicket {
  final String token;
  final String url;
  final String mimeType;
  final int sizeBytes;

  const MediaTicket({
    required this.token,
    required this.url,
    required this.mimeType,
    required this.sizeBytes,
  });

  @override
  String toString() =>
      'MediaTicket(token=$token, url=$url, mime=$mimeType, size=$sizeBytes)';
}

/// Internal book-keeping for a registered file.
class _Registration {
  final String filePath;
  final String mimeType;
  final int sizeBytes;
  final DateTime expiresAt;

  const _Registration({
    required this.filePath,
    required this.mimeType,
    required this.sizeBytes,
    required this.expiresAt,
  });
}

/// HTTP server that serves a registry of local video files over the LAN. See
/// the file header for usage, security notes, and the manual test procedure.
class LocalMediaServer {
  /// How long a registration stays valid by default. 6 h comfortably covers
  /// the longest movie + intermissions; tokens get GC-evicted afterwards.
  static const Duration defaultTtl = Duration(hours: 6);

  /// Sweeper cadence; the registry is tiny so this is essentially free.
  static const Duration _gcInterval = Duration(minutes: 5);

  /// 64 KiB chunks balance throughput vs. memory. Chromecast's request size
  /// is typically 2 MiB, so each request yields ~32 chunks — well below
  /// shelf's stream backpressure threshold.
  static const int _streamChunkSize = 64 * 1024;

  /// Letting the OS pick a free port avoids "port already in use" races on
  /// hot restart and on devices where another app holds 8080.
  static const int _preferredPort = 0;

  final NetworkInfo _networkInfo;
  final Random _rng;
  final Map<String, _Registration> _registry = {};

  HttpServer? _server;
  Timer? _gcTimer;
  String? _wifiIp;
  int? _boundPort;

  LocalMediaServer({
    NetworkInfo? networkInfo,
    Random? rng,
  })  : _networkInfo = networkInfo ?? NetworkInfo(),
        _rng = rng ?? Random.secure();

  // ── Public API ──────────────────────────────────────────────────────────

  bool get isRunning => _server != null;

  /// `http://<wifi-ip>:<port>` while running, `null` otherwise.
  String? get baseUrl {
    final ip = _wifiIp;
    final port = _boundPort;
    if (!isRunning || ip == null || port == null) return null;
    return 'http://$ip:$port';
  }

  int get activeTokenCount => _registry.length;

  /// Start listening. Throws [StateError] when the device has no Wi-Fi IP,
  /// because a Chromecast on cellular is not reachable.
  Future<void> start() async {
    if (_server != null) return;

    final ip = await _networkInfo.getWifiIP();
    if (ip == null || ip.isEmpty) {
      throw StateError(
        'LocalMediaServer.start(): no Wi-Fi IP (NetworkInfo.getWifiIP() '
        'returned null). Connect the device to the Wi-Fi network the Cast '
        'receiver is on, then retry.',
      );
    }
    _wifiIp = ip;

    final server = await shelf_io.serve(
      _handler,
      InternetAddress.anyIPv4,
      _preferredPort,
    );
    _server = server;
    _boundPort = server.port;
    _gcTimer = Timer.periodic(_gcInterval, (_) => _gcExpired());

    if (kDebugMode) {
      debugPrint('[LocalMediaServer] started at $baseUrl');
    }
  }

  /// Stop the server and drop every registration. Pending requests get their
  /// TCP connection cut; the async generator's `finally` block closes any
  /// `RandomAccessFile` it had open.
  Future<void> stop() async {
    final s = _server;
    _server = null;
    _gcTimer?.cancel();
    _gcTimer = null;
    _registry.clear();
    _wifiIp = null;
    _boundPort = null;

    if (s != null) {
      await s.close(force: true);
      if (kDebugMode) {
        debugPrint('[LocalMediaServer] stopped');
      }
    }
  }

  /// Register a local file for serving. Returns a [MediaTicket] whose `url`
  /// the caller can hand to the Chromecast receiver.
  ///
  /// Throws [StateError] if the server isn't running, and
  /// [FileSystemException] if the file doesn't exist.
  Future<MediaTicket> register(
    String filePath, {
    Duration? ttl,
  }) async {
    if (!isRunning) {
      throw StateError(
        'LocalMediaServer.register() called before start().',
      );
    }
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('Source file not found', filePath);
    }

    final length = await file.length();
    final mimeType = _detectMime(filePath);
    final token = _generateToken();

    _registry[token] = _Registration(
      filePath: filePath,
      mimeType: mimeType,
      sizeBytes: length,
      expiresAt: DateTime.now().add(ttl ?? defaultTtl),
    );

    final url = '$baseUrl/v/$token';
    if (kDebugMode) {
      debugPrint(
        '[LocalMediaServer] registered $url (mime=$mimeType, size=$length B, '
        'ttl=${(ttl ?? defaultTtl).inMinutes} min)',
      );
    }

    return MediaTicket(
      token: token,
      url: url,
      mimeType: mimeType,
      sizeBytes: length,
    );
  }

  /// Drop a registration eagerly (without waiting for TTL). Idempotent.
  void unregister(String token) {
    if (_registry.remove(token) != null && kDebugMode) {
      debugPrint('[LocalMediaServer] unregistered token=$token');
    }
  }

  // ── HTTP handler ────────────────────────────────────────────────────────

  FutureOr<Response> _handler(Request request) {
    final segments = request.url.pathSegments;
    if (segments.isEmpty) return Response.notFound('Not found');

    switch (segments.first) {
      case 'healthz':
        return Response.ok('ok');
      case 'v':
        if (segments.length < 2) return Response.notFound('Missing token');
        return _serveVideo(request, segments[1]);
      default:
        return Response.notFound('Not found');
    }
  }

  Future<Response> _serveVideo(Request request, String token) async {
    final reg = _registry[token];
    if (reg == null) {
      return Response.notFound('Unknown token');
    }
    if (DateTime.now().isAfter(reg.expiresAt)) {
      _registry.remove(token);
      return Response.notFound('Token expired');
    }

    final file = File(reg.filePath);
    if (!await file.exists()) {
      // File was deleted/moved after registration; evict so we don't keep
      // serving 404s under the same token.
      _registry.remove(token);
      return Response.notFound('Source missing');
    }

    final commonHeaders = <String, String>{
      'Accept-Ranges': 'bytes',
      'Content-Type': reg.mimeType,
      'Cache-Control': 'no-store',
    };

    // HEAD = metadata probe; same headers, no body.
    if (request.method == 'HEAD') {
      return Response.ok(
        null,
        headers: {
          ...commonHeaders,
          'Content-Length': reg.sizeBytes.toString(),
        },
      );
    }

    final parsed = _parseRange(request.headers['range'], reg.sizeBytes);

    // No Range header (or unparseable) — stream the whole file.
    if (parsed == null) {
      return Response.ok(
        _streamFile(file, 0, reg.sizeBytes - 1),
        headers: {
          ...commonHeaders,
          'Content-Length': reg.sizeBytes.toString(),
        },
      );
    }

    final (start, end) = parsed;
    if (start >= reg.sizeBytes || end < start) {
      return Response(
        416,
        headers: {
          ...commonHeaders,
          'Content-Range': 'bytes */${reg.sizeBytes}',
        },
        body: 'Requested range not satisfiable',
      );
    }
    final length = end - start + 1;
    return Response(
      206,
      headers: {
        ...commonHeaders,
        'Content-Length': length.toString(),
        'Content-Range': 'bytes $start-$end/${reg.sizeBytes}',
      },
      body: _streamFile(file, start, end),
    );
  }

  Stream<List<int>> _streamFile(File file, int start, int end) async* {
    final raf = await file.open();
    try {
      await raf.setPosition(start);
      var remaining = end - start + 1;
      while (remaining > 0) {
        final size =
            remaining < _streamChunkSize ? remaining : _streamChunkSize;
        final bytes = await raf.read(size);
        if (bytes.isEmpty) break;
        yield bytes;
        remaining -= bytes.length;
      }
    } finally {
      // Runs on normal completion AND when the consumer cancels (client
      // disconnect), so no file descriptors are leaked.
      await raf.close();
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  /// Parse an HTTP `Range: bytes=START-END` value. Returns `null` for absent
  /// or unparseable inputs (the caller then serves the full file).
  ///
  /// Honors the three single-range forms RFC 7233 defines:
  ///   bytes=START-END   (closed)
  ///   bytes=START-      (open-ended → up to the last byte)
  ///   bytes=-N          (suffix → last N bytes)
  ///
  /// Multi-range (`bytes=0-100,200-300`) is intentionally collapsed to its
  /// first range; Chromecast never asks for multiple at once, and a proper
  /// multipart response would just complicate the streaming path for no
  /// real-world gain.
  (int, int)? _parseRange(String? header, int sizeBytes) {
    if (header == null || header.isEmpty) return null;
    if (!header.startsWith('bytes=')) return null;

    final spec = header.substring('bytes='.length);
    final first = spec.split(',').first.trim();
    final dash = first.indexOf('-');
    if (dash < 0) return null;

    final startStr = first.substring(0, dash);
    final endStr = first.substring(dash + 1);

    if (startStr.isEmpty) {
      final suffixLen = int.tryParse(endStr);
      if (suffixLen == null || suffixLen <= 0) return null;
      final start = sizeBytes - suffixLen;
      return (start < 0 ? 0 : start, sizeBytes - 1);
    }

    final start = int.tryParse(startStr);
    if (start == null || start < 0) return null;

    if (endStr.isEmpty) {
      return (start, sizeBytes - 1);
    }
    final end = int.tryParse(endStr);
    if (end == null || end < 0) return null;
    return (start, end >= sizeBytes ? sizeBytes - 1 : end);
  }

  /// Look up the MIME by extension through the shared video metadata helper.
  /// Anything unknown gets `application/octet-stream` so the receiver can
  /// reject it cleanly and callers can surface a format warning.
  String _detectMime(String filePath) {
    return VideoMimeUtils.mimeTypeForPath(filePath);
  }

  /// 24 random bytes → base64url-encoded ≈ 32 chars. `Random.secure()` uses
  /// the platform CSPRNG (`/dev/urandom` on Android), so guessing tokens is
  /// equivalent to brute-forcing a 192-bit secret — i.e. infeasible.
  String _generateToken() {
    final bytes = List<int>.generate(24, (_) => _rng.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  void _gcExpired() {
    final now = DateTime.now();
    final before = _registry.length;
    _registry.removeWhere((_, r) => now.isAfter(r.expiresAt));
    final removed = before - _registry.length;
    if (removed > 0 && kDebugMode) {
      debugPrint('[LocalMediaServer] gc evicted $removed expired token(s)');
    }
  }
}
