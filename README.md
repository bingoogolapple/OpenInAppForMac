# OpenInAppForMac

[![Latest Release](https://img.shields.io/github/v/release/bingoogolapple/OpenInAppForMac)](../../releases/latest)
[![Build](https://img.shields.io/github/actions/workflow/status/bingoogolapple/OpenInAppForMac/release.yml)](../../actions/workflows/release.yml)
[![License](https://img.shields.io/github/license/bingoogolapple/OpenInAppForMac)](LICENSE)
[![Downloads](https://img.shields.io/github/downloads/bingoogolapple/OpenInAppForMac/total)](../../releases/latest)
[![Platform](https://img.shields.io/badge/platform-macOS-000000)](https://www.apple.com/macos)

**🌐 [中文文档](README.zh-CN.md)**

A collection of AppleScript-based macOS utilities that quickly open the current Finder directory in your favorite editor or terminal.

- **Editors:** VSCode, CodeBuddy (incl. China version), Cursor, Devin / Windsurf, Kiro, Qoder (incl. China version), Trae (incl. China version), Antigravity, Zed, CatPaw (Employee / Public) and more
- **Terminals:** Terminal, iTerm2, Warp, Ghostty, WezTerm, Kitty and more

> Some apps provide separate "China / Public" entries (e.g. `OpenInCodeBuddyCN`, `OpenInQoderCN`, `OpenInTraeCN`, `OpenInCatPawAI`) to fit different distribution channels. See **Directory Structure** below.

## Demo

![Drag the app into the Finder toolbar](images/OpenInAppForMac.webp)

## For Users

If you just want to use these utilities, follow the steps below — no need to look at the source code.

### Installation

1. Go to the [Releases](../../releases/latest) page, download the desired `OpenInXxx.app` from the Assets of the latest release, and unzip it into the **Applications** folder.
2. Hold the `command` key and drag the extracted `OpenInXxx.app` onto the Finder toolbar.

> Holding `command` while dragging "pins" the app to the toolbar instead of moving the file.

> If you see "cannot be opened because the developer cannot be verified" the first time you click the toolbar icon, that's macOS Gatekeeper protecting unsigned apps. Either right-click the app → Open, or go to **System Settings → Privacy & Security → Open Anyway**. After allowing it once, it works normally (these utilities are not developer-signed, which is normal).

### Usage

In any Finder window, click the corresponding icon on the toolbar to open that folder in the matching app.

## For Maintainers

If you are a repo maintainer or want to modify the source and re-export the apps yourself, read on.

### Directory Structure

```
release.sh                       # One-click compile src/*.scpt into same-name .app and replace icons
src/                             # Each app has a pair of same-name .scpt (source) and .icns (icon)
  OpenInVSCode.scpt/.icns        # VSCode
  OpenInCodeBuddy.scpt/.icns     # CodeBuddy International
  OpenInCodeBuddyCN.scpt/.icns   # CodeBuddy China
  OpenInCursor.scpt/.icns        # Cursor
  OpenInDevin.scpt/.icns         # Devin/Windsurf
  OpenInTerminal.scpt/.icns      # Built-in Terminal.app
  OpenIniTerm2.scpt/.icns        # iTerm2
  OpenInWarp.scpt/.icns          # Warp
  OpenInGhostty.scpt/.icns       # Ghostty
  OpenInWezTerm.scpt/.icns       # WezTerm
  OpenInKitty.scpt/.icns         # Kitty
  OpenInKiro.scpt/.icns          # Kiro
  OpenInQoder.scpt/.icns         # Qoder International
  OpenInQoderCN.scpt/.icns       # Qoder China
  OpenInTrae.scpt/.icns          # Trae International
  OpenInTraeCN.scpt/.icns        # Trae China
  OpenInAntigravity.scpt/.icns   # Google Antigravity
  OpenInZed.scpt/.icns           # Zed
  OpenInCatPaw.scpt/.icns        # CatPaw Employee
  OpenInCatPawAI.scpt/.icns      # CatPaw Public
.github/workflows/
  release.yml                    # On tag push, auto build and publish zip to GitHub Releases
```

When adding a new app, just drop a same-name `.scpt` and `.icns` pair into `src/`. `release.sh` and `release.yml` will automatically compile, package, and publish all scripts — no build logic changes needed.

### Export App from Source

One-click export (recommended): the `release.sh` at the repo root automatically compiles `src/*.scpt` into same-name `.app` and replaces the icons, equivalent to all the manual steps below:

```bash
./release.sh
```

The default behavior of `osacompile` used by the script already matches the "do not select" options below: no startup screen, quit after running (no stay-open), keep source, no developer signing — so no extra flags are needed.

Manual export (if you want step-by-step confirmation):

1. Right-click `src/OpenInXxx.scpt` → Open With → Script Editor → File → Export.
2. Set "File Format" to "Application".
3. Deselect all "Options":
   - **Show startup screen** — Not needed. This is an instant action, no splash screen required.
   - **Stay open after run handler** — Not needed. The script finishes (opens Xxx) and ends; there's no background task to keep running.
   - **Run only** — Leave unchecked. Keep the script source for future edits; checking it strips the source (smaller file, but no longer editable).
4. Set "Code signing" to "Don't Code Sign":
   - These tools are for local personal use, not published to the App Store or distributed to others, so no need to verify identity or prevent tampering.
   - If you choose a signing option without a matching Apple Developer certificate, export fails outright, so "Don't Code Sign" is the hassle-free choice.

### Usage

- Hold the `command` key and drag the `OpenInXxx.app` exported above onto the Finder toolbar;
- In a Finder window, click the toolbar icon to open the current folder in the matching app.

### Replace App Icon

> When exporting with `./release.sh`, the icon is already replaced automatically. This section is only needed when exporting manually via Script Editor or when you want a different icon.

1. `command + C` to copy the corresponding `.icns` icon file.
2. Right-click `OpenInXxx.app` → Get Info.
3. Click the small icon at the top-left of the Info panel (not the preview area at the bottom).
4. `command + V` to paste; the icon takes effect immediately.

### Build & Release

Releases are distributed via GitHub Releases; zips are no longer stored in the repo. The flow:

1. Run `./release.sh` locally once to confirm `.app` and zip are generated correctly (optional, for self-testing).
2. Create and push a version tag, e.g.:

   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

3. After pushing, `.github/workflows/release.yml` runs `./release.sh` on a macOS runner and uploads all generated `OpenInXxx.zip` (one per `.scpt`, e.g. `OpenInVSCode.zip`, `OpenInCursor.zip`, …) to the Release for that tag.

Users always download the latest version from the [Releases](../../releases/latest) page; no zip needs to be kept in the repo.

## License

This project is open-sourced under the [MIT License](LICENSE); feel free to use, modify, and distribute it.

## Author Contact

| Homepage | Email |
| ------------- | ------------ |
| <a  href="https://www.bingoogolapple.cn" target="_blank">bingoogolapple.cn</a>  | <a href="mailto:bingoogolapple@gmail.com" target="_blank">bingoogolapple@gmail.com</a> |

| WeChat ID | WeChat Group | Official Account |
| ------------ | ------------ | ------------ |
| <img width="180" alt="Personal WeChat ID" src="https://github.com/bingoogolapple/bga-god-assistant-config/raw/main/images/BGAQrCode.png"> | <img width="180" alt="WeChat Group" src="https://github.com/bingoogolapple/bga-god-assistant-config/raw/main/images/WeChatGroup1QrCode.jpg"> | <img width="180" alt="Official Account" src="https://github.com/bingoogolapple/bga-god-assistant-config/raw/main/images/GongZhongHao.png"> |

| Personal QQ | QQ Group |
| ------------ | ------------ |
| <img width="180" alt="Personal QQ ID" src="https://github.com/bingoogolapple/bga-god-assistant-config/raw/main/images/BGAQQQrCode.jpg"> | <img width="180" alt="QQ Group" src="https://github.com/bingoogolapple/bga-god-assistant-config/raw/main/images/QQGroup1QrCode.jpg"> |

## Support the Author

If you find the BGA series of open-source libraries or tools have saved you a lot of development time, you can scan the QR codes below to buy me a coffee. Your support will encourage me to keep creating. After donating, you can also add me on WeChat to get a free one-year membership of the [God Assistant browser extension / plugin development platform](https://github.com/bingoogolapple/bga-god-assistant-config).

| WeChat | QQ | Alipay |
| ------------- | ------------- | ------------- |
| <img width="180" alt="WeChat" src="https://github.com/bingoogolapple/bga-god-assistant-config/raw/main/images/donate-wechat.jpg"> | <img width="180" alt="QQ" src="https://github.com/bingoogolapple/bga-god-assistant-config/raw/main/images/donate-qq.jpg"> | <img width="180" alt="Alipay" src="https://github.com/bingoogolapple/bga-god-assistant-config/raw/main/images/donate-alipay.jpg"> |

## Author's Recommended Projects

* Welcome to try my first indie software product, the [God Assistant browser extension / plugin development platform](https://github.com/bingoogolapple/bga-god-assistant-config)