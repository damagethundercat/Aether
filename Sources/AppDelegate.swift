import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var window: NSWindow!
    var webViewController: WebViewController!
    var aboutWindowController: AboutWindowController? // Strong reference

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("DEBUG: App Launched")
        
        // Observer for About Window
        NotificationCenter.default.addObserver(self, selector: #selector(showAboutWindow), name: .openAboutWindow, object: nil)
        
        // 1. Create Menu Bar Item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            // 2025-12-27 User Request: Use Ascending Node symbol (☊) as icon
            button.image = nil
            let title = "☊"
            let font = NSFont.systemFont(ofSize: 22) // Increased from 18 to 22
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .baselineOffset: -3.0 // Keep user's manual adjustment
            ]
            button.attributedTitle = NSAttributedString(string: title, attributes: attributes)
            
            button.action = #selector(statusBarButtonClicked(sender:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        // 2. Create Window (Custom "control center" style)
        let windowSize = NSSize(width: 420, height: 380)
        let styleMask: NSWindow.StyleMask = [.borderless, .fullSizeContentView]
        
        window = WishWindow(
            contentRect: NSRect(origin: .zero, size: windowSize),
            styleMask: styleMask,
            backing: .buffered,
            defer: false
        )
        window.level = .floating
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = true // Add shadow for depth like battery menu
        window.ignoresMouseEvents = false
        
        // 3. Setup Content View
        webViewController = WebViewController()
        window.contentViewController = webViewController
        
        // Hide initially
        window.orderOut(nil)
        
        // Auto-close when clicking outside
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidResignKey), name: NSWindow.didResignKeyNotification, object: window)
        
        // 4. First Launch Tutorial
        checkFirstLaunch()
    }
    
    func checkFirstLaunch() {
        let key = "HasLaunchedBefore"
        let hasLaunched = UserDefaults.standard.bool(forKey: key)
        
        if !hasLaunched {
            UserDefaults.standard.set(true, forKey: key)
            
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "새해 복 많이 받으세요!"
                alert.informativeText = "1. 상단바의 ☊ 아이콘을 누르세요.\n2. 소원을 입력하고 엔터(Enter)를\n누르세요.\n\n아이콘이 안 보이면 상단바 공간을\n확보해주세요!"
                alert.alertStyle = .informational
                alert.addButton(withTitle: "시작하기")
                
                // Ensure the alert appears on top
                NSApp.activate(ignoringOtherApps: true)
                alert.runModal()
                
                // Highlight the button briefly to show where it is
                self.statusItem.button?.highlight(true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.statusItem.button?.highlight(false)
                }
            }
        }
    }

    @objc func statusBarButtonClicked(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        
        if event.type == .rightMouseUp {
            let menu = NSMenu()
            menu.addItem(NSMenuItem(title: "Quit Aether", action: #selector(terminateApp), keyEquivalent: "q"))
            statusItem.menu = menu
            statusItem.button?.performClick(nil)
            statusItem.menu = nil
        } else {
            toggleWindow(sender)
        }
    }

    func toggleWindow(_ sender: Any?) {
        if window.isVisible {
            window.orderOut(nil)
            statusItem.button?.isHighlighted = false
        } else {
            // Position Logic
            guard let button = statusItem.button, let buttonWindow = button.window else { return }
            
            // Get button frame in screen coordinates
            // Convert button -> window coors -> screen coords
            let buttonRectInWindow = button.convert(button.bounds, to: nil)
            let buttonRectInScreen = buttonWindow.convertToScreen(buttonRectInWindow)
            
            let windowSize = window.frame.size
            
            // Center X on button
            let midX = buttonRectInScreen.midX
            var x = midX - (windowSize.width / 2)
            
            // Y: Below button with a GAP
            // Screen Y is bottom-left origin. Button Bottom is actually the top edge visually in screen coords?
            // Wait, screen coords: Y=0 is bottom. Y=MAX is top.
            // buttonRectInScreen.minY is the bottom edge of the button.
            let gap: CGFloat = 1.0 // Reduced from 5.0 to 1.0 per user request
            var y = buttonRectInScreen.minY - windowSize.height - gap
            
            // Ensure on screen
            if let screen = NSScreen.main {
                let screenRect = screen.visibleFrame
                x = max(screenRect.minX, min(x, screenRect.maxX - windowSize.width))
                y = max(screenRect.minY, y) // Don't go below screen
            }
            
            window.setFrameOrigin(NSPoint(x: x, y: y))
            
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            webViewController.focusInput()
            
            // Highlight Button
            statusItem.button?.isHighlighted = true
        }
    }
    
    @objc func showAboutWindow() {
        if aboutWindowController == nil {
            aboutWindowController = AboutWindowController()
        }
        aboutWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
        aboutWindowController?.window?.makeKeyAndOrderFront(nil)
    }
    
    @objc func windowDidResignKey() {
        window.orderOut(nil)
        statusItem.button?.isHighlighted = false // Remove highlight
    }
    


    @objc func terminateApp() {
        NSApp.terminate(nil)
    }
}
