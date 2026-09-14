# Building a Commercial Cross-Platform VPN App (Flutter)

**Status:** Architecture & implementation guide
**Target:** iOS + Android first (Flutter), desktop later
**Goal:** Commercial, subscription-based product
**Audience:** Comfortable coder

---

## 1. The one thing to understand before writing any code

A VPN app has four distinct pieces. People conflate them and get lost. Keep them separate in your head:

| Piece | What it does | Where it runs | Do you build it? |
|-------|--------------|---------------|------------------|
| **Client UI** | Connect button, server list, account, paywall | Flutter (Dart) | ✅ Yes |
| **Tunnel engine** | Actually encrypts & routes device traffic | **Native OS extension** | ⚠️ You *integrate* an existing engine, you don't write crypto |
| **VPN servers** | The exit nodes traffic flows out of | VPS in datacenters worldwide | ✅ You provision/configure |
| **Backend API** | Accounts, auth, subscriptions, hands out configs | Your cloud (e.g. Node/Go + Postgres) | ✅ Yes |

### The Flutter constraint (critical)

**Dart code cannot capture or tunnel OS network traffic.** Operating systems only grant packet capture to a sandboxed *system network extension*:

- **iOS / macOS** → Apple `NetworkExtension` framework (`NEPacketTunnelProvider`), requires the **Network Extensions** entitlement from Apple (you must request it; not granted to everyone automatically).
- **Android** → `android.net.VpnService` (a bound foreground service), requires the `BIND_VPN_SERVICE` permission and a user consent dialog.

So the real architecture of "a Flutter VPN" is:

```
┌─────────────────────────────────────────────┐
│  Flutter UI (Dart)                          │
│  server list · connect button · paywall     │
└───────────────┬─────────────────────────────┘
                │  MethodChannel / EventChannel
                │  (start, stop, status, stats)
    ┌───────────┴───────────┐
    ▼                       ▼
┌────────────────┐   ┌────────────────────────┐
│ iOS native     │   │ Android native         │
│ NEPacketTunnel │   │ VpnService             │
│ Provider (Swift)│   │ (Kotlin)               │
│  + tunnel lib  │   │  + tunnel lib          │
└───────┬────────┘   └────────┬───────────────┘
        │  encrypted tunnel    │
        └──────────┬───────────┘
                   ▼
        ┌────────────────────┐
        │  VPN server (VPS)  │  ← WireGuard / OpenVPN / custom daemon
        │  in country X      │
        └────────────────────┘
```

The **tunnel engine** (the box labelled "tunnel lib") is the part that differs between WireGuard, OpenVPN, and a custom protocol. **That is the choice this document is really about.** Everything else (UI, backend, servers, billing) is roughly the same regardless.

---

## 2. Approach A — WireGuard  ⭐ recommended default

### 2.1 What it is
WireGuard is a modern VPN protocol: ~4,000 lines of code, fixed modern crypto (Curve25519, ChaCha20-Poly1305, BLAKE2s), UDP-only, extremely fast, and battery-friendly on mobile. It is the current industry default for new consumer VPNs.

### 2.2 How the pieces map

**Server side (each VPS):**
- Install the `wireguard` kernel module / `wg-quick`.
- Each server has a static keypair. Each client is a "peer" with its own keypair and an assigned internal IP (e.g. `10.7.0.5/32`).
- A client config looks like:

```ini
[Interface]
PrivateKey = <client_private_key>
Address    = 10.7.0.5/32
DNS        = 10.7.0.1

[Peer]
PublicKey  = <server_public_key>
Endpoint   = 185.x.x.x:51820
AllowedIPs = 0.0.0.0/0, ::/0      # route ALL traffic through tunnel
PersistentKeepalive = 25
```

**Client side (native, per platform):**
- Don't write the protocol. Use the official embeddable libraries:
  - iOS/macOS: `wireguard-apple` (the `WireGuardKit` Swift package) inside your `NEPacketTunnelProvider`.
  - Android: `wireguard-android` (the `com.wireguard.android:tunnel` library) inside your `VpnService`.
- For Flutter, the community plugin **`wireguard_flutter`** (or `wireguard_dart`) wraps both and gives you a Dart API. Realistically for a commercial app you'll fork/extend it, because you need custom status, stats, and per-app routing.

