console.log("P5JS: p5js.js loading (Instance Mode)");

new p5(function (p) {
    let stars = [];
    let numStars = 4000;
    let numBackgroundStars = 4000;
    let numArms = 2;

    let textParticles = [];
    let ripples = []; // Radio Wave Ripples
    let inputState = {
        text: "",
        isFocused: true,
        cursorVisible: true,
        lastBlink: 0
    };

    let textLayer;
    // let hiddenInput; // Removed in favor of Flutter native input
    let logoImg;
    let mainFont = 'Arial';
    let textBoxY = 340;







    let galaxyCenterX = 0; // Centered
    let galaxyCenterY = -90; // Slightly up (negative is up in WebGL)
    let galaxyCenterZ = -90;
    let galaxyRotX = Math.PI / 2.7;
    let galaxyRotY = Math.PI / -9;

    let galaxyNormal;

    // Base64 encoded image to bypass local file system CORS restrictions in WebView
    const logoBase64 = "data:image/png;base64,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";

    p.preload = function () {
        console.log("P5JS: preload() called");
        // Load image from Base64 string directly
        logoImg = p.loadImage(logoBase64,
            () => console.log("P5JS: Logo loaded successfully"),
            (e) => console.log("P5JS: Logo load failed", e)
        );
    };

    p.setup = function () {
        console.log("P5JS: setup() called");
        p.pixelDensity(1);

        // Dynamic sizing
        let cnv = p.createCanvas(p.windowWidth, p.windowHeight, p.WEBGL);
        console.log("P5JS: Canvas created " + p.windowWidth + "x" + p.windowHeight);

        cnv.style('display', 'block');
        cnv.style('touch-action', 'none');

        p.noStroke();

        textLayer = p.createGraphics(p.windowWidth, p.windowHeight);
        textLayer.pixelDensity(1);
        textLayer.textWrap(p.WORD); // Enable word wrapping for natural breaks
        textLayer.textAlign(p.CENTER, p.CENTER);
        textLayer.textSize(24);

        galaxyNormal = p.createVector(0, 0, 1);
        rotateVectorX(galaxyNormal, galaxyRotX);
        rotateVectorY(galaxyNormal, galaxyRotY);
        galaxyNormal.normalize();




        // --- FLUTTER INTEGRATION ---
        // We delegate input handling to Flutter's native TextField for better IME support (Korean, etc.)
        window.updateP5Input = (newText) => {
            // console.log("P5JS: Received input from flutter: " + newText);
            inputState.text = newText;
            if (!inputState.isFocused) inputState.isFocused = true;
        };

        window.triggerP5Explosion = () => {
            console.log("P5JS: Triggering explosion from Flutter");
            triggerExplosion();
        };

        // Allow Swift to control Interaction Mode (since native overlay blocks touches)
        window.setConstellationMode = (isActive) => {
            // Stub: Interaction removed by user request
        };

        for (let i = 0; i < numStars; i++) {
            let isCore = p.random() < 0.2;
            stars.push(new Star('galaxy', isCore));
        }

        // Add background stars scattered everywhere
        for (let i = 0; i < numBackgroundStars; i++) {
            stars.push(new Star('background'));
        }

        // Recalculate positions based on new size
        recalcLayout();



        // FORCE RESIZE CHECK: Sometimes initial load is 800x600 (default WebView),  
        // then window resizes to 600x600. We ensure we catch that.
        setTimeout(() => {
            console.log("P5JS: Force resize check. Size: " + p.windowWidth + "x" + p.windowHeight);
            p.resizeCanvas(p.windowWidth, p.windowHeight);
            textLayer.resizeCanvas(p.windowWidth, p.windowHeight);
            recalcLayout();
        }, 500);
    };

    p.windowResized = function () {
        console.log("P5JS: Window resized to " + p.windowWidth + "x" + p.windowHeight);
        p.resizeCanvas(p.windowWidth, p.windowHeight);
        textLayer.resizeCanvas(p.windowWidth, p.windowHeight);
        recalcLayout();
    };

    function recalcLayout() {
        // Re-center things if needed
        // Position text lower on screen (approx 85% down)
        textBoxY = p.height * 0.85;
    }



    // p.keyPressed removed - handled by Native Bridge

    let isExporting = false;

    p.draw = function () {
        if (p.frameCount === 1) console.log("P5JS: First draw frame");

        // Skip background and logo if exporting for transparent asset
        if (!isExporting) {
            drawGradientBackground();
            // drawLogo(); // Hidden by user request (Detail correction #2)
        } else {
            p.clear(); // Ensure transparency in WEBGL
        }

        // --- Background Stars Rotation (Slower) ---
        p.push();
        p.translate(galaxyCenterX, galaxyCenterY, galaxyCenterZ);
        p.rotateX(galaxyRotX);
        p.rotateY(galaxyRotY);
        p.rotateZ(p.frameCount * 0.0004); // Slower background rotation
        p.blendMode(p.BLEND);
        for (let star of stars) {
            if (star.type === 'background') star.show();
        }
        p.pop();

        // --- Galaxy Stars Rotation (Standard) ---
        p.push();
        p.translate(galaxyCenterX, galaxyCenterY, galaxyCenterZ);
        p.rotateX(galaxyRotX);
        p.rotateY(galaxyRotY);
        p.rotateZ(p.frameCount * 0.002);
        p.blendMode(p.BLEND);
        for (let star of stars) {
            if (star.type !== 'background') star.show();
        }
        p.pop();

        p.push();
        p.translate(0, 0, 0);
        // Render Particles
        for (let i = textParticles.length - 1; i >= 0; i--) {
            let particle = textParticles[i];
            particle.update();
            particle.show();
            if (particle.life <= 0) {
                textParticles.splice(i, 1);
            }
        }
        // Ripples removed by user request
        p.pop();

        if (!isExporting) {
            updateTextLayer();
            p.push();
            // HUD MODE: Switch to Orthographic projection to draw 2D overlay on top
            p.resetMatrix();
            p.camera(0, 0, (p.height / 2.0) / Math.tan(Math.PI * 30.0 / 180.0), 0, 0, 0, 0, 1, 0);
            p.ortho(-p.width / 2, p.width / 2, -p.height / 2, p.height / 2, 0, 10000);

            p.noLights();
            p.texture(textLayer);

            // Draw full screen quad as image (simpler for 2D overlay)
            // Note: In WEBGL mode, image() draws at the current z-depth (default 0).
            // We use a plane or image. Image is cleaner for texture mapping mapping 1:1.
            p.imageMode(p.CENTER);
            p.image(textLayer, 0, 0, p.width, p.height);

            p.pop();
        }
    };

    // Hidden high-res export function for design assets
    window.exportHighRes = function () {
        console.log("P5JS: Starting high-res transparent export...");
        isExporting = true;

        // Temporarily boost resolution
        let originalDensity = p.pixelDensity();
        p.pixelDensity(4); // 4x high-res

        p.noLoop(); // Stop loop temporarily 
        p.redraw(); // Trigger a single frame with new settings

        // Get DataURL instead of p.saveCanvas to handle saving in Swift
        let dataURL = p.canvas.toDataURL('image/png');

        // Restore settings
        p.pixelDensity(originalDensity);
        isExporting = false;
        p.loop(); // Resume loop

        console.log("P5JS: High-res export data generated.");
        return dataURL;
    };

    function drawGradientBackground() {
        p.push();
        p.translate(0, 0, -500);
        // Use a large plane to cover rotation
        let w = p.width * 1.5;
        let h = p.height * 1.5; // Giant height for background coverage

        // Gradient Stops configuration (Figma-style)
        // Coordinates in WebGL: 0 is center. -height/2 is top. +height/2 is bottom.

        // Stop 1: Solid Color Line (extends from top infinity to start of fade)
        // Raised start position to -0.8 (much higher) to make the gradient transition longer/smoother
        let gradientStart = -p.height * 0.8;

        // Stop 2: End of Fade (extends to bottom of screen)
        let gradientEnd = p.height * 0.5; // Bottom edge of visible canvas

        p.noStroke();
        p.beginShape(p.TRIANGLE_STRIP);

        // 1. Top Section (Solid Vivid Crimson)
        p.fill(228, 1, 70);
        p.vertex(-w, -h); // Way above screen
        p.vertex(w, -h);

        p.vertex(-w, gradientStart); // Start fading
        p.vertex(w, gradientStart);

        // 2. Gradient Section (Crimson -> Charcoal)
        // Charcoal (40, 40, 43)
        p.fill(25, 25, 25);
        p.vertex(-w, gradientEnd); // Bottom of screen
        p.vertex(w, gradientEnd);

        // 3. Bottom Section (Solid Charcoal for anything below screen)
        p.vertex(-w, h);
        p.vertex(w, h);

        p.endShape();
        p.pop();
    }

    function drawLogo() {
        if (!logoImg) return; // Skip if not loaded
        p.push();
        p.translate(-p.width / 2 + 70, -p.height / 2 + 60, 100);
        p.imageMode(p.CENTER);
        p.scale(0.2);
        p.image(logoImg, 0, 0);
        p.pop();
    }

    function updateTextLayer() {
        textLayer.clear();
        let content = inputState.text;
        let showPlaceholder = (content.length === 0);

        if (showPlaceholder) {
            content = "";
            textLayer.fill(255, 255, 255, 150); // Placeholder: Semi-transparent white
        } else {
            // Visible typing text color: White (by User Request)
            textLayer.fill(255, 255, 255);
        }

        textLayer.noStroke();
        textLayer.textAlign(p.CENTER, p.CENTER);
        textLayer.textSize(18);
        // Use system font stack that supports Korean on macOS
        textLayer.textFont('Apple SD Gothic Neo, sans-serif');

        let padding = 40;
        let textWidthLimit = p.width - (padding * 2);

        // Draw in a way that wraps and stays above bottom buttons
        // Box spans from y to y+h.
        textLayer.text(content, padding, textBoxY - 80, textWidthLimit, 100);

        textLayer.text(content, padding, textBoxY - 80, textWidthLimit, 100);
    }

    function triggerExplosion() {
        // Input handled via native bridge
        let str = inputState.text;
        if (str.trim() === "") return;

        explodeText(str);

        inputState.text = "";
    }

    function explodeText(str) {
        textLayer.clear();
        textLayer.fill(255);
        textLayer.textAlign(p.CENTER, p.CENTER);
        textLayer.textSize(24); // Size during explosion can be slightly larger for effect
        textLayer.textFont('Apple SD Gothic Neo, sans-serif');
        textLayer.textWrap(p.WORD); // Match setup wrapping

        let padding = 40;
        let textWidthLimit = p.width - (padding * 2);
        // Use same bounding box as updateTextLayer for accurate sampling
        textLayer.text(str, padding, textBoxY - 80, textWidthLimit, 100);

        textLayer.loadPixels();

        // DENSITY TWEAK: Step 3 instead of 4 (More particles)
        let step = 3;
        // Center offset for particles relative to where text was drawn
        // Text was drawn at (centerX, textBoxY)
        // We want particles to start exactly there.
        // In WEBGL mode with translate(0,0), (0,0) is center.
        // Pixel array (x,y) is (0,0) at top-left.

        // Convert 2D pixel coordinates (Top-Left 0,0) to WebGL World Coordinates (Center 0,0)
        let worldOffsetX = textLayer.width / 2;
        let worldOffsetY = textLayer.height / 2;

        for (let y = 0; y < textLayer.height; y += step) {
            for (let x = 0; x < textLayer.width; x += step) {
                let index = (x + y * textLayer.width) * 4;
                let a = textLayer.pixels[index + 3];

                if (a > 100) {
                    // Calculate world position:
                    // x=0 -> -worldOffsetX
                    // y=0 -> -worldOffsetY
                    let worldX = x - worldOffsetX;
                    let worldY = y - worldOffsetY;

                    textParticles.push(new TextParticle(worldX, worldY, 0));
                }
            }
        }
    }

    function rotateVectorX(v, angle) {
        let y = v.y * Math.cos(angle) - v.z * Math.sin(angle);
        let z = v.y * Math.sin(angle) + v.z * Math.cos(angle);
        v.y = y; v.z = z;
    }

    function rotateVectorY(v, angle) {
        let x = v.x * Math.cos(angle) + v.z * Math.sin(angle);
        let z = -v.x * Math.sin(angle) + v.z * Math.cos(angle);
        v.x = x; v.z = z;
    }

    class Star {
        constructor(type, isCore) {
            this.type = type;

            if (this.type === 'galaxy') {
                this.isCore = isCore;
                if (this.isCore) {
                    this.dist = p.abs(p.randomGaussian(0, 30));
                    this.angle = p.random(p.TWO_PI);
                    this.size = p.random(1.5, 3.0);
                    this.brightness = 255;
                } else {
                    this.dist = p.randomGaussian(100, 80);
                    if (this.dist < 0) this.dist = -this.dist;
                    let armIndex = p.floor(p.random(numArms));
                    let baseAngle = (p.TWO_PI / numArms) * armIndex;
                    let spiralFactor = 0.06;
                    let armSpread = p.randomGaussian() * 0.6;
                    this.angle = baseAngle + (this.dist * spiralFactor) + armSpread;
                    this.size = p.random(1.0, 2.5);
                    this.brightness = p.map(this.dist, 0, 300, 255, 100);
                }
                // Pre-calculate galaxy position (unrotated)
                this.gx = this.dist * p.cos(this.angle);
                this.gy = this.dist * p.sin(this.angle);
                this.gz = 0; // Flat galaxy disc + jitter?
            } else {
                // Background
                this.x = p.random(-p.width * 2, p.width * 2);
                this.y = p.random(-p.height * 2, p.height * 2);
                this.z = p.random(-2000, 2000);
                this.size = p.random(0.5, 1.5);
                this.brightness = p.random(50, 150);
            }
        }


        show() {
            p.push();
            if (this.type === 'background') {
                p.translate(this.x, this.y, this.z);
            } else {
                // Normal Galaxy Star rendering
                // Note: We pre-calc cx, cy in constructor but here we use transform for efficiency usually.
                // But my variable names are slightly different.
                // old code: translate(x,y,0) after rotating.
                let x = this.dist * p.cos(this.angle);
                let y = this.dist * p.sin(this.angle);
                p.translate(x, y, 0);
            }
            // If this is a constellation star, we DON'T render it here (checked in loop)
            p.fill(255, this.brightness);
            p.ellipse(0, 0, this.size);
            p.pop();
        }
    }

    class TextParticle {
        constructor(x, y, z) {
            this.pos = p.createVector(x, y, z);
            this.vel = p.createVector(p.random(-0.3, 0.3), p.random(-0.8, -0.2), p.random(-0.2, 0.2));
            this.life = 255;
            this.maxLife = 255;
            this.noiseOffset = p.random(1000);
        }

        update() {
            let target = p.createVector(galaxyCenterX, galaxyCenterY, galaxyCenterZ);
            let dirToCenter = p5.Vector.sub(target, this.pos);
            let dist = dirToCenter.mag();
            dirToCenter.normalize();
            let pullStrength = p.map(dist, 0, 400, 0.5, 0.08);
            this.vel.add(p5.Vector.mult(dirToCenter, pullStrength));

            let radiusVec = p5.Vector.sub(this.pos, target);
            let spinDir = radiusVec.cross(galaxyNormal);
            spinDir.normalize();
            let spinStrength = p.map(dist, 0, 300, 0.3, 0.03);
            this.vel.add(p5.Vector.mult(spinDir, spinStrength));

            if (this.life > 200) {
                this.vel.y -= 0.03;
            }
            this.vel.mult(0.95);
            this.pos.add(this.vel);
            let n = p.noise(this.pos.x * 0.01, this.pos.y * 0.01, p.frameCount * 0.01 + this.noiseOffset);
            this.pos.x += p.map(n, 0, 1, -0.2, 0.2);
            this.pos.y += p.map(n, 0, 1, -0.2, 0.2);
            this.life -= 1.5;
        }

        show() {
            p.push();
            p.translate(this.pos.x, this.pos.y, this.pos.z);

            // Fixed White Color (by User Request)
            p.fill(255, 255, 255, this.life); // White with alpha based on life
            p.noStroke();
            // SIZE TWEAK: Reduced max size from 5.0 to 3.0 to prevent clumping
            let pSize = p.map(this.life, 255, 0, 3.0, 0.8);
            p.ellipse(0, 0, pSize);
            p.pop();
        }
    }


});