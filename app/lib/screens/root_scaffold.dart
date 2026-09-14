import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_bottom_nav.dart';
import 'home_screen.dart';
import 'servers_screen.dart';
import 'speed_screen.dart';

/// Hosts the three tabs behind the floating bottom nav.
/// Nav order: Servers (0) · Home (1) · Speed (2). Home is the default.
class RootScaffold extends StatefulWidget {
  const RootScaffold({super.key});

  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  int _index = 1;

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final pages = [
      ServersScreen(onConnect: () => _go(1)),
      HomeScreen(onOpenServers: () => _go(0)),
      const SpeedScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: KeyedSubtree(
                key: ValueKey(_index),
                child: pages[_index],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: AppBottomNav(index: _index, onChanged: _go),
            ),
          ),
        ],
      ),
    );
  }
}
