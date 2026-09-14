import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../vpn/vpn_engine.dart';
import 'liquid_glass.dart';

/// Big circular liquid-glass connect button. A colored glow sits *behind* the
/// glass so the backdrop blur refracts it; the glass tint + specular edge give
/// the Apple "Liquid Glass" feel. Pulses while connecting.
class PowerButton extends StatefulWidget {
  const PowerButton({super.key, required this.stage, required this.onTap});

  final VpnStage stage;
  final VoidCallback onTap;

  @override
  State<PowerButton> createState() => _PowerButtonState();
}

class _PowerButtonState extends State<PowerButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Color get _glow => switch (widget.stage) {
        VpnStage.connected => AppColors.connected,
        VpnStage.error => AppColors.disconnected,
        _ => AppColors.primary,
      };

  bool get _busy =>
      widget.stage == VpnStage.connecting ||
      widget.stage == VpnStage.disconnecting;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, _) {
          final t = _busy ? _pulse.value : 1.0;
          final glowSpread = _busy ? 6 + t * 20 : 22.0;
          final glowOpacity = _busy ? 0.30 + t * 0.30 : 0.45;
          return SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Colored aura the glass refracts.
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _glow.withValues(alpha: 0.85),
                        _glow.withValues(alpha: 0.15),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _glow.withValues(alpha: glowOpacity),
                        blurRadius: 44,
                        spreadRadius: glowSpread,
                      ),
                    ],
                  ),
                ),
                // The liquid-glass disc.
                LiquidGlass(
                  circle: true,
                  width: 150,
                  height: 150,
                  blur: 14,
                  tintOpacity: 0.30,
                  child: Center(
                    child: _busy
                        ? SizedBox(
                            width: 44,
                            height: 44,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: const AlwaysStoppedAnimation(
                                  Colors.white),
                            ),
                          )
                        : Icon(Icons.power_settings_new_rounded,
                            size: 54, color: Colors.white),
                  ),
                ),
                // Bright inner rim highlight.
                IgnorePointer(
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.45),
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: 0.10),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
