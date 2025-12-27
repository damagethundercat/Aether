import Cocoa
import WebKit

class WebViewController: NSViewController, WKScriptMessageHandler, NSTextFieldDelegate {
    var webView: WKWebView!
    var inputField: NSTextField!
    var tutorialPopover: NSPopover?

    override func loadView() {
        // Main Container
        let initialFrame = NSRect(x: 0, y: 0, width: 420, height: 420)
        self.view = NSView(frame: initialFrame)
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.clear.cgColor
        
        // Rounded Corners for the "Card" look
        self.view.layer?.cornerRadius = 16.0
        self.view.layer?.masksToBounds = true
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        print("DEBUG: WebViewController viewDidAppear - Forcing Focus")
        self.focusInput()
        self.showTutorialPopover()
    }
    
    func showTutorialPopover() {
        let key = "HasSeenWindowTutorial"
        if UserDefaults.standard.bool(forKey: key) { return }
        UserDefaults.standard.set(true, forKey: key)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            let popover = NSPopover()
            popover.behavior = .transient
            popover.animates = true
            
            // Content View Controller
            let vc = NSViewController()
            vc.view = NSView(frame: NSRect(x: 0, y: 0, width: 220, height: 40))
            
            let label = NSTextField(labelWithString: "소원을 입력하고 엔터를 누르세요")
            label.frame = NSRect(x: 10, y: 10, width: 200, height: 20)
            label.alignment = .center
            label.font = NSFont.systemFont(ofSize: 13, weight: .medium)
            vc.view.addSubview(label)
            
            popover.contentViewController = vc
            
            // Point to text area (bottom)
            // Y=0 is bottom. Text box is around y=60.
            // User requested to move it up.
            let centerRect = NSRect(x: self.view.bounds.midX, y: 100, width: 1, height: 1)
            popover.show(relativeTo: centerRect, of: self.view, preferredEdge: .maxY)
            
            self.tutorialPopover = popover
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupInputField()
        setupShortcutMonitor()
    }
    
    func setupWebView() {
        print("DEBUG: WebViewController setupWebView")
        let contentController = WKUserContentController()
        // Listen for log messages from JS if needed
        contentController.add(self, name: "logHandler")

        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.preferences.setValue(true, forKey: "developerExtrasEnabled") // Enable Inspector

        webView = WKWebView(frame: self.view.bounds, configuration: config)
        print("DEBUG: WebView Frame: \(webView.frame)")
        webView.autoresizingMask = [.width, .height]
        
        // Transparent Background (Standard API missing on macOS WKWebView, use KVC)
        webView.setValue(false, forKey: "drawsBackground")
        
        // Scrollbars: Handled by CSS overflow: hidden in index.html
        // Accessing underlying scrollview via private hierarchy is fragile.
        
        self.view.addSubview(webView)
        
        // 5. Load index.html
        // Hot Reload Logic: Try loading from strict Source path first (for Dev), then fallback to Bundle
        let devSourcePath = "/Users/ikidk/Documents/01 개인작업/01 Aether/USB/WishcasterSwift/Resources/index.html"
        let devUrl = URL(fileURLWithPath: devSourcePath)
        
        if FileManager.default.fileExists(atPath: devSourcePath) {
             print("DEBUG: Dev Mode - Loading HTML from Source Directory: \(devSourcePath)")
             let dir = devUrl.deletingLastPathComponent()
             webView.loadFileURL(devUrl, allowingReadAccessTo: dir)
        } else if let htmlPath = Bundle.main.path(forResource: "index", ofType: "html") {
            print("DEBUG: Production Mode - Loading HTML from Bundle: \(htmlPath)")
            let url = URL(fileURLWithPath: htmlPath)
            let dir = url.deletingLastPathComponent()
            webView.loadFileURL(url, allowingReadAccessTo: dir)
        } else {
            print("ERROR: index.html not found in bundle!")
        }
    }
    
