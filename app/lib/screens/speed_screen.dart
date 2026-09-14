import 'package:flutter/material.dart';

import '../data/network_service.dart';
import '../theme/app_colors.dart';
import '../widgets/speed_gauge.dart';
import '../widgets/stat_tile.dart';
import '../widgets/top_bar.dart';

class SpeedScreen extends StatefulWidget {
  const SpeedScreen({super.key});

  @override
  State<SpeedScreen> createState() => _SpeedScreenState();
}

class _SpeedScreenState extends State<SpeedScreen> {
  final _net = NetworkService();

  double _speed = 0;
  double _upload = 0;
  double _download = 0;
  int _ping = 0;
  String _ip = '—';
  bool _testing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadIp();
  }

  @override
  void dispose() {
    _net.dispose();
    super.dispose();
  }

  Future<void> _loadIp() async {
    try {
      final info = await _net.fetchIpInfo();
      if (mounted && info.ip.isNotEmpty) setState(() => _ip = info.ip);
    } catch (_) {/* leave placeholder */}
  }

  /// Real speed test against Cloudflare's public endpoints.
  Future<void> _runTest() async {
    if (_testing) return;
    setState(() {
      _testing = true;
      _error = null;
      _speed = 0;
    });
    try {
      final result = await _net.runSpeedTest(
        onDownloadProgress: (mbps) {
          if (mounted) setState(() => _speed = mbps);
        },
      );
      if (!mounted) return;
      setState(() {
        _download = result.downloadMbps;
        _upload = result.uploadMbps;
        _ping = result.pingMs;
        _speed = result.downloadMbps;
      });
    } catch (e) {
      if (mounted) setState(() => _error = 'Test failed — check your network');
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const TopBar(title: 'Speed'),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 26),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFFFFFFF), Color(0xFFF3F2FE)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        blurRadius: 30,
                        offset: const Offset(0, 14),
                      ),
                      const BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Soft radial glow behind the gauge for depth.
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 170,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.10),
                                  AppColors.primary.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                          SpeedGauge(
                            value: _speed,
                            max: _speed <= 100
                                ? 100
                                : ((_speed / 100).ceil() * 100).toDouble(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _TryAgainButton(testing: _testing, onTap: _runTest),
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text(_error!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.disconnected)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        icon: Icons.north_rounded,
                        label: 'Upload',
                        value: _upload == 0 ? '—' : _upload.toStringAsFixed(0),
                        unit: 'mbps',
                        gradient: AppColors.tileBlue,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: StatTile(
                        icon: Icons.south_rounded,
                        label: 'Download',
                        value:
                            _download == 0 ? '—' : _download.toStringAsFixed(0),
                        unit: 'mbps',
                        gradient: AppColors.tileGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        icon: Icons.autorenew_rounded,
                        label: 'Ping',
                        value: _ping == 0 ? '—' : '$_ping',
                        unit: 'ms',
                        gradient: AppColors.tilePink,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: StatTile(
                        icon: Icons.wifi_tethering_rounded,
                        label: 'IP',
                        value: _ip,
                        unit: '',
                        gradient: AppColors.tilePeach,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TryAgainButton extends StatelessWidget {
  const _TryAgainButton({required this.testing, required this.onTap});
  final bool testing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDeep],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            testing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.refresh_rounded,
                    size: 19, color: Colors.white),
            const SizedBox(width: 8),
            Text(testing ? 'Testing…' : 'Try Again',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
