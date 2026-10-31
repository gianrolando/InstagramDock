# InstagramDock

A small native macOS app that opens Instagram and displays an unread-message badge in the Dock.

[Download macOS app](../../raw/refs/heads/main/downloads/InstagramDock-0.7-macOS-universal.zip) · [Installation](#installation) · [Build](#build-from-source) · [Privacy](PRIVACY.md)

Built with Swift, AppKit and WKWebView. No Electron, Python, Node.js or third-party libraries.
Independent community project, not affiliated with, endorsed by or sponsored by Instagram or Meta. Instagram and Meta names belong to their respective owners. The MIT license covers this project's code and original assets, not Instagram's website, content or trademarks.

## Features

- Instagram website in its own native window, with a persistent local login.
- Dock unread badge; clears after roughly 10 seconds when the Messages counter disappears.
- Closing the window keeps the app running. Click its Dock icon to reopen; **⌘Q** quits.
- Developer panel hidden by default: **⌘⇧D**, or **View → Show Developer Panel**.
- Keeps the Home feed tab strip clear of the right-hand profile column when it overlaps.
- Remembers window size and position across app launches.
- Native Dock badge test and diagnostic report.
- **InstagramDock → About InstagramDock**: app icon, version, copyright, GitHub link and bundled MIT license.

## Installation

Requires **macOS 13 or later** and an Internet connection. Download the [ready-to-use universal app ZIP](../../raw/refs/heads/main/downloads/InstagramDock-0.7-macOS-universal.zip), extract it, and drag **InstagramDock.app** into Applications. The ZIP includes an English README and the MIT license. A [SHA-256 checksum](downloads/InstagramDock-0.7-macOS-universal.zip.sha256) is provided alongside it. Future versions may also be published under **Releases**. Open it and sign in on Instagram's own page.

The current package is **0.7**, universal for Apple Silicon and Intel. Intel compilation is checked; interactive use has only been confirmed on Apple Silicon. The app is ad hoc signed, **not Developer ID signed or notarized**. macOS may block downloaded builds: after attempting to open it, use **System Settings → Privacy & Security → Open Anyway** if offered and you trust the source. Managed Macs may disallow this. Building from source is another option. Do not disable Gatekeeper globally.

All app-owned menus, status messages, diagnostics and documentation are in English. Instagram content follows your Instagram language settings; macOS-owned dialogs follow system settings. The detector still recognizes English and Italian website labels.

## Badge limitations

The badge reads counters and accessibility labels from the loaded website; it does not use an official Instagram unread-count API. A **+** means a lower bound from visible unread conversations, not an exact message total. A dot means unread activity without a readable number. If the page cannot be inspected, the previous count may remain until reliable information returns. The zero reset uses a stable Messages link without a counter as a heuristic.

Instagram interface changes, language, connectivity and WebKit background scheduling can affect results. The app must remain running; it cannot update after **⌘Q**. This release provides a Dock badge, **not macOS notification banners**, and does not promise an exact total for every account. Facebook-based login popups and some media features may be unavailable with the current navigation restrictions.

## Shortcuts

| Shortcut | Action |
|---|---|
| ⌘⇧D | Toggle developer panel |
| ⌘1 | Instagram home |
| ⌘2 | Messages |
| ⌘R | Reload |
| ⌘0 | Show window |
| ⌘Q | Quit |

## Build from source

On a Mac, install Xcode or Apple's Command Line Tools (`xcode-select --install`). From the project directory:

```sh
bash scripts/test.sh
bash scripts/build.sh            # this Mac's architecture
bash scripts/build.sh universal  # Apple Silicon + Intel
open build/InstagramDock.app
```

Or double-click `Build_Mac.command` for a local build. All resources, including the original icon, are generated or copied from this repository. Build outputs are excluded from Git.

```sh
bash scripts/package.sh universal
```

Creates the app ZIP and its SHA-256 checksum in `dist/`. GitHub Actions runs detector tests and builds on pushes and pull requests. Manually running the workflow also produces a downloadable package artifact; it does not publish a release automatically.

## Development

- `Sources/main.swift`: native window, menus, WebKit bridge and Dock badge.
- `Resources/detector.js`: unread detection and zero-reset heuristic.
- `Resources/layout.js`: geometry-based Home tab-strip width correction.
- `Tests/test_detector.swift`: synthetic DOM and transition regressions using JavaScriptCore.
- `scripts/`: reproducible build, tests, icon generation and packaging.

Tests cover simulated pages, not a live Instagram account. Before a release, check login, a new unread message, reading the final message, reopening the window and developer shortcuts on real hardware. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE). Copyright © 2026 Gianrolando Scaringi.
