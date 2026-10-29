# InstagramDock 0.6

Updated release of InstagramDock, a small native macOS app that opens Instagram and displays an unread-message badge in the Dock.

- Limits the Home feed tab strip when it overlaps the right-hand profile card.
- Remembers window size and position across launches.
- Persistent local login session.
- Dock badge with delayed reset after the last unread message is read (about 10 seconds).
- Developer panel hidden by default; toggle with **Command+Shift+D** or **View → Show Developer Panel**.
- English app menus, status messages, diagnostics and documentation.
- Original icon, Swift source code and MIT license.

## Download and installation

Download **InstagramDock-0.6-macOS-universal.zip**, extract it, and drag InstagramDock.app to Applications. Requires macOS 13 or later. Includes Apple Silicon and Intel code; interactive use confirmed on Apple Silicon in earlier builds, compilation verified for Intel.

This release is **ad hoc signed and not notarized by Apple**. macOS may block it. After attempting to open it, use Privacy & Security → Open Anyway if available and you trust the project. Alternatively, build from source.

Download the `.sha256` file alongside the ZIP and run this command from their folder:

```sh
shasum -a 256 -c InstagramDock-0.6-macOS-universal.zip.sha256
```

## Limitations

The count is inferred from the website and can be affected by Instagram changes. A + means a lower bound. The app must remain running. This version does not send macOS notification banners. Website language follows Instagram settings; system-owned dialogs follow macOS settings. Not affiliated with Instagram or Meta.

## Validation

20 synthetic detector cases and 11 synthetic layout cases pass, including English and Italian website labels and the final 1 → 0 reset. Universal build and ad hoc signature verified. The layout tests reproduce the reported screenshot geometry, not the live Instagram DOM. Visual confirmation on the affected account is still needed.
