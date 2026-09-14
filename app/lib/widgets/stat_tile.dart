import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Rounded pastel-gradient tile used on the Speed screen (upload/download/…).
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.gradient,
  });

  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.textPrimary.withValues(alpha: 0.7)),
          const SizedBox(height: 18),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textPrimary.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textPrimary.withValues(alpha: 0.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
