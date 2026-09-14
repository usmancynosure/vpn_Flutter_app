# Gemini image prompts for Shield VPN

Generate these in Gemini (or any image model), export as **PNG**, and drop them
into this folder with the **exact filenames** below. The app already references
them and shows a gradient fallback until they exist — so it runs either way.

Target: modern iOS VPN app, soft lavender UI, indigo (#5A4FF3) accent.

---

## 1. `map_bg.png`  — home screen background
**Use:** faint backdrop behind the location pin on the Home tab.
**Size:** 1080 × 1080 px (square), transparent or light background.

> A soft, minimal 3D isometric world map made of a subtle light-grey dotted
> grid on a very light lavender (#ECEBFA) background. Thin faint gridlines,
> gentle perspective as if looking across a plane. Extremely light and airy,
> low contrast, lots of negative space, no text, no labels, no country names.
> Pastel, clean, Apple-like, flat pastel illustration. The center-top area
> should be nearly empty so a UI pin can sit on top. Soft, blurred, decorative.

---

## 2. `globe.png`  — servers screen hero
**Use:** glowing globe inside the dark hero card on the Servers tab.
**Size:** 1000 × 1000 px, **transparent background** (PNG with alpha).

> A glowing translucent 3D globe made of a fine network of blue dots and
> connecting lines, wireframe continents lit in bright electric blue and cyan,
> radiant glow and light particles around it, floating in dark empty space.
> Futuristic, high-tech, cinematic, deep navy-to-black surroundings.
> Transparent background outside the glow. Centered, symmetrical, premium.
> No text, no location pins (the app overlays its own pins), no UI.

---

## Optional extras (nice-to-have later)

### 3. `connected_glow.png` — subtle aura behind the power button (transparent)
> A soft circular radial glow, indigo to transparent, faint, for layering
> behind a circular button. Transparent PNG, no hard edges, just a gentle halo.

### 4. App icon (1024 × 1024, no transparency — for the store)
> A minimal app icon: a rounded shield silhouette in a soft indigo-to-violet
> gradient (#5A4FF3 to #7B6CF6), a small power symbol subtly embossed in the
> center, soft inner glow, on a clean light background. Flat, modern, iOS-style,
> no text. Crisp, centered, premium.

---

## Tips
- Ask Gemini for **PNG with transparent background** explicitly for globe.png
  and connected_glow.png.
- Keep them light/low-contrast so the UI text stays readable on top.
- After adding files, run `flutter pub get` then hot-restart — no code changes
  needed; the app swaps the gradient fallback for your image automatically.
