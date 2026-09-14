import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'liquid_glass.dart';

/// Floating liquid-glass pill navigation bar. Frosted, translucent, refracts
/// the content scrolling behind it. The active item expands to show its label.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.index,
    required this.onChanged,
  });

  final int index;
  final ValueChanged<int> onChanged;

  static const _items = [
    (icon: Icons.public_rounded, label: 'Servers'),
    (icon: Icons.shield_rounded, label: 'Home'),
    (icon: Icons.bolt_rounded, label: 'Speed'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x222A2A55),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: LiquidGlass(
        borderRadius: 32,
        blur: 30,
        tintOpacity: 0.42,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (int i = 0; i < _items.length; i++)
              _NavItem(
                icon: _items[i].icon,
                label: _items[i].label,
                active: i == index,
                onTap: () => onChanged(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: active ? 18 : 16, vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 22,
                color: active ? Colors.white : AppColors.textFaint),
            if (active) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
