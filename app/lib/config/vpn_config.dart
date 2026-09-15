/// TEST-ONLY WireGuard config for Phase 0b.
///
/// This is the real config for our AWS server in Stockholm. In production the
/// backend (`POST /connect`) generates a fresh per-device key and returns this
/// block — never ship a hard-coded key in a released app.
///
/// The same key can only be actively connected from ONE device at a time, so
/// disconnect the desktop WireGuard app before testing the mobile app.
class VpnConfig {
  VpnConfig._();

  static const String swedenEndpoint = '51.21.255.243:51820';
  static const String swedenServerAddress = '51.21.255.243';

  static const String swedenTestConfig = '''
[Interface]
PrivateKey = 2OFqsQTaR+cKIWd29AacucjiTCZulhM+9Pj+hsEooUY=
Address = 10.7.0.2/32
DNS = 1.1.1.1

[Peer]
PublicKey = bcrRgW2lm9VugdKgvl1Brk0oGZwcPeXxSvo5k8q1nGE=
Endpoint = 51.21.255.243:51820
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
''';
}