### 2.3 Connection flow
1. User taps Connect in Flutter.
2. Flutter asks **your backend**: "give me a config for server X for this user."
3. Backend authenticates the subscription, generates (or reuses) a client keypair, registers the client public key as a peer on the chosen server (via the server's admin API or `wg set`), returns the `.conf` above.
4. Flutter passes the config down the MethodChannel to native.
5. Native extension boots the WireGuard tunnel with that config. OS shows the VPN icon.
6. Native streams status + byte counters back up an EventChannel; Flutter renders them.

### 2.4 Pros / cons
- ✅ Fastest, lowest battery, simplest config, best mobile UX, easy to automate peer management.
- ✅ Best-supported embeddable libraries.
- ⚠️ **UDP-only** → easy to block on restrictive networks (some corporate/campus/national firewalls drop or throttle WireGuard). Mitigate by wrapping it (see §5, obfuscation) or falling back to OpenVPN-TCP.
- ⚠️ Peers are somewhat "static" — you manage IP assignment and key rotation yourself. Tools like **wg-easy**, **Netmaker**, or **Firezone** automate this.

**Recommendation: Ship WireGuard first.** It is the shortest path to a fast, working product.

---

## 3. Approach B — OpenVPN

### 3.1 What it is
The older, battle-tested protocol. Runs over **TCP or UDP**, uses OpenSSL/mbedTLS with X.509 certificates. Slower and heavier than WireGuard but far more configurable and far better at *evading blocks* (TCP/443 OpenVPN looks a lot like normal HTTPS).

### 3.2 How the pieces map

**Server side:** run an OpenVPN daemon (or **OpenVPN Access Server** for a managed control plane). Each client gets a `.ovpn` profile containing CA cert, client cert/key (or username/password + certificate), and remote endpoint:

```
client
dev tun
proto udp                 # or tcp for stealth
remote 185.x.x.x 1194
cipher AES-256-GCM
auth SHA256
<ca>...</ca>
<cert>...</cert>
<key>...</key>
```

**Client side (native):**
- iOS/macOS: use **`OpenVPNAdapter`** (or the **`TunnelKit`** library by Passepartout's author — the most maintained Swift option) inside `NEPacketTunnelProvider`.
- Android: use the **`ics-openvpn`** core (`de.blinkt.openvpn`) as a library module inside `VpnService`.
- Flutter: **`openvpn_flutter`** plugin wraps both platforms and exposes connect/disconnect/status in Dart.

### 3.3 Pros / cons
- ✅ TCP mode + port 443 = very good at getting through restrictive firewalls.
- ✅ Extremely mature, well audited, universally supported.
- ✅ Rich auth options (certs, user/pass, 2FA).
- ⚠️ Slower, higher battery/CPU than WireGuard.
- ⚠️ Config & PKI (certificate authority) management is more involved.

**Recommendation: Add OpenVPN as your "stealth / fallback" protocol** after WireGuard works, so the app can auto-switch when WireGuard is blocked.

---

## 4. Approach C — Custom protocol

### 4.1 What "custom" actually means (three honest levels)

**Do not invent your own encryption.** Rolling your own crypto is how commercial VPNs get breached and lose users' trust. "Custom" in a serious product means one of these:

**Level 1 — Obfuscation wrapper around an existing protocol (recommended form of "custom").**
Keep WireGuard/OpenVPN doing the crypto, but wrap the packets so censors can't fingerprint them:
- **`wstunnel`** — tunnel WireGuard/OpenVPN over WebSocket/HTTPS.
- **`shadowsocks` / `v2ray` / `XRay` (VLESS/VMess/Trojan)** — protocols literally designed to look like ordinary TLS web traffic; heavily used to bypass national firewalls.
- **`obfs4` / `Cloak`** — pluggable transports that disguise the tunnel.
- **AmneziaWG** — a WireGuard fork with built-in obfuscation (junk packets, custom headers) that defeats DPI while keeping WireGuard's speed. This is the single best "custom-feeling" option today.

**Level 2 — Custom transport, standard crypto.**
Build your own daemon that uses a vetted crypto library (`libsodium`, `BoringSSL`, Noise Protocol Framework) for the encryption, but with your own packet format, handshake, multiplexing, port-hopping, or QUIC-based transport. This is what companies do when they want a differentiated "stealth" mode they control end-to-end.

**Level 3 — Fully bespoke protocol.** Only justified at scale with a dedicated security team and external audits. Not where you start.

### 4.2 How you'd build a Level-2 custom protocol

**Server:** a daemon (Go is the usual choice — great networking, easy static binaries) that:
1. Opens a UDP/QUIC (or TCP/TLS) listener.
2. Performs a **Noise Protocol** handshake (the same framework WireGuard uses) for mutual auth + forward secrecy.
3. Reads/writes a TUN device to route packets to the internet with NAT.

**Client (native):** your `NEPacketTunnelProvider` / `VpnService` reads packets off the OS TUN interface, hands them to your client library (ship the Go core to both platforms via **`gomobile bind`** → one shared library for iOS *and* Android), which encrypts and ships them to your server daemon.

```
Flutter UI ─► native extension ─► [your Go client core via gomobile]
             (reads OS TUN)          Noise handshake + your framing
                                     encrypt → QUIC/UDP → your server daemon
```

Using **gomobile** to write the tunnel core *once in Go* and bind it into both the iOS and Android extensions is the pragmatic way to keep "custom" from doubling your work.

### 4.3 Pros / cons
- ✅ Full control; a real differentiator ("works where others are blocked").
- ✅ You own the anti-censorship story.
- ⚠️ You own **all** the security risk. Needs audits, a threat model, careful key management.
- ⚠️ Much slower to build and maintain.

**Recommendation for a commercial launch:** Don't ship a Level-2/3 custom protocol at v1. Ship **WireGuard + OpenVPN**, then add **AmneziaWG or a wstunnel/XRay obfuscation layer** as your "custom stealth mode." You get 90% of the "custom protocol" marketing benefit for 10% of the risk.

---

## 5. Side-by-side decision table

| Dimension | WireGuard | OpenVPN | Custom (obfuscated) |
|-----------|-----------|---------|---------------------|
| Speed | ★★★★★ | ★★★ | ★★★–★★★★ |
| Battery | ★★★★★ | ★★ | ★★★ |
| Firewall evasion | ★★ | ★★★★ (TCP/443) | ★★★★★ |
| Build effort | Low | Medium | High |
| Security risk you own | Low | Low | High |
| Library maturity (Flutter) | Good | Good | You build it |
| Best role | **Default** | **Stealth fallback** | **Premium "unblockable" mode** |

**Product strategy:** WireGuard by default → auto-fallback to OpenVPN-TCP/443 when UDP is blocked → offer obfuscated mode (AmneziaWG / XRay) as a premium feature.

---

## 6. The rest of the product (same for all three protocols)

### 6.1 Backend API
Responsibilities: signup/login, subscription state, server list, and **issuing tunnel configs on demand**. Suggested stack: **Go or Node.js + PostgreSQL + Redis**, behind your VPS fleet.

Core endpoints:
```
POST /auth/register            POST /auth/login          # accounts (or go passwordless / Sign in with Apple)
GET  /servers                  # list: id, country, city, load, protocols supported
POST /connect                  # body: {serverId, protocol} → returns a fresh tunnel config
POST /disconnect               # deregister peer / revoke short-lived cert
GET  /subscription/status      # entitlement check (see billing)
POST /webhooks/revenuecat      # billing events → flip entitlements
```

Config issuance is the security-sensitive core: verify the entitlement, generate short-lived credentials (WireGuard peer or OpenVPN cert), register them on the target server via that server's admin API, and return them. Rotate/revoke on disconnect and on subscription lapse.

### 6.2 Server fleet
- Rent VPS in the countries you advertise. Providers commonly used for VPN exit nodes vary; pick ones with clear acceptable-use terms for VPN traffic and good network capacity.
- Automate provisioning with **Terraform + Ansible** so spinning up "a new city" is one command: install the tunnel daemon, configure NAT/`iptables`, register the server in your backend's `/servers`.
- Run a small **control agent** on each server exposing an internal API your backend calls to add/remove peers (or use wg-easy/Netmaker/Firezone for WireGuard, OpenVPN Access Server for OpenVPN).
- **DNS:** run your own resolver on each server (block leaks; optional ad/tracker blocking as a selling point).

### 6.3 Billing & subscriptions (you already use RevenueCat)
- Use **RevenueCat** to manage App Store + Play Store subscriptions with one SDK (`purchases_flutter`). It normalizes iOS/Android receipts and gives you a single "is this user entitled?" answer.
- Flow: user buys in-app → RevenueCat validates the store receipt → your app reads the **entitlement** → RevenueCat **webhook** hits your backend → backend flips the user's subscription flag → `/connect` starts honoring requests.
- Never gate access purely client-side; the backend must verify entitlement before issuing configs.

### 6.4 Flutter app structure
```
lib/
  main.dart
  core/            # DI, config, secure storage (flutter_secure_storage for tokens/keys)
  data/            # backend API client, RevenueCat wrapper
  features/
    onboarding/
    server_list/   # pick a country
    connection/    # the big Connect button + live stats (from EventChannel)
    paywall/       # RevenueCat paywall
    settings/      # protocol choice, kill switch, split tunneling
  platform/
    vpn_channel.dart   # MethodChannel + EventChannel to native
android/  ...VpnService + tunnel lib (Kotlin)
ios/      ...NEPacketTunnelProvider extension + tunnel lib (Swift)
```
State management: Riverpod or Bloc. The connection state machine (`disconnected → connecting → connected → disconnecting → error`) should live in Dart, driven by native events.

### 6.5 Must-have features users expect
- **Kill switch** (block all traffic if tunnel drops — configured natively via `includeAllNetworks` / route rules).
- **Auto-connect** on untrusted Wi-Fi.
- **Split tunneling** (per-app routing) — Android supports it natively; iOS is very limited.
- **Protocol switch** + **auto-fallback**.
- **DNS-leak / IPv6-leak protection.**
- **No-logs stance** — and actually honor it (it's a legal + marketing pillar).

---

## 7. Store, legal & operational reality (don't skip)

- **Apple:** VPN apps need the **Network Extensions** entitlement and must be published by an **organization** Apple Developer account (not individual) — Apple enforces this for VPNs. Review is strict about privacy disclosures and "no selling user data."
- **Google Play:** must use the `VpnService` API, declare it, complete the extra VPN/privacy declarations, and can't intercept traffic deceptively.
- **Privacy policy + no-logs**: legally required and scrutinized. Say what you log and mean it.
- **Jurisdiction** affects your logging obligations and marketing claims — worth real legal advice before launch.
- **Abuse handling:** exit nodes *will* attract abuse complaints (DMCA, fraud). You need an abuse-response process or hosts will drop you.

---

## 8. Recommended build order (phased)

**Phase 0 — Prototype (1 server, WireGuard, no billing)**
1. Spin up one WireGuard VPS by hand; hand-craft one client config.
2. New Flutter app; integrate `wireguard_flutter`; hard-code the config.
3. Get Connect/Disconnect + live byte counters working on a real Android device, then iOS. *This proves the hardest part (native tunnel) end to end.*

**Phase 1 — Backend + dynamic configs**
4. Build auth + `/servers` + `/connect` (dynamic WireGuard peer creation).
5. App fetches server list and configs from backend instead of hard-coding.

**Phase 2 — Monetization**
6. Integrate RevenueCat, build the paywall, gate `/connect` on entitlement via webhook.

**Phase 3 — Scale & resilience**
7. Terraform/Ansible the fleet to multiple countries.
8. Add OpenVPN as fallback protocol; add auto-fallback logic.

**Phase 4 — Differentiate**
9. Add obfuscated/"custom" mode (AmneziaWG or XRay) as a premium feature.
10. Kill switch, auto-connect, split tunneling, polish, store submission.

---

## 9. Concrete starting libraries (Flutter)

| Need | Package / lib |
|------|---------------|
| WireGuard tunnel | `wireguard_flutter` / `wireguard_dart` (wraps `wireguard-apple` + `wireguard-android`) |
| OpenVPN tunnel | `openvpn_flutter` (wraps TunnelKit/OpenVPNAdapter + ics-openvpn) |
| Custom Go core → both platforms | `gomobile bind` |
| Billing | `purchases_flutter` (RevenueCat) |
| Secure key/token storage | `flutter_secure_storage` |
| State | `flutter_riverpod` or `flutter_bloc` |
| Backend | Go (`net`, `wireguard-go`, `wgctrl`) or Node.js + Postgres |
| Fleet automation | Terraform + Ansible; wg-easy / Netmaker / Firezone (WG), OpenVPN AS |

---

## 10. TL;DR

- A "Flutter VPN" = **Flutter UI + native OS tunnel extension + your servers + your backend.** Dart can't tunnel; the native extension does.
- **Ship WireGuard first** — fastest path to a real product.
- **Add OpenVPN** as the TCP/443 stealth fallback.
- **"Custom" = an obfuscation layer (AmneziaWG/XRay/wstunnel) over vetted crypto**, not homemade encryption. Add it as a premium differentiator, not at v1.
- The non-tunnel plumbing (auth, server fleet, RevenueCat billing, no-logs policy, store entitlements) is the same for all three and is where most of the actual work lives.
