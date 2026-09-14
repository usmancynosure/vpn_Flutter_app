import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

import '../models/vpn_server.dart';
import '../theme/app_colors.dart';

/// Gradient server tile with flag, a faint country silhouette feel, a selected
/// radio, and the location name — as in the reference home screen.
class ServerCard extends StatelessWidget {
  const ServerCard({
    super.key,
    required this.server,
    required this.selected,
    required this.onTap,
  });

  final VpnServer server;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 190,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: server.cardGradient,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: server.cardGradient.last.withValues(alpha: 0.5),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipOval(
                  child: CountryFlag.fromCountryCode(
                    server.countryCode,
                    height: 40,
                    width: 40,
                  ),
                ),
                const Spacer(),
                _RadioDot(selected: selected),
              ],
            ),
            const Spacer(),
            Text(
              'Location',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textPrimary.withValues(alpha: 0.55)),
            ),
            const SizedBox(height: 2),
            Text(
              server.country,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.bolt_rounded,
                    size: 15, color: AppColors.primaryDeep.withValues(alpha: 0.7)),
                const SizedBox(width: 2),
                Text('${server.pingMs} ms',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary.withValues(alpha: 0.6),
                        fontSize: 12)),
                if (server.isPremium) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.workspace_premium_rounded,
                      size: 15, color: Color(0xFFCC9A2B)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.7),
        border: Border.all(
          color: selected ? AppColors.primary : Colors.white,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
            )
          : null,
    );
  }
}
