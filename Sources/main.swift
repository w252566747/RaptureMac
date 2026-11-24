import AppKit
import CoreGraphics
import ScreenCaptureKit

enum DisplayLanguage: String, CaseIterable {
    case japanese = "ja"
    case chinese = "zh-Hans"
    case english = "en"

    var title: String {
        switch self {
        case .japanese: return "日本語"
        case .chinese: return "简体中文"
        case .english: return "English"
        }
    }
}

enum L {
    private static let languageKey = "displayLanguage"
    static var language: DisplayLanguage {
        get {
            if let raw = UserDefaults.standard.string(forKey: languageKey), let value = DisplayLanguage(rawValue: raw) { return value }
            let preferred = Locale.preferredLanguages.first ?? "en"
            return preferred.hasPrefix("ja") ? .japanese : (preferred.hasPrefix("zh") ? .chinese : .english)
        }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: languageKey) }
    }

    static func text(_ key: String) -> String {
        let table: [String: (String, String, String)] = [
            "newCapture": ("新規キャプチャ", "新建截图", "New Capture"),
            "nextCapture": ("次のキャプチャ", "下一张截图", "Next Capture"),
            "settings": ("機能設定…", "功能设置…", "Feature Settings…"),
            "quit": ("終了", "退出", "Quit"),
            "language": ("表示言語", "显示语言", "Display Language"),
            "settingsTitle": ("RaptureMac 機能設定", "RaptureMac 功能设置", "RaptureMac Feature Settings"),
            "clickWindow": ("クリックしたウィンドウをキャプチャ", "单击窗口截图", "Capture clicked window"),
            "dragSelection": ("ドラッグで範囲キャプチャ", "拖拽区域截图", "Drag to capture area"),
            "alwaysOnTop": ("貼り付け画像を常に前面に表示", "截图始终置顶", "Keep screenshots on top"),
            "moveSticky": ("ドラッグで貼り付け画像を移動", "拖拽移动截图", "Drag to move screenshot"),
            "doubleClickClose": ("ダブルクリックで貼り付け画像を閉じる", "双击关闭截图", "Double-click to close screenshot"),
            "freehand": ("⌘ ドラッグで赤いフリーハンド線", "⌘ 拖拽红色自由线", "⌘ drag for red freehand"),
            "straightLine": ("⌘⇧ ドラッグで水平・垂直の直線", "⌘⇧ 拖拽水平或垂直直线", "⌘⇧ drag for horizontal/vertical line"),
            "fileActions": ("コピーと PNG/JPEG/BMP 保存", "复制与 PNG/JPEG/BMP 保存", "Copy and save PNG/JPEG/BMP"),
            "transform": ("回転・反転・透明度", "旋转、翻转与透明度", "Rotate, flip and opacity"),
            "editing": ("裁切・文字・元に戻す/やり直す", "裁切、文字、撤销/重做", "Crop, text, undo/redo"),
            "imageImport": ("ローカル画像・クリップボード画像を開く", "打开本地或剪贴板图片", "Open local or clipboard image"),
            "mergeSticky": ("複数貼り付け画像を連結", "合并多张截图", "Merge screenshots"),
            "undo": ("元に戻す", "撤销", "Undo"),
            "copy": ("コピー", "复制", "Copy"),
            "save": ("保存…", "保存…", "Save…"),
            "close": ("閉じる", "关闭", "Close"),
            "closeScreenshot": ("スクリーンショットを閉じる", "关闭截图", "Close screenshot"),
            "rangeCapture": ("範囲キャプチャ", "区域截图", "Area Capture"),
            "screenCapture": ("画面キャプチャ", "屏幕截图", "Screen Capture"),
            "windowCapture": ("ウィンドウキャプチャ", "窗口截图", "Window Capture")
        ]
        guard let value = table[key] else { return key }
        switch language { case .japanese: return value.0; case .chinese: return value.1; case .english: return value.2 }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var captureController: CaptureController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.image = NSImage(systemSymbolName: "camera.viewfinder", accessibilityDescription: "Rapture Mac")
        rebuildMenus()
        DispatchQueue.main.async { self.startCapture() }
    }

    @objc private func startCapture() {
        // Each capture becomes an independent pasted image; existing images stay open.
        guard captureController == nil else { return }
        captureController = CaptureController { [weak self] in self?.captureController = nil }
        captureController?.begin()
    }

    @objc private func quit() { NSApp.terminate(nil) }
    @objc private func openSettings() { FeatureSettingsWindow.shared.show() }

    func rebuildMenus() {
        let menu = NSMenu()
        menu.addItem(withTitle: L.text("newCapture"), action: #selector(startCapture), keyEquivalent: "")
        menu.addItem(withTitle: L.text("settings"), action: #selector(openSettings), keyEquivalent: ",")
        menu.addItem(.separator())
        menu.addItem(withTitle: L.text("quit"), action: #selector(quit), keyEquivalent: "q")
        statusItem?.menu = menu
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if StickyImagePanel.hasOpenSticky {
            StickyImagePanel.showOpenStickies()
        } else {
            startCapture()
        }
        return true
    }

    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        let menu = NSMenu()
        menu.addItem(withTitle: L.text("nextCapture"), action: #selector(startCapture), keyEquivalent: "").target = self
        menu.addItem(withTitle: L.text("settings"), action: #selector(openSettings), keyEquivalent: "").target = self
        return menu
    }
}

final class FeatureSettings {
    static let shared = FeatureSettings()
    private let defaults = UserDefaults.standard
    let items = ["clickWindow", "dragSelection", "alwaysOnTop", "moveSticky", "doubleClickClose", "freehand", "straightLine", "fileActions", "transform", "editing", "imageImport", "mergeSticky"]
    func enabled(_ key: String) -> Bool { defaults.object(forKey: key) as? Bool ?? true }
    func set(_ value: Bool, _ key: String) { defaults.set(value, forKey: key) }
}

final class FeatureSettingsWindow: NSObject {
    static let shared = FeatureSettingsWindow()
    private var panel: NSPanel?
    func show() {
        if let panel { panel.makeKeyAndOrderFront(nil); return }
        let stack = NSStackView(); stack.orientation = .vertical; stack.alignment = .leading; stack.spacing = 10
        stack.edgeInsets = NSEdgeInsets(top: 18, left: 20, bottom: 18, right: 20)
        let languageRow = NSStackView(); languageRow.orientation = .horizontal; languageRow.spacing = 10
        languageRow.addArrangedSubview(NSTextField(labelWithString: L.text("language")))
        let languagePicker = NSPopUpButton(frame: .zero, pullsDown: false)
        DisplayLanguage.allCases.forEach { languagePicker.addItem(withTitle: $0.title) }
        languagePicker.selectItem(at: DisplayLanguage.allCases.firstIndex(of: L.language) ?? 0)
        languagePicker.target = self; languagePicker.action = #selector(selectLanguage(_:))
        languageRow.addArrangedSubview(languagePicker); stack.addArrangedSubview(languageRow)
        for key in FeatureSettings.shared.items {
            let box = NSButton(checkboxWithTitle: L.text(key), target: self, action: #selector(toggle(_:)))
            box.identifier = NSUserInterfaceItemIdentifier(key); box.state = FeatureSettings.shared.enabled(key) ? .on : .off
            stack.addArrangedSubview(box)
        }
        let panel = NSPanel(contentRect: CGRect(x: 0, y: 0, width: 420, height: 485), styleMask: [.titled, .closable], backing: .buffered, defer: false)
        panel.title = L.text("settingsTitle"); panel.contentView = stack; panel.isReleasedWhenClosed = false; panel.center(); panel.makeKeyAndOrderFront(nil)
        self.panel = panel
    }
    @objc private func toggle(_ sender: NSButton) { if let key = sender.identifier?.rawValue { FeatureSettings.shared.set(sender.state == .on, key) } }
    @objc private func selectLanguage(_ sender: NSPopUpButton) {
        guard sender.indexOfSelectedItem >= 0 else { return }
        L.language = DisplayLanguage.allCases[sender.indexOfSelectedItem]
        (NSApp.delegate as? AppDelegate)?.rebuildMenus()
        panel?.close(); panel = nil; show()
    }
}

final class CaptureController {
    private var panels: [CaptureOverlayPanel] = []
    private let onFinish: () -> Void

    init(onFinish: @escaping () -> Void) { self.onFinish = onFinish }

    func begin() {
        for screen in NSScreen.screens {
            let panel = CaptureOverlayPanel(screen: screen) { [weak self] selection, sourceScreen in
                self?.finish(selection: selection, on: sourceScreen, title: L.text("rangeCapture"))
            } onClick: { [weak self] point, sourceScreen in
                self?.captureWindow(at: point, on: sourceScreen)
            } onCancel: { [weak self] in
                self?.cancel()
            }
            panels.append(panel)
            panel.orderFrontRegardless()
            panel.makeKey()
        }
        NSApp.activate(ignoringOtherApps: true)
    }

    private func captureWindow(at point: CGPoint, on screen: NSScreen) {
        guard FeatureSettings.shared.enabled("clickWindow") else { return }
        dismissOverlays()
        onFinish()

        // CGWindowList is ordered from the visually frontmost window downwards.
        // The screen recording is cropped afterwards, so overlapping windows remain
        // in the captured image exactly as they appeared on screen.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [self] in
            let desktopTop = NSScreen.screens.map { $0.frame.maxY }.max() ?? screen.frame.maxY
            // CGWindowList bounds use macOS display points, even on a Retina display.
            // ScreenCaptureKit pixels are derived later by finish(_:).
            let displayOrigin = CGPoint(x: screen.frame.minX,
                                        y: desktopTop - screen.frame.maxY)
            let probe = CGPoint(x: displayOrigin.x + point.x,
                                y: displayOrigin.y + (screen.frame.height - point.y))
            let ownPID = Int32(ProcessInfo.processInfo.processIdentifier)
            let windows = (CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]]) ?? []
            guard let info = windows.first(where: { info in
                let layer = (info[kCGWindowLayer as String] as? NSNumber)?.intValue ?? 1
                let alpha = (info[kCGWindowAlpha as String] as? NSNumber)?.doubleValue ?? 0
                let pid = (info[kCGWindowOwnerPID as String] as? NSNumber)?.int32Value ?? ownPID
                guard layer == 0, alpha > 0.01, pid != ownPID,
                      let dictionary = info[kCGWindowBounds as String] as? [String: Any],
                      let frame = CGRect(dictionaryRepresentation: dictionary as CFDictionary) else { return false }
                return frame.contains(probe)
            }),
            let dictionary = info[kCGWindowBounds as String] as? [String: Any],
            let windowFrame = CGRect(dictionaryRepresentation: dictionary as CFDictionary) else {
                // Clicking an empty part of the desktop keeps the old full-screen behaviour.
                self.finish(selection: CGRect(origin: .zero, size: screen.frame.size), on: screen, title: L.text("screenCapture"))
                return
            }

            let crop = CGRect(x: windowFrame.minX - displayOrigin.x,
                              y: windowFrame.minY - displayOrigin.y,
                              width: windowFrame.width,
                              height: windowFrame.height)
            let appKitOrigin = CGPoint(x: screen.frame.minX + crop.minX,
                                       y: screen.frame.minY + screen.frame.height - crop.maxY)
            let owner = info[kCGWindowOwnerName as String] as? String ?? ""
            let name = info[kCGWindowName as String] as? String ?? ""
            let title = name.isEmpty ? owner : (owner.isEmpty ? name : "\(owner) — \(name)")
            self.finish(selection: CGRect(x: crop.minX, y: screen.frame.height - crop.maxY,
                                          width: crop.width, height: crop.height),
                        on: screen, title: title.isEmpty ? L.text("windowCapture") : title,
                        fixedOrigin: appKitOrigin)
        }
    }

    private func finish(selection: CGRect, on screen: NSScreen, title: String, fixedOrigin: CGPoint? = nil) {
        guard selection.width > 2, selection.height > 2 else { cancel(); return }
        let displayID = (screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber).map { CGDirectDisplayID($0.uint32Value) } ?? CGMainDisplayID()
        let scale = screen.backingScaleFactor
        let quartzFrame = CGRect(x: selection.minX * scale,
                                 y: (screen.frame.height - selection.maxY) * scale,
                                 width: selection.width * scale,
                                 height: selection.height * scale)
        dismissOverlays()
        onFinish()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            Task { @MainActor in
                do {
                    let content = try await SCShareableContent.current
                    guard let display = content.displays.first(where: { $0.displayID == displayID }) else { return }
                    let filter = SCContentFilter(display: display, excludingWindows: [])
                    let configuration = SCStreamConfiguration()
                    configuration.capturesAudio = false
                    configuration.excludesCurrentProcessAudio = true
                    configuration.showsCursor = false
                    configuration.width = Int(screen.frame.width * scale)
                    configuration.height = Int(screen.frame.height * scale)
                    let fullImage = try await SCScreenshotManager.captureImage(contentFilter: filter, configuration: configuration)
                    guard let image = fullImage.cropping(to: quartzFrame.integral) else { return }
                    let origin = fixedOrigin ?? CGPoint(x: screen.frame.minX + selection.minX,
                                                        y: screen.frame.minY + selection.minY)
                    StickyImagePanel(image: NSImage(cgImage: image, size: selection.size), title: title, origin: origin).makeKeyAndOrderFront(nil)
                } catch {
                    NSAlert(error: error).runModal()
                }
            }
        }
    }

    private func cancel() { dismissOverlays(); onFinish() }
    private func dismissOverlays() { panels.forEach { $0.orderOut(nil) }; panels.removeAll() }
}