    func setupInputField() {
        // Transparent TextField overlay
        // 2025-12-27 Bug Fix: Resize layout to avoid covering the bottom buttons (Cursor Flickering Issue)
        // Shift up by 50px to leave space for info/camera icons at the bottom.
        let inputFrame = NSRect(x: 0, y: 50, width: self.view.bounds.width, height: self.view.bounds.height - 50)
        inputField = NSTextField(frame: inputFrame)
        inputField.autoresizingMask = [.width, .height]
        
        inputField.focusRingType = .none
        inputField.isBordered = false
        inputField.drawsBackground = false
        inputField.backgroundColor = .clear
        
        // --- MULTI-LINE CONFIGURATION ---
        inputField.usesSingleLineMode = false // Allow multiple lines
        inputField.cell?.wraps = true         // Wrap text
        inputField.cell?.isScrollable = false // Don't allow horizontal scroll, force wrap
        inputField.lineBreakMode = .byCharWrapping
        // --------------------------------
        
        // Hide text and cursor - p5.js renders the text
        inputField.textColor = NSColor.clear
        // Hide Cursor (Caret) by making the view ALMOST transparent.
        inputField.alphaValue = 0.01
        
        inputField.delegate = self
        
        self.view.addSubview(inputField)
        
        setupInfoButton()
    }
    
    func setupInfoButton() {
        // Camera Button (Left of Info)
        let cameraButton = NSButton(frame: NSRect(x: 365, y: 10, width: 20, height: 20))
        cameraButton.bezelStyle = .inline
        cameraButton.title = ""
        cameraButton.image = NSImage(systemSymbolName: "camera", accessibilityDescription: "Screenshot") ?? NSImage(named: NSImage.actionTemplateName)
        cameraButton.imageScaling = .scaleProportionallyDown
        cameraButton.target = self
        cameraButton.action = #selector(takeScreenshot)
        cameraButton.isBordered = false
        cameraButton.contentTintColor = .white.withAlphaComponent(0.8)
        cameraButton.alphaValue = 0.8
        self.view.addSubview(cameraButton)
        
        // Info Button
        let button = NSButton(frame: NSRect(x: 390, y: 10, width: 20, height: 20))
        button.bezelStyle = .inline
        button.title = ""
        // Try system symbol, fell back to standard info Name
        button.image = NSImage(systemSymbolName: "info.circle", accessibilityDescription: "About") ?? NSImage(named: NSImage.infoName)
        button.imageScaling = .scaleProportionallyDown
        
        button.target = self
        button.action = #selector(openAboutWindow)
        button.isBordered = false
        button.contentTintColor = .white.withAlphaComponent(0.8)
        button.alphaValue = 0.8 
        
        self.view.addSubview(button)
    }
    
    @objc func takeScreenshot() {
        let config = WKSnapshotConfiguration()
        // Capture entire view
        config.rect = self.webView.bounds
        config.afterScreenUpdates = true
        
        self.webView.takeSnapshot(with: config) { image, error in
            if let error = error {
                print("Screenshot failed: \(error)")
                return
            }
            
            guard let image = image else { return }
            self.saveImage(image)
        }
    }
    
    func saveImage(_ image: NSImage) {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.png]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.title = "Save Screenshot"
        savePanel.message = "Choose a location to save your Aether screenshot."
        savePanel.nameFieldStringValue = "Aether_Capture_\(Int(Date().timeIntervalSince1970))"
        
        // We need to present this on the window
        // guard let window = self.view.window else { return }
        
        // Use runModal for robustness on utility windows
        print("DEBUG: Showing Save Panel...")
        let response = savePanel.runModal()
        
