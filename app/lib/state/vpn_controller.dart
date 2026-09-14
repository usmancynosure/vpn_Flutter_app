import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/servers.dart';
import '../models/vpn_server.dart';
import '../vpn/vpn_engine.dart';

/// Owns connection state, the selected server, and the connected-duration timer.
/// The UI listens to this via `provider`.
class VpnController extends ChangeNotifier {
  VpnController(this._engine) {
    _stageSub = _engine.stage.listen(_onStage);
  }

  final VpnEngine _engine;
  StreamSubscription<VpnStage>? _stageSub;
  Timer? _ticker;

  VpnStage _stage = VpnStage.disconnected;
  VpnServer _selected = kServers.first;
  Duration _elapsed = Duration.zero;

  VpnStage get stage => _stage;
  VpnServer get selected => _selected;
  Duration get elapsed => _elapsed;

  bool get isConnected => _stage == VpnStage.connected;
  bool get isBusy =>
      _stage == VpnStage.connecting || _stage == VpnStage.disconnecting;

  String get statusLabel => switch (_stage) {
        VpnStage.connected => 'Connected',
        VpnStage.connecting => 'Connecting…',
        VpnStage.disconnecting => 'Disconnecting…',
        VpnStage.error => 'Error',
        VpnStage.disconnected => 'Tap to connect',
      };

  String get elapsedLabel {
    final h = _elapsed.inHours.toString().padLeft(2, '0');
    final m = (_elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  void selectServer(VpnServer server) {
    if (server.id == _selected.id) return;
    final wasConnected = isConnected;
    _selected = server;
    notifyListeners();
    if (wasConnected) {
      // Reconnect to the newly chosen location.
      _engine.disconnect().then((_) => connect());
    }
  }

  Future<void> toggle() => isConnected || isBusy ? disconnect() : connect();

  Future<void> connect() async {
    // Phase 1: fetch this config from your backend's POST /connect.
    // Phase 0: the mock ignores it; the real engine would use the Sweden config.
    const placeholderConfig = '';
    await _engine.connect(_selected, placeholderConfig);
  }

  Future<void> disconnect() => _engine.disconnect();

  void _onStage(VpnStage s) {
    _stage = s;
    if (s == VpnStage.connected) {
      _startTicker();
    } else if (s == VpnStage.disconnected || s == VpnStage.error) {
      _stopTicker();
      _elapsed = Duration.zero;
    }
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    _elapsed = Duration.zero;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed += const Duration(seconds: 1);
      notifyListeners();
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  void dispose() {
    _stageSub?.cancel();
    _ticker?.cancel();
    _engine.dispose();
    super.dispose();
  }
}
