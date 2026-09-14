import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/servers.dart';
import '../state/vpn_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/power_button.dart';
import '../widgets/server_card.dart';
import '../widgets/top_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenServers});

  final VoidCallback onOpenServers;

  @override
  Widget build(BuildContext context) {
    final vpn = context.watch<VpnController>();

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const TopBar(title: 'Shield'),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _MapHero(
                    city: vpn.selected.city,
                    country: vpn.selected.country,
                    ip: vpn.selected.ip,
                    connected: vpn.isConnected,
                  ),
                  const SizedBox(height: 8),
                  PowerButton(stage: vpn.stage, onTap: vpn.toggle),
                  const SizedBox(height: 20),
                  Text(vpn.statusLabel,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    vpn.isConnected ? vpn.elapsedLabel : '—',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontFeatures: const []),
                  ),
                  const SizedBox(height: 24),
                  _ServerRow(onOpenServers: onOpenServers),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Faint map backdrop + a floating location pill.
class _MapHero extends StatelessWidget {
  const _MapHero({
    required this.city,
    required this.country,
    required this.ip,
    required this.connected,
  });

  final String city;
  final String country;
  final String ip;
  final bool connected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 158,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Gradient fallback if the Gemini map image isn't added yet.
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.backgroundAlt, AppColors.background],
                ),
              ),
              child: Image.asset(
                'assets/images/map_bg.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          Positioned(
            top: 10,
            child: _LocationPill(
              city: city,
              country: country,
              ip: ip,
              connected: connected,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationPill extends StatelessWidget {
  const _LocationPill({
    required this.city,
    required this.country,
    required this.ip,
    required this.connected,
  });

  final String city;
  final String country;
  final String ip;
  final bool connected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: (connected ? AppColors.connected : AppColors.primary)
                    .withValues(alpha: 0.4),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(Icons.location_on_rounded,
              color: connected ? AppColors.connected : AppColors.primary),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 14,
                  offset: Offset(0, 6)),
            ],
          ),
          child: Column(
            children: [
              Text('$city, $country',
                  style: Theme.of(context).textTheme.titleMedium),
              Text(ip, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _ServerRow extends StatelessWidget {
  const _ServerRow({required this.onOpenServers});
  final VoidCallback onOpenServers;

  @override
  Widget build(BuildContext context) {
    final vpn = context.watch<VpnController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Locations',
                  style: Theme.of(context).textTheme.titleLarge),
              GestureDetector(
                onTap: onOpenServers,
                child: Text('See all',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: AppColors.primary)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: kServers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final server = kServers[i];
              return ServerCard(
                server: server,
                selected: server.id == vpn.selected.id,
                onTap: () {
                  context.read<VpnController>().selectServer(server);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
