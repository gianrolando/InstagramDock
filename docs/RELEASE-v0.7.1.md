# InstagramDock 0.7.1

InstagramDock now opens the native macOS file picker when Instagram asks for a file, including when creating a post or changing a profile photo. The picker allows multiple files when the page requests them.

## Installation

Download `InstagramDock-0.7.1-macOS-universal.zip` and extract it. Quit the previous version with Command+Q and replace `InstagramDock.app` in Applications. The build supports Apple Silicon and Intel Macs running macOS 13 or later. The ZIP includes an English README and the MIT license.

The app is ad hoc signed and not notarized. If macOS blocks the first launch, see the instructions in `README.txt`.

To verify the download, place the ZIP and its checksum file in the same folder and run:

```sh
shasum -a 256 -c InstagramDock-0.7.1-macOS-universal.zip.sha256
```

## Validation

The universal build and all 31 existing badge and layout tests passed. The app delegate exposes the file picker callback expected by WebKit. Uploads with a signed-in Instagram account have not been verified.
