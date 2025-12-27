import Cocoa

class AboutWindowController: NSWindowController, NSWindowDelegate {
    
    // UI Elements
    private let textView = NSTextView()
    private let appIconView = NSImageView()
    private let appNameLabel = NSTextField(labelWithString: "Aether")
    private let versionLabel = NSTextField(labelWithString: "Version 1.0.0")
    
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 350, height: 550), // Increased from 450 to 550
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        
        // Limits: Fix width at 350, allow height between 300 and 800
        window.minSize = NSSize(width: 350, height: 350)
        window.maxSize = NSSize(width: 350, height: 800)
        
        window.center()
        self.init(window: window)
        window.delegate = self
        
        setupUI()
    }
    
    private func setupUI() {
        guard let contentView = window?.contentView else { return }
        window?.backgroundColor = .windowBackgroundColor
        
        // Use Auto Layout instead of manual frames
        let container = NSView()
        container.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        // 0. Custom Title Label
        let headerLabel = NSTextField(labelWithString: "About Aether")
        headerLabel.font = NSFont.systemFont(ofSize: 13, weight: .bold)
        headerLabel.textColor = .labelColor.withAlphaComponent(0.9)
        headerLabel.alignment = .center
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(headerLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            headerLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            headerLabel.heightAnchor.constraint(equalToConstant: 22)
        ])
        
        // 1. App Icon
        appIconView.image = NSImage(named: "AppIcon") ?? NSImage(named: NSImage.applicationIconName)
        appIconView.imageScaling = .scaleProportionallyUpOrDown
        appIconView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(appIconView)
        
        NSLayoutConstraint.activate([
            appIconView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 32),
            appIconView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            appIconView.widthAnchor.constraint(equalToConstant: 100),
            appIconView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        // 2. App Name & Version
        appNameLabel.font = NSFont.systemFont(ofSize: 20, weight: .bold)
        appNameLabel.alignment = .center
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(appNameLabel)
        
        NSLayoutConstraint.activate([
            appNameLabel.topAnchor.constraint(equalTo: appIconView.bottomAnchor, constant: 10),
            appNameLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ])
        
        versionLabel.font = NSFont.systemFont(ofSize: 12)
        versionLabel.textColor = .secondaryLabelColor
        versionLabel.alignment = .center
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(versionLabel)
        
        NSLayoutConstraint.activate([
            versionLabel.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: 4),
            versionLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ])
        
        // 3. Scrollable Text View (Flexible Height)
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: versionLabel.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 30),
            scrollView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -30),
            scrollView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -60)
        ])
        
        // 4. Social Links (GitHub, Instagram)
        let githubButton = createSocialButton(imageName: "github_icon", action: #selector(openGitHub))
        let instaButton = createSocialButton(imageName: "instagram_icon", action: #selector(openInstagram))
        
        container.addSubview(githubButton)
        container.addSubview(instaButton)
        
        NSLayoutConstraint.activate([
            // GitHub: Bottom Left-ish (centered relative to half width?) or just centered together
            // Let's put them side by side centered
            githubButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -50),
            githubButton.trailingAnchor.constraint(equalTo: container.centerXAnchor, constant: -10),
            
            instaButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -50),
            instaButton.leadingAnchor.constraint(equalTo: container.centerXAnchor, constant: 10)
        ])
        
        // 5. Email Link
        let emailButton = NSButton(title: "ikidkforwork@gmail.com", target: self, action: #selector(openEmail))
        emailButton.bezelStyle = .inline
        emailButton.isBordered = false
        emailButton.font = NSFont.systemFont(ofSize: 11)
        emailButton.contentTintColor = NSColor.gray
        emailButton.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(emailButton)
        
        NSLayoutConstraint.activate([
            emailButton.topAnchor.constraint(equalTo: githubButton.bottomAnchor, constant: 8),
            emailButton.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ])
        
        // Configure TextView
        textView.isEditable = false
        textView.isRichText = false
        textView.font = NSFont.systemFont(ofSize: 13, weight: .regular)
        textView.textColor = .labelColor
        textView.backgroundColor = .clear
        textView.textContainer?.lineBreakMode = .byWordWrapping // Word Wrap enabled
        
        // Use autoresizing mask for the internal document view (Standard way for NSTextView)
        // This ensures the text view matches the width of the scroll view's content area.
        textView.autoresizingMask = [.width]
        textView.widthAnchor.constraint(equalTo: scrollView.contentView.widthAnchor).isActive = false // Disable conflicting constraint

        textView.string = """
        2026년 병오년(丙午年), 붉은 말의 해를 맞이하며.

        고대인들은 우주가 ‘에테르(Aether)’로
        가득하다고 믿었습니다.
        
        1,500광년 떨어진 오리온 자리의 말머리 성운으로,
        문장을 신호로 바꿔 쏘아 올립니다.

        작은 창에 입력된 문장은 0과 1이 되어 UDP를 타고
        하늘 너머로 흩어집니다.

        붉게 타오르는 마음으로 한 해를 시작하시길!

        김용규 드림
        """
        
        scrollView.documentView = textView
    }
    
    private func createSocialButton(imageName: String, action: Selector) -> NSButton {
        let btn = NSButton()
        btn.bezelStyle = .regularSquare
        btn.isBordered = false
        btn.image = NSImage(contentsOfFile: Bundle.main.path(forResource: imageName, ofType: "png") ?? "")
        if btn.image == nil {
             // Fallback if image not found (shouldn't happen with correct resource copy)
             btn.title = imageName
        } else {
             btn.title = ""
             btn.image?.isTemplate = true // Enable template rendering for tinting
             btn.contentTintColor = NSColor(white: 0.6, alpha: 1.0) // Slightly gray as requested
             btn.imageScaling = .scaleProportionallyDown
        }
        btn.target = self
        btn.action = action
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        // Add size constraints
        btn.widthAnchor.constraint(equalToConstant: 24).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        return btn
    }
    
    @objc func openGitHub() {
        if let url = URL(string: "https://github.com/damagethundercat/Aether") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc func openInstagram() {
        if let url = URL(string: "https://instagram.com/yooong_k_") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc func openEmail() {
        if let url = URL(string: "mailto:ikidkforwork@gmail.com") {
            NSWorkspace.shared.open(url)
        }
    }
}
