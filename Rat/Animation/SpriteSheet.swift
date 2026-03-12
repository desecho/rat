import AppKit

class SpriteSheet {
    let frames: [CGImage]

    init(frames: [CGImage]) {
        self.frames = frames
    }

    private static func loadPNGFrames(name: String, frameCount: Int) -> [CGImage]? {
        var frames: [CGImage] = []
        for i in 1...frameCount {
            let resource = "rat-\(name)-\(i)"
            guard let url = Bundle.main.url(forResource: resource, withExtension: "png", subdirectory: "Sprites"),
                  let nsImage = NSImage(contentsOf: url) else {
                // If frame 1 exists but later frames don't, repeat frame 1
                if i > 1 && !frames.isEmpty {
                    while frames.count < frameCount {
                        frames.append(frames[0])
                    }
                    return frames
                }
                return nil
            }
            var rect = CGRect(origin: .zero, size: nsImage.size)
            guard let cgImage = nsImage.cgImage(forProposedRect: &rect, context: nil, hints: nil) else {
                return nil
            }
            guard let flipped = flipHorizontally(cgImage) else { return nil }
            frames.append(flipped)
        }
        return frames
    }

    private static func flipHorizontally(_ image: CGImage) -> CGImage? {
        let w = image.width
        let h = image.height
        guard let ctx = CGContext(
            data: nil, width: w, height: h,
            bitsPerComponent: 8, bytesPerRow: w * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        ctx.translateBy(x: CGFloat(w), y: 0)
        ctx.scaleBy(x: -1, y: 1)
        ctx.draw(image, in: CGRect(x: 0, y: 0, width: w, height: h))
        return ctx.makeImage()
    }

    static func generate(name: String, frameCount: Int, size: Int = 32) -> SpriteSheet {
        guard let pngFrames = loadPNGFrames(name: name, frameCount: frameCount) else {
            fatalError("Missing PNG sprites for animation '\(name)' in Sprites/ directory")
        }
        return SpriteSheet(frames: pngFrames)
    }
}
