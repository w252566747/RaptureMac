# RaptureMac

[简体中文](README.md) · [日本語](README.ja.md)

A native macOS screenshot and floating-pin tool. Click a window or drag a region, then keep the result on screen as a movable floating image.

> This is an unofficial project inspired by Windows Rapture. It is not affiliated with or endorsed by the original software's author.

## Features

- Window capture: Click a window to capture it. Overlapping windows remain in the image exactly as they appear on screen.
- Area capture: Drag to capture a custom region. Click an empty desktop area to capture the current display.
- Floating pins: Captures remain at their original window position and can be moved from either the image or its title bar.
- Multiple captures: Keep several pinned images open. Right-click the Dock icon and choose **Next Capture** to create another one.
- Markup: Hold `⌘` while dragging to draw a red freehand line; hold `⌘⇧` while dragging for a horizontal or vertical line.
- Editing: Undo the latest line, copy, save as PNG, or close a pinned image from its context menu.
- Double-click close: Double-click a pinned image to copy the annotated result to the clipboard and close it.

## Usage

1. Open `RaptureMac.app`; the first capture mode starts immediately.
2. Click a window or drag a region.
3. Move, annotate, or right-click the resulting floating image to copy or save it.
4. To create another capture, right-click the RaptureMac Dock icon and choose **Next Capture**.

## Permission

RaptureMac needs macOS Screen Recording permission:

**System Settings → Privacy & Security → Screen & System Audio Recording → RaptureMac**

After allowing permission, quit and reopen the app.

## Build locally

Requirements: macOS 14+, Xcode Command Line Tools, Swift, and ScreenCaptureKit.

```zsh
git clone https://github.com/YOUR_ACCOUNT/RaptureMac.git
cd RaptureMac
./build-app.sh
open .build/RaptureMac.app
```

The app is built at `.build/RaptureMac.app`. This is an ad-hoc development build. For wider distribution, Developer ID signing and notarization are recommended.

## Security notice: unsigned and Gatekeeper

The current Release is **not signed with an Apple Developer ID and is not notarized by Apple**. macOS Gatekeeper may therefore show an “unidentified developer” or “Apple cannot check it for malicious software” warning the first time it is opened.

- Download only from this project's official GitHub Releases page.
- Verify the SHA-256 checksum published with the Release after downloading.
- Only if you trust the source and checksum, manually allow the app in **System Settings → Privacy & Security → Open Anyway**.
- Managed work or school Macs may block unsigned apps completely. In that case, build from source or wait for a future signed and notarized release.

## Technology

- Swift + AppKit
- ScreenCaptureKit
- CoreGraphics
- No third-party dependencies

## License

[MIT](LICENSE)
