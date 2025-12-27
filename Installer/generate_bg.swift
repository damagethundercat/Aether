import Cocoa
import CoreGraphics

// Define Setup
let width: CGFloat = 600
let height: CGFloat = 400
let size = NSSize(width: width, height: height)

// Create Image
let image = NSImage(size: size)
image.lockFocus()

// 1. Fill Background White
NSColor.white.setFill()
let rect = NSRect(x: 0, y: 0, width: width, height: height)
rect.fill()

// 2. Configure Text Styles using explicit NSAttributedString.Key
let fontName = "Helvetica Neue Light"

// Arrow (Ascending Node)
let arrowFont = NSFont.systemFont(ofSize: 60) // Reduced size
let arrowStyle = NSMutableParagraphStyle()
arrowStyle.alignment = .center
let arrowAttrs: [NSAttributedString.Key: Any] = [
    .font: arrowFont,
    .foregroundColor: NSColor(white: 0.6, alpha: 1.0), // Slightly darker for the symbol
    .paragraphStyle: arrowStyle
]
let arrowText = "☊"
let arrowRect = NSRect(x: 0, y: (height/2) - 10, width: width, height: 100) // Adjusted centering (Raised by 40)
arrowText.draw(in: arrowRect, withAttributes: arrowAttrs)

// Main Text (Korean)
let instructionFont = NSFont(name: "AppleSDGothicNeo-Regular", size: 14) ?? NSFont.systemFont(ofSize: 14)
let instructionStyle = NSMutableParagraphStyle()
instructionStyle.alignment = .center
let instructionAttrs: [NSAttributedString.Key: Any] = [
    .font: instructionFont,
    .foregroundColor: NSColor(white: 0.5, alpha: 1.0), // Medium grey text
    .paragraphStyle: instructionStyle
]
let instructionText = "드래그해서 설치해주세요."
let instructionRect = NSRect(x: 0, y: 100, width: width, height: 30) // Raised by 40
instructionText.draw(in: instructionRect, withAttributes: instructionAttrs)


image.unlockFocus()

// 3. Save to PNG
if let tiffData = image.tiffRepresentation,
   let bitmap = NSBitmapImageRep(data: tiffData),
   let pngData = bitmap.representation(using: .png, properties: [:]) {
    let fileURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("dmg_background_generated.png")
    try? pngData.write(to: fileURL)
    print("Successfully created \(fileURL.path)")
} else {
    print("Error creating image")
}
