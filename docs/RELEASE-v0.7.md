# InstagramDock 0.7

This release adds a native **About InstagramDock** window to the application menu.

- Original app icon and current version.
- App description, copyright and MIT license information.
- Independent-project notice, with no affiliation to Instagram or Meta.
- **GitHub** button and **License** button. The full license is included for offline reading.
- Previous unread Dock badge, Home layout correction and remembered window size/position retained.

## Installation

Download **InstagramDock-0.7-macOS-universal.zip**, extract it, quit any previous version with Command+Q, and replace InstagramDock.app in Applications. Requires macOS 13 or later. Universal Apple Silicon and Intel build.

The ZIP contains the ready-to-use app, an English README and the MIT license. Download the SHA-256 file alongside it to verify:

```sh
shasum -a 256 -c InstagramDock-0.7-macOS-universal.zip.sha256
```

This build is ad hoc signed and not notarized by Apple. If macOS blocks it, after attempting to open it use System Settings → Privacy & Security → Open Anyway, if available and you trust the source. Do not disable Gatekeeper globally.

## Limitations

Badge counts are inferred from Instagram's loaded website. A + means a lower bound; the app must remain running. This app does not provide macOS notification banners. Website and system-dialog languages follow their own settings. Intel compilation is checked; Intel hardware testing is not performed. Not affiliated with or endorsed by Instagram or Meta.

## Validation

31 synthetic badge/layout tests, universal compilation, bundle contents, signature and checksum are checked. See the included validation notes for About-window inspection. Live Instagram account behavior still depends on the website.
