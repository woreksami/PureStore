# PureStore

> **Pure installs. Pure control. Pure you.**

PureStore is a clean, themeable fork of TrollStore — an IPA installer for iOS that uses the CoreTrust permanent signing method.

---

## What Makes It Pure?

**Pure** means:
- 🫧 **Minimal** — No bloat, no noise. Every pixel has a reason.
- 💎 **Transparent** — Open source, no hidden behaviour.
- 🎨 **Yours** — Custom themes, your scripts, your way.
- 🔒 **Clean** — No ads, no telemetry, no nonsense.

The name comes from the idea that installing apps should be *pure and simple* — no jailbreak wizardry, no sketchy repos, just drop an IPA and go.

---

## Features

### Custom Themes
Pick from 4 built-in themes or import your own `.pstheme` JSON:
| Theme | Vibe |
|-------|------|
| **Pure** (default) | Crisp blue, light and clean |
| **Ocean** | Deep navy + teal, OLED-optimised |
| **Sakura** | Soft pinks, blossom vibes |
| **Midnight** | Pure OLED black + violet |

**Theme JSON format:**
```json
{
  "name": "My Theme",
  "description": "Custom vibes",
  "author": "you",
  "accentColor": "#FF6B6B",
  "backgroundColor": "#1A1A2E",
  "cardColor": "#16213E",
  "textColor": "#EAEAEA",
  "subtitleColor": "#888888",
  "blurredBackground": true,
  "cornerRadius": 16,
  "iconStyle": "squircle",
  "identifier": "com.you.mytheme"
}
```

### User Scripts
Import and manage `.psscript` or `.sh` files from the **Scripts** tab.

**Script JSON format:**
```json
{
  "name": "My Script",
  "description": "Does something cool",
  "author": "you",
  "version": "1.0",
  "type": "bash",
  "content": "#!/bin/bash\necho Hello from PureStore!"
}
```
Or use the frontmatter format: JSON metadata + `---` separator + raw script.

---

## Building

### Requirements
- macOS 13+
- [Theos](https://theos.dev)
- Xcode Command Line Tools

### Build locally
```bash
make package FINALPACKAGE=1
```

### GitHub Actions
Push to `main` or create a tag (`v1.0.0`) — Actions will build the IPA automatically.  
Check the **Releases** page for the compiled IPA.

---

## Credits
- **TrollStore** by [opa334](https://github.com/opa334) — the foundation  
- PureStore team — themes, scripts, UI improvements

## License
GPL-3.0 — see LICENSE
