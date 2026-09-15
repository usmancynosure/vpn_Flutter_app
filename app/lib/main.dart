import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'state/vpn_controller.dart';
import 'theme/app_theme.dart';
import 'screens/root_scaffold.dart';
import 'vpn/vpn_engine.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  runApp(const ShieldVpnApp());
}

VpnEngine _buildEngine() {
  if (!kIsWeb && Platform.isAndroid) return WireGuardEngine();
  return MockVpnEngine();
}

class ShieldVpnApp extends StatelessWidget {
  const ShieldVpnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Real WireGuard tunnel on Android (VpnService, no Apple account needed).
      // iOS needs a Network Extension target first, so it stays on the mock
      // until that's added; web/desktop always use the mock.
      create: (_) => VpnController(_buildEngine()),
      child: MaterialApp(
        title: 'Shield VPN',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const RootScaffold(),
      ),
    );
  }
}
