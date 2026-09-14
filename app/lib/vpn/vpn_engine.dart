import 'dart:async';

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

/// Real WireGuard engine — ENABLE IN PHASE 0b.
///
/// Steps to activate:
///   1. Uncomment `wireguard_flutter` in pubspec.yaml, run `flutter pub get`.
///   2. iOS: add a Network Extension target + App Group + entitlements.
///      Android: the plugin registers the VpnService (consent dialog on first run).
///   3. Uncomment the plugin calls below and pass a WireGuardEngine into
///      VpnController instead of MockVpnEngine.
///
/// The config string it receives is exactly the `[Interface]/[Peer]` text your
/// backend returns from `POST /connect` (or, for now, the Sweden test config).
class WireGuardEngine implements VpnEngine {
  final _controller = StreamController<VpnStage>.broadcast();
  // final _wg = WireGuardFlutter.instance;

  @override
  Stream<VpnStage> get stage => _controller.stream;

  Future<void> init() async {
    // await _wg.initialize(interfaceName: 'wg0');
    // _wg.vpnStageSnapshot.listen((s) => _controller.add(_map(s)));
  }

  @override
  Future<void> connect(VpnServer server, String wgConfig) async {
    _controller.add(VpnStage.connecting);
    // await _wg.startVpn(
    //   serverAddress: server.ip,
    //   wgQuickConfig: wgConfig,
    //   providerBundleIdentifier: 'com.shieldvpn.shieldVpn.tunnel',
    // );
  }

  @override
  Future<void> disconnect() async {
    _controller.add(VpnStage.disconnecting);
    // await _wg.stopVpn();
  }

  @override
  void dispose() => _controller.close();
}
