#!/bin/bash
# Build script for Wishcaster (Swift Native)

APP_NAME="Aether"
APP_DIR="$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "🚧 Building $APP_NAME..."

# 1. Prepare Directory Structure
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# 2. Compile Swift Sources (Universal Binary: Intel + Apple Silicon)
echo "🔨 Compiling Swift sources..."

# Compile for ARM64 (Apple Silicon)
swiftc Sources/*.swift -o "$MACOS_DIR/$APP_NAME-arm64" -target arm64-apple-macosx11.0 -sdk $(xcrun --show-sdk-path)

# Compile for x86_64 (Intel)
swiftc Sources/*.swift -o "$MACOS_DIR/$APP_NAME-x86_64" -target x86_64-apple-macosx11.0 -sdk $(xcrun --show-sdk-path)

if [ $? -ne 0 ]; then
    echo "❌ Compilation Failed!"
    exit 1
fi

# Create Universal Binary
echo "🔗 Creating Universal Binary..."
lipo -create "$MACOS_DIR/$APP_NAME-arm64" "$MACOS_DIR/$APP_NAME-x86_64" -output "$MACOS_DIR/$APP_NAME"
rm "$MACOS_DIR/$APP_NAME-arm64" "$MACOS_DIR/$APP_NAME-x86_64"

# 3. Create Info.plist
echo "📝 Creating Info.plist..."
cat > "$CONTENTS_DIR/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.ikidk.Aether</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSUIElement</key>
    <true/> <!-- Menu Bar App Agent Mode -->
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
</dict>
</plist>
EOF

# 4. Copy Resources
echo "📂 Copying Resources..."
cp Resources/* "$RESOURCES_DIR/"

# 5. Clean Metadata & Ad-hoc Sign (Crucial for M1/M2/M3)
echo "🧹 Cleaning metadata and signing..."
xattr -cr "$APP_DIR"
codesign --force --deep -s - "$APP_DIR"

echo "✅ Build Complete: $APP_DIR"
echo "👉 Run with: open $APP_DIR"