final class CaptureOverlayPanel: NSPanel {
    init(screen: NSScreen, onSelection: @escaping (CGRect, NSScreen) -> Void, onClick: @escaping (CGPoint, NSScreen) -> Void, onCancel: @escaping () -> Void) {
        let view = CaptureOverlayView(frame: CGRect(origin: .zero, size: screen.frame.size), onSelection: { rect in
            onSelection(rect, screen)
        }, onClick: { point in
            onClick(point, screen)
        }, onCancel: onCancel)
        super.init(contentRect: screen.frame, styleMask: .borderless, backing: .buffered, defer: false)
        contentView = view
        isOpaque = false
        backgroundColor = .clear
        level = .screenSaver
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        ignoresMouseEvents = false
        acceptsMouseMovedEvents = true
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

final class CaptureOverlayView: NSView {
    private var start: CGPoint?
    private var selection = CGRect.zero
    private let onSelection: (CGRect) -> Void
    private let onClick: (CGPoint) -> Void
    private let onCancel: () -> Void

    init(frame: CGRect, onSelection: @escaping (CGRect) -> Void, onClick: @escaping (CGPoint) -> Void, onCancel: @escaping () -> Void) {
        self.onSelection = onSelection; self.onClick = onClick; self.onCancel = onCancel
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override var acceptsFirstResponder: Bool { true }
    override func viewDidMoveToWindow() { window?.makeFirstResponder(self) }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.black.withAlphaComponent(0.32).setFill(); bounds.fill()
        if !selection.isEmpty {
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current?.compositingOperation = .clear
            NSBezierPath(rect: selection).fill()
            NSGraphicsContext.restoreGraphicsState()
            NSColor.white.setStroke(); let border = NSBezierPath(rect: selection); border.lineWidth = 1; border.stroke()
            let text = "\(Int(selection.width)) × \(Int(selection.height))"
            let attrs: [NSAttributedString.Key: Any] = [.font: NSFont.monospacedSystemFont(ofSize: 12, weight: .medium), .foregroundColor: NSColor.white]
            NSAttributedString(string: text, attributes: attrs).draw(at: CGPoint(x: selection.minX, y: selection.maxY + 6))
        }
    }

    override func mouseDown(with event: NSEvent) { start = convert(event.locationInWindow, from: nil); selection = .zero }
    override func mouseDragged(with event: NSEvent) {
        guard let start else { return }
        selection = CGRect(x: min(start.x, convert(event.locationInWindow, from: nil).x), y: min(start.y, convert(event.locationInWindow, from: nil).y), width: abs(start.x - convert(event.locationInWindow, from: nil).x), height: abs(start.y - convert(event.locationInWindow, from: nil).y))
        needsDisplay = true
    }
    override func mouseUp(with event: NSEvent) {
        if selection.width < 2 || selection.height < 2 {
            if let start { onClick(start) }
        } else if FeatureSettings.shared.enabled("dragSelection") { onSelection(selection) }
    }
    override func keyDown(with event: NSEvent) { if event.keyCode == 53 { onCancel() } else { super.keyDown(with: event) } }
}

final class StickyImagePanel: NSPanel {
    private static var openPanels: [StickyImagePanel] = []
    static var hasOpenSticky: Bool { !openPanels.isEmpty }

    static func showOpenStickies() {
        NSApp.activate(ignoringOtherApps: true)
        openPanels.forEach { $0.orderFrontRegardless() }
        openPanels.last?.makeKeyAndOrderFront(nil)
    }

    private let capturedImage: NSImage
    private var stickyView: StickyImageView!
    private var isRegistered = false

    init(image: NSImage, title: String, origin: CGPoint) {
        capturedImage = image
        let size = image.size
        let titleHeight: CGFloat = 25
        super.init(contentRect: CGRect(origin: .zero, size: CGSize(width: size.width, height: size.height + titleHeight)), styleMask: .borderless, backing: .buffered, defer: false)
        isOpaque = false; backgroundColor = .clear; hasShadow = true; level = FeatureSettings.shared.enabled("alwaysOnTop") ? .floating : .normal
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        let container = NSView(frame: CGRect(origin: .zero, size: CGSize(width: size.width, height: size.height + titleHeight)))
        let imageView = StickyImageView(frame: CGRect(origin: .zero, size: size)); imageView.image = image; imageView.imageScaling = .scaleNone
        imageView.menu = contextMenu(); container.addSubview(imageView); stickyView = imageView
        let titleBar = StickyTitleBarView(frame: CGRect(x: 0, y: size.height, width: size.width, height: titleHeight))
        titleBar.wantsLayer = true; titleBar.layer?.backgroundColor = NSColor(calibratedWhite: 0.12, alpha: 0.92).cgColor
        let titleLabel = NSTextField(labelWithString: title)
        titleLabel.frame = CGRect(x: 8, y: 4, width: max(1, size.width - 40), height: 17)
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium); titleLabel.textColor = .white
        titleLabel.lineBreakMode = .byTruncatingTail
        let closeButton = NSButton(title: "×", target: self, action: #selector(closeImage))
        closeButton.frame = CGRect(x: max(0, size.width - 28), y: 1, width: 26, height: 23)
        closeButton.bezelStyle = .inline
        closeButton.isBordered = false
        closeButton.font = .systemFont(ofSize: 18, weight: .medium)
        closeButton.contentTintColor = .white
        closeButton.toolTip = L.text("closeScreenshot")
        closeButton.setAccessibilityLabel(L.text("closeScreenshot"))
        titleBar.addSubview(titleLabel); titleBar.addSubview(closeButton); container.addSubview(titleBar); contentView = container
        setFrameOrigin(origin)
        Self.openPanels.append(self)
        isRegistered = true
    }

    override func close() {
        unregister()
        super.close()
    }

    deinit { unregister() }

    private func unregister() {
        guard isRegistered else { return }
        isRegistered = false
        Self.openPanels.removeAll { $0 === self }
    }

    private func contextMenu() -> NSMenu {
        let menu = NSMenu()
        menu.addItem(withTitle: L.text("undo"), action: #selector(undoDrawing), keyEquivalent: "z").target = self
        menu.addItem(withTitle: L.text("copy"), action: #selector(copyImage), keyEquivalent: "c")
        menu.addItem(withTitle: L.text("save"), action: #selector(saveImage), keyEquivalent: "s")
        menu.addItem(.separator())
        menu.addItem(withTitle: L.text("close"), action: #selector(closeImage), keyEquivalent: "w")
        return menu
    }
    @objc private func copyImage() {
        guard let image = stickyView.renderedImage() else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects([image])
    }
    @objc private func saveImage() {
        let panel = NSSavePanel(); panel.allowedContentTypes = [.png]; panel.nameFieldStringValue = "Screenshot.png"
        panel.beginSheetModal(for: self) { response in
            guard response == .OK, let url = panel.url,
                  let image = self.stickyView.renderedImage(),
                  let tiff = image.tiffRepresentation,
                  let bitmap = NSBitmapImageRep(data: tiff),
                  let png = bitmap.representation(using: .png, properties: [:]) else { return }
            try? png.write(to: url)
        }
    }
    @objc private func closeImage() { close() }
    @objc private func undoDrawing() { stickyView.undoLastDrawing() }
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
    override func keyDown(with event: NSEvent) {
        if event.modifierFlags.contains(.command), event.charactersIgnoringModifiers?.lowercased() == "z" {
            stickyView.undoLastDrawing()
        } else { super.keyDown(with: event) }
    }
}

final class StickyImageView: NSImageView {
    private var drawings: [NSBezierPath] = []
    private var activePath: NSBezierPath?
    private var drawingIsConstrained = false
    private var constrainedStart: CGPoint?
    private var dragStartMouseLocation: CGPoint?
    private var dragStartWindowOrigin: CGPoint?

    override var acceptsFirstResponder: Bool { true }
    override func viewDidMoveToWindow() { window?.makeFirstResponder(self) }

    override func mouseDown(with event: NSEvent) {
        guard event.modifierFlags.contains(.command) else {
            if event.clickCount == 2 && FeatureSettings.shared.enabled("doubleClickClose") { copySnapshotAndClose() }
            else if FeatureSettings.shared.enabled("moveSticky"), let window {
                dragStartMouseLocation = NSEvent.mouseLocation
                dragStartWindowOrigin = window.frame.origin
            }
            return
        }
        let point = convert(event.locationInWindow, from: nil)
        let path = NSBezierPath()
        path.move(to: point)
        path.lineWidth = 4
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        activePath = path
        drawingIsConstrained = event.modifierFlags.contains(.shift)
        if drawingIsConstrained && !FeatureSettings.shared.enabled("straightLine") { activePath = nil; return }
        if !drawingIsConstrained && !FeatureSettings.shared.enabled("freehand") { activePath = nil; return }
        constrainedStart = point
    }

    override func mouseDragged(with event: NSEvent) {
        if let startMouse = dragStartMouseLocation, let startOrigin = dragStartWindowOrigin, let window {
            let current = NSEvent.mouseLocation
            window.setFrameOrigin(CGPoint(x: startOrigin.x + current.x - startMouse.x,
                                          y: startOrigin.y + current.y - startMouse.y))
            return
        }
        guard let path = activePath else { return }
        let point = convert(event.locationInWindow, from: nil)
        if drawingIsConstrained {
            guard let first = constrainedStart else { return }
            path.removeAllPoints()
            path.move(to: first)
            let locked = abs(point.x - first.x) >= abs(point.y - first.y)
                ? CGPoint(x: point.x, y: first.y)
                : CGPoint(x: first.x, y: point.y)
            path.line(to: locked)
        } else {
            path.line(to: point)
        }
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        dragStartMouseLocation = nil
        dragStartWindowOrigin = nil
        if let path = activePath {
            drawings.append(path.copy() as! NSBezierPath)
            activePath = nil
            constrainedStart = nil
            needsDisplay = true
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSColor.systemRed.setStroke()
        drawings.forEach { $0.stroke() }
        activePath?.stroke()
    }

    override func keyDown(with event: NSEvent) {
        if event.modifierFlags.contains(.command), event.charactersIgnoringModifiers?.lowercased() == "z" {
            undoLastDrawing()
            return
        }
        super.keyDown(with: event)
    }
    func undoLastDrawing() { if !drawings.isEmpty { drawings.removeLast(); needsDisplay = true } }

    func renderedImage() -> NSImage? {
        guard let bitmap = bitmapImageRepForCachingDisplay(in: bounds) else { return nil }
        cacheDisplay(in: bounds, to: bitmap)
        let image = NSImage(size: bounds.size)
        image.addRepresentation(bitmap)
        return image
    }

    private func copySnapshotAndClose() {
        guard let image = renderedImage() else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects([image])
        window?.close()
    }
}

/// The Rapture-style caption strip is also a drag handle, so the pasted
/// screenshot can be moved from either its image or its title.
final class StickyTitleBarView: NSView {
    private var dragStartMouseLocation: CGPoint?
    private var dragStartWindowOrigin: CGPoint?

    override func mouseDown(with event: NSEvent) {
        guard FeatureSettings.shared.enabled("moveSticky"), let window else { return }
        dragStartMouseLocation = NSEvent.mouseLocation
        dragStartWindowOrigin = window.frame.origin
    }

    override func mouseDragged(with event: NSEvent) {
        guard let startMouse = dragStartMouseLocation, let startOrigin = dragStartWindowOrigin, let window else { return }
        let current = NSEvent.mouseLocation
        window.setFrameOrigin(CGPoint(x: startOrigin.x + current.x - startMouse.x,
                                      y: startOrigin.y + current.y - startMouse.y))
    }

    override func mouseUp(with event: NSEvent) {
        dragStartMouseLocation = nil
        dragStartWindowOrigin = nil
    }
}

let application = NSApplication.shared
let applicationDelegate = AppDelegate()
application.delegate = applicationDelegate
application.run()
