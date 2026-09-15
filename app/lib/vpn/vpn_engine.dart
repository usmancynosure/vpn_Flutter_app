import 'dart:async';

import 'package:wireguard_flutter/wireguard_flutter.dart' as wg;

import '../models/vpn_server.dart';

/// Tunnel lifecycle stages surfaced to the UI.
enum VpnStage { disconnected, connecting, connected, disconnecting, error }

/// Abstraction over "the thing that actually opens the tunnel".
///
/// Phase 0 ships [MockVpnEngine] so the whole UI runs in a simulator with no
/// native setup. Phase 0b swaps in [WireGuardEngine] (below) — the UI code
/// does not change, only the engine passed into `VpnController`.
abstract class VpnEngine {
  Stream<VpnStage> get stage;
  Future<void> connect(VpnServer server, String wgConfig);
  Future<void> disconnect();
  void dispose();
}

/// Simulated engine: transitions through the real stages on timers so you can
/// build and demo the UI before the native tunnel is wired up.
class MockVpnEngine implements VpnEngine {
  final _controller = StreamController<VpnStage>.broadcast();
  VpnStage _current = VpnStage.disconnected;

  @override
  Stream<VpnStage> get stage => _controller.stream;

  void _emit(VpnStage s) {
    _current = s;
    _controller.add(s);
  }

  @override
  Future<void> connect(VpnServer server, String wgConfig) async {
    _emit(VpnStage.connecting);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (_current == VpnStage.connecting) _emit(VpnStage.connected);
  }

  @override
  Future<void> disconnect() async {
    _emit(VpnStage.disconnecting);
    await Future.delayed(const Duration(milliseconds: 700));
    _emit(VpnStage.disconnected);
  }

  @override
  void dispose() => _controller.close();
}

/// Real WireGuard engine (Phase 0b) — drives the native tunnel via
/// `wireguard_flutter`. On Android the plugin registers a `VpnService` and
/// shows the OS consent dialog on first connect. On iOS it needs a Network
/// Extension target + entitlements (an Apple org account).
///
/// The config string it receives is the `[Interface]/[Peer]` text — for now
/// the Sweden test config; in Phase 1 it comes from `POST /connect`.
class WireGuardEngine implements VpnEngine {
  WireGuardEngine({this.bundleId = 'com.shieldvpn.shieldVpn'});

  final String bundleId;
  final _wg = wg.WireGuardFlutter.instance;
  final _controller = StreamController<VpnStage>.broadcast();
  StreamSubscription<wg.VpnStage>? _sub;
  bool _initialized = false;

  @override
  Stream<VpnStage> get stage => _controller.stream;

  Future<void> _ensureInit() async {
    if (_initialized) return;
    await _wg.initialize(interfaceName: 'wg0');
    _sub = _wg.vpnStageSnapshot.listen((s) => _controller.add(_map(s)));
    _initialized = true;
  }

  // Map the plugin's richer stage set onto our four-state model.
  VpnStage _map(wg.VpnStage s) => switch (s) {
        wg.VpnStage.connected => VpnStage.connected,
        wg.VpnStage.connecting ||
        wg.VpnStage.waitingConnection ||
        wg.VpnStage.authenticating ||
        wg.VpnStage.reconnect ||
        wg.VpnStage.preparing =>
          VpnStage.connecting,
        wg.VpnStage.disconnecting ||
        wg.VpnStage.exiting =>
          VpnStage.disconnecting,
        wg.VpnStage.disconnected ||
        wg.VpnStage.noConnection =>
          VpnStage.disconnected,
        wg.VpnStage.denied => VpnStage.error,
      };

  @override
  Future<void> connect(VpnServer server, String wgConfig) async {
    try {
      await _ensureInit();
      _controller.add(VpnStage.connecting);
      await _wg.startVpn(
        serverAddress: server.ip,
        wgQuickConfig: wgConfig,
        providerBundleIdentifier: bundleId,
      );
    } catch (e) {
      _controller.add(VpnStage.error);
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    _controller.add(VpnStage.disconnecting);
    await _wg.stopVpn();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _controller.close();
  }
}
