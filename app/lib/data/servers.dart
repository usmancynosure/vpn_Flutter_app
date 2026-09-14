import '../models/vpn_server.dart';
import '../theme/app_colors.dart';

/// Static server list for Phase 0. In Phase 1 this comes from `GET /servers`.
///
/// NOTE: the Sweden entry is the REAL WireGuard test server you provisioned
/// on AWS (eu-north-1). The rest are placeholders until you add more nodes.
const List<VpnServer> kServers = [
  VpnServer(
    id: 'se-sto-1',
    country: 'Sweden',
    city: 'Stockholm',
    countryCode: 'SE',
    ip: '51.21.255.243',
    pingMs: 42,
    cardGradient: AppColors.cardBlue,
  ),
  VpnServer(
    id: 'us-nyc-1',
    country: 'United States',
    city: 'New York',
    countryCode: 'US',
    ip: '166.43.245.10',
    pingMs: 88,
    cardGradient: AppColors.cardRed,
  ),
  VpnServer(
    id: 'ca-tor-1',
    country: 'Canada',
    city: 'Toronto',
    countryCode: 'CA',
    ip: '162.19.44.21',
    pingMs: 95,
    cardGradient: AppColors.cardGreen,
  ),
  VpnServer(
    id: 'gb-lon-1',
    country: 'United Kingdom',
    city: 'London',
    countryCode: 'GB',
    ip: '178.62.10.5',
    pingMs: 64,
    isPremium: true,
    cardGradient: AppColors.cardPurple,
  ),
  VpnServer(
    id: 'de-fra-1',
    country: 'Germany',
    city: 'Frankfurt',
    countryCode: 'DE',
    ip: '49.12.8.9',
    pingMs: 71,
    isPremium: true,
    cardGradient: AppColors.cardBlue,
  ),
];
