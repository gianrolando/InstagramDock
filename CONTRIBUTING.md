# Contributing

Small, focused issues and pull requests are welcome. Use a Mac with Apple's Swift toolchain and read README.md before building.

Run `bash scripts/test.sh` and `bash scripts/build.sh universal` before proposing code changes. For detector changes add a regression case to Tests/test_detector.swift. Avoid depending on unstable CSS class names, collecting private messages or logging credentials.

Before a release, manually verify login, persistent session after relaunch, unread increments, the final 1 → 0 transition (wait roughly 10 seconds), window close/reopen, ⌘Q, ⌘⇧D and external-link handling. Test both CPU architectures when hardware is available; report any untested platform honestly.

Bug reports should include macOS version, CPU type, app version, steps and a redacted diagnostic report. Never include cookies, access tokens, private message text or account screenshots. Contributions must be compatible with the MIT license. Be respectful and constructive.
