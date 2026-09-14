import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Public IP + geo for the current connection.
class IpInfo {
  final String ip;
  final String city;
  final String country;
  const IpInfo({required this.ip, required this.city, required this.country});
}

/// Result of a real speed test.
class SpeedResult {
  final double downloadMbps;
  final double uploadMbps;
  final int pingMs;
  const SpeedResult({
    required this.downloadMbps,
    required this.uploadMbps,
    required this.pingMs,
  });
}

/// Real network measurements — no mock data.
///
/// - IP/geo via ipwho.is (free, HTTPS, no key).
/// - Throughput via Cloudflare's public speed endpoints (speed.cloudflare.com),
///   the same ones speed.cloudflare.com uses.
class NetworkService {
  final http.Client _client = http.Client();

  static const _upUrl = 'https://speed.cloudflare.com/__up';

  // Cloudflare 403s the default Dart user-agent; present a browser one.
  static const _headers = {
    'User-Agent':
        'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
            'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile Safari/604.1',
    'Accept': '*/*',
  };

  /// Current public IP and rough location.
  Future<IpInfo> fetchIpInfo() async {
    final resp = await _client
        .get(Uri.parse('https://ipwho.is/'))
        .timeout(const Duration(seconds: 8));
    final body = resp.body;
    String pick(String key) {
      final m = RegExp('"$key":\\s*"([^"]*)"').firstMatch(body);
      return m?.group(1) ?? '';
    }

    return IpInfo(
      ip: pick('ip'),
      city: pick('city'),
      country: pick('country'),
    );
  }

  // Reliable HTTPS download sources (verified to serve real bytes); in order.
  static const _downloadSources = [
    'https://proof.ovh.net/files/100Mb.dat',
    'https://ash-speed.hetzner.com/100MB.bin',
    'https://speed.cloudflare.com/__down?bytes=20000000',
  ];

  /// Median-ish latency (min of several round-trips) to a fast endpoint, in ms.
  Future<int> measurePing({int samples = 5}) async {
    int best = 9999;
    for (var i = 0; i < samples; i++) {
      final sw = Stopwatch()..start();
      try {
        // 204 no-content endpoint — tiny and ultra-reliable.
        await _client
            .get(Uri.parse('https://www.google.com/generate_204'),
                headers: _headers)
            .timeout(const Duration(seconds: 5));
        sw.stop();
        best = math.min(best, sw.elapsedMilliseconds);
      } catch (_) {
        // ignore a failed sample
      }
    }
    return best == 9999 ? 0 : best;
  }

  /// Streamed download so the caller can animate live throughput.
  /// Streams from a large file and stops after [capBytes] to bound the time.
  /// Tries each source until one returns real bytes. Returns average Mbps.
  Future<double> measureDownload({
    int capBytes = 15000000, // measure ~15 MB
    void Function(double mbps)? onProgress,
  }) async {
    for (final url in _downloadSources) {
      try {
        final req = http.Request('GET', Uri.parse(url))
          ..followRedirects = true
          ..headers.addAll(_headers);
        final resp =
            await _client.send(req).timeout(const Duration(seconds: 15));
        debugPrint('[speedtest] $url status=${resp.statusCode}');
        if (resp.statusCode != 200) continue;

        var received = 0;
        final sw = Stopwatch()..start();
        await for (final chunk in resp.stream) {
          received += chunk.length;
          final secs = sw.elapsedMilliseconds / 1000.0;
          if (secs > 0) onProgress?.call(received * 8 / secs / 1e6);
          if (received >= capBytes) break; // enough — stop the big file early
        }
        sw.stop();
        debugPrint('[speedtest] $url received=$received in '
            '${sw.elapsedMilliseconds}ms');
        if (received > 0) {
          final secs = sw.elapsedMilliseconds / 1000.0;
          return secs > 0 ? received * 8 / secs / 1e6 : 0;
        }
      } catch (e) {
        debugPrint('[speedtest] $url failed: $e');
      }
    }
    return 0;
  }

  /// Upload a payload and measure throughput, in Mbps.
  Future<double> measureUpload({int bytes = 8000000}) async {
    final payload = Uint8List(bytes); // zero-filled is fine for throughput
    final sw = Stopwatch()..start();
    await _client
        .post(Uri.parse(_upUrl), headers: _headers, body: payload)
        .timeout(const Duration(seconds: 30));
    sw.stop();
    final secs = sw.elapsedMilliseconds / 1000.0;
    return secs > 0 ? bytes * 8 / secs / 1e6 : 0;
  }

  /// Full test: ping → download (animated) → upload.
  Future<SpeedResult> runSpeedTest({
    void Function(double mbps)? onDownloadProgress,
  }) async {
    final ping = await measurePing();
    final down = await measureDownload(onProgress: onDownloadProgress);
    final up = await measureUpload();
    return SpeedResult(downloadMbps: down, uploadMbps: up, pingMs: ping);
  }

  void dispose() => _client.close();
}
