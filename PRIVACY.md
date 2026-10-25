# Privacy

InstagramDock loads https://www.instagram.com/ in WKWebView. Login and service content are handled by Instagram/Meta, whose own privacy policies apply. The app uses WebKit's persistent local website data store for cookies and login state. These data are not part of the source tree or release archive.

This version includes no developer-operated server, analytics, advertising SDK or custom telemetry. It does not extract passwords. Instagram itself makes its normal network requests; this app is not an offline or anonymous client.

The injected detector inspects page elements and accessibility labels locally to infer unread counts. It sends the native app state, numeric counts and technical flags; the native diagnostic dialog adds timestamp, app version and persistence information. The diagnostic payload is not designed to include names, passwords, message bodies or full URLs. It is copied to the clipboard only when you choose Copy diagnostics; review it before sharing. Clipboard contents may be accessible to other software or synchronized by your macOS configuration.

To end a session, use Instagram's sign-out control in the app. Removing the app alone may leave WebKit website data in your user Library. Never attach browser profiles, cookie databases, session storage, credentials or private screenshots to issues.

This description applies to the code in this repository, not to Meta's data practices or modified third-party builds.
