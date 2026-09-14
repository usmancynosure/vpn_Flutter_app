import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Screen header: menu button, centered title, premium (crown) button.
class TopBar extends StatelessWidget {
  const TopBar({super.key, required this.title, this.onMenu, this.onPremium});

  final String title;
  final VoidCallback? onMenu;
  final VoidCallback? onPremium;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          _CircleButton(icon: Icons.menu_rounded, onTap: onMenu),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          _CircleButton(
            icon: Icons.workspace_premium_rounded,
            iconColor: const Color(0xFFCC9A2B),
            onTap: onPremium,
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, this.onTap, this.iconColor});
  final IconData icon;
  final VoidCallback? onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface.withValues(alpha: 0.7),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 22, color: iconColor ?? AppColors.textPrimary),
      ),
    );
  }
}