        if response == .OK, let url = savePanel.url {
            if let tiffData = image.tiffRepresentation,
               let bitmapImage = NSBitmapImageRep(data: tiffData),
               let pngData = bitmapImage.representation(using: .png, properties: [:]) {
                
                try? pngData.write(to: url)
                print("Screenshot saved to: \(url.path)")
                
                // Visual Feedback: Flash or sound?
                NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .default)
            }
        } else {
            print("DEBUG: Save Panel cancelled or failed.")
        }
    }
    
    @objc func openAboutWindow() {
        NotificationCenter.default.post(name: NSNotification.Name("openAboutWindow"), object: nil)
    }
    
    func setupShortcutMonitor() {
        // Keyboard Shortcuts
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            // Check for Cmd + Shift + E (Export) or Cmd + R (Reload)
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            
            if flags == [.command, .shift] {
                if let chars = event.charactersIgnoringModifiers?.lowercased(), chars == "e" {
                    print("Shortcut Cmd+Shift+E detected via Monitor")
                    self?.exportHighResAsset()
                    return nil // Swallow the event
                }
            } else if flags == [.command] {
                if let chars = event.charactersIgnoringModifiers?.lowercased(), chars == "r" {
                    print("Shortcut Cmd+R detected - RELOADING WEBVIEW")
                    self?.webView.reload()
                    return nil
                }
            }
            return event
        }
        
        // Mouse Interaction Monitor (since overlay might block WebView)
        NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .leftMouseUp]) { [weak self] event in
            // We only care if the event happens inside our window
            guard let self = self, let window = self.view.window, event.window == window else {
                 return event
            }
            
            if event.type == .leftMouseDown {
                print("DEBUG: Mouse Down detected - Sending setConstellationMode(true)")
                self.webView.evaluateJavaScript("if(window.setConstellationMode) window.setConstellationMode(true);", completionHandler: nil)
            } else if event.type == .leftMouseUp {
                 print("DEBUG: Mouse Up detected - Sending setConstellationMode(false)")
                self.webView.evaluateJavaScript("if(window.setConstellationMode) window.setConstellationMode(false);", completionHandler: nil)
            }
            
            return event
        }
    }
    
    func exportHighResAsset() {
        print("WebViewController: Evaluating exportHighRes()...")
        webView.evaluateJavaScript("exportHighRes()") { [weak self] result, error in
            if let error = error {
                print("Error triggering high-res export (JS): \(error)")
            } else if let dataURL = result as? String {
                print("JS returned DataURL (Length: \(dataURL.count))")
                if let data = self?.dataFromDataURL(dataURL), let image = NSImage(data: data) {
                    print("Image data converted successfully, opening save panel...")
                    self?.saveImage(image)
                } else {
                    print("Failed to convert DataURL to image")
                }
            } else {
                print("JS returned unexpected result type: \(String(describing: result))")
            }
        }
    }
    
    private func dataFromDataURL(_ dataURL: String) -> Data? {
        if let commaIndex = dataURL.firstIndex(of: ",") {
            let base64String = String(dataURL[dataURL.index(after: commaIndex)...])
            return Data(base64Encoded: base64String)
        }
        return nil
    }
    
    func focusInput() {
        self.view.window?.makeFirstResponder(inputField)
    }
    
    // MARK: - NSTextFieldDelegate
    
    func controlTextDidChange(_ obj: Notification) {
        // Dismiss tutorial if typing starts
        if let popover = tutorialPopover, popover.isShown {
            popover.close()
            tutorialPopover = nil
        }

        if let textField = obj.object as? NSTextField {
            let text = textField.stringValue
            // Sanitize and JSON encode string for JS safely
            if let jsonData = try? JSONEncoder().encode(text),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                let js = "if(window.updateP5Input) window.updateP5Input(\(jsonString));"
                webView.evaluateJavaScript(js, completionHandler: nil)
            }
        }
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            // Check if Shift or Option is pressed for newline
            if let event = NSApp.currentEvent, event.modifierFlags.contains(.shift) || event.modifierFlags.contains(.option) {
                textView.insertNewlineIgnoringFieldEditor(nil)
                return true
            }
            
            // Regular Enter pressed -> Submit
            let text = inputField.stringValue
            if !text.isEmpty {
                // 1. Real Network Transmission (UDP Broadcast)
                SignalTransmitter.shared.broadcast(message: text)
                
                // 2. Haptic Feedback
                NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .default)
                
                // 3. Trigger p5.js Explosion
                webView.evaluateJavaScript("if(window.triggerP5Explosion) window.triggerP5Explosion();", completionHandler: nil)
                
                // 4. Clear local field
                inputField.stringValue = ""
            }
            return true
        }
        return false
    }
    
    // MARK: - WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "logHandler" {
            print("JS LOG: \(message.body)")
        }
    }
}
