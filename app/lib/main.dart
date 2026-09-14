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

class ShieldVpnApp extends StatelessWidget {
  const ShieldVpnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Phase 0: MockVpnEngine so the UI runs with no native setup.
      // Phase 0b: swap in WireGuardEngine() once the native tunnel is wired.
      create: (_) => VpnController(MockVpnEngine()),
      child: MaterialApp(
        title: 'Shield VPN',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const RootScaffold(),
      ),
    );
  }
}
