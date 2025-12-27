import Cocoa

class WishWindow: NSWindow {
    // CRITICAL: Borderless windows cannot become Key by default.
    // We must override this to return true for Input and Focus events to work.
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
}
