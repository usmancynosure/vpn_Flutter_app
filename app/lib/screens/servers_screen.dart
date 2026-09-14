import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/servers.dart';
import '../state/vpn_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/top_bar.dart';

class ServersScreen extends StatelessWidget {
  const ServersScreen({super.key, this.onConnect});

  final VoidCallback? onConnect;

  @override
  Widget build(BuildContext context) {
    final vpn = context.watch<VpnController>();

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const TopBar(title: 'Servers'),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                const _GlobeHero(),
                const SizedBox(height: 22),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.displayLarge,
                    children: const [
                      TextSpan(text: 'PICK A SERVER,\n'),
                      TextSpan(
                        text: 'UNLOCK THE WORLD!',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Select a server from our global network to enjoy fast, '
                  'secure, and borderless browsing.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                ...kServers.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ServerRow(
                        selected: s.id == vpn.selected.id,
                        onTap: () =>
                            context.read<VpnController>().selectServer(s),
                        code: s.countryCode,
                        title: s.country,
                        subtitle: '${s.city} · ${s.pingMs} ms',
                        premium: s.isPremium,
                      ),
                    )),
                const SizedBox(height: 8),
                _StartButton(onTap: onConnect),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlobeHero extends StatelessWidget {
  const _GlobeHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const RadialGradient(
          center: Alignment.center,
          radius: 0.9,
          colors: [Color(0xFF1B2352), AppColors.heroDark],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Gemini globe image, edges radially faded so its (JPEG-baked)
          // checkerboard corners blend invisibly into the dark card.
          ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (rect) => const RadialGradient(
              colors: [Colors.white, Colors.white, Colors.transparent],
              stops: [0.0, 0.48, 0.66],
            ).createShader(rect),
            child: Image.asset(
              'assets/images/globe.png',
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const _GlowOrb(),
            ),
          ),
          const Positioned(top: 34, left: 30, child: _Pin(label: 'American')),
          const Positioned(top: 30, right: 26, child: _Pin(label: 'Asian')),
          const Positioned(bottom: 30, child: _Pin(label: 'European')),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 170,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFF3E7BFF), Color(0xFF12205A)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.heroGlow.withValues(alpha: 0.6),
            blurRadius: 60,
            spreadRadius: 10,
          ),
        ],
      ),
      child: const Icon(Icons.public_rounded, size: 90, color: Colors.white24),
    );
  }
}

class _Pin extends StatelessWidget {
  const _Pin({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on_rounded,
              size: 15, color: AppColors.disconnected),
          const SizedBox(width: 4),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(fontSize: 13)),
        ],
      ),
    );
  }
}

class _ServerRow extends StatelessWidget {
  const _ServerRow({
    required this.selected,
    required this.onTap,
    required this.code,
    required this.title,
    required this.subtitle,
    required this.premium,
  });

  final bool selected;
  final VoidCallback onTap;
  final String code;
  final String title;
  final String subtitle;
  final bool premium;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 12,
                offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CountryFlag.fromCountryCode(code, height: 32, width: 44),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: Theme.of(context).textTheme.titleMedium),
                      if (premium) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.workspace_premium_rounded,
                            size: 16, color: Color(0xFFCC9A2B)),
                      ],
                    ],
                  ),
                  Text(subtitle,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.primary : AppColors.textFaint,
            ),
          ],
        ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Start For Free',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white)),
            const SizedBox(width: 8),
            const Icon(Icons.auto_awesome_rounded,
                size: 20, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
