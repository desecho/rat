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
                    return normalizeFrames(frames)
                }
                return nil
            }
            var rect = CGRect(origin: .zero, size: nsImage.size)
            guard let cgImage = nsImage.cgImage(forProposedRect: &rect, context: nil, hints: nil) else {
                return nil
            }
            frames.append(cgImage)
        }

        return normalizeFrames(frames)
    }

    private static func normalizeFrames(_ frames: [CGImage]) -> [CGImage]? {
        let rasterizedFrames = frames.compactMap(rasterizeRGBA)
        guard rasterizedFrames.count == frames.count else { return nil }

        let normalizedFrames: [CGImage]
        if let bounds = sharedOpaqueBounds(in: rasterizedFrames) {
            normalizedFrames = rasterizedFrames.compactMap { crop($0, to: bounds) }
            guard normalizedFrames.count == rasterizedFrames.count else { return nil }
        } else {
            normalizedFrames = rasterizedFrames
        }

        let flippedFrames = normalizedFrames.compactMap(flipHorizontally)
        return flippedFrames.count == normalizedFrames.count ? flippedFrames : nil
    }

    private static func sharedOpaqueBounds(in frames: [CGImage]) -> CGRect? {
        var unionBounds: CGRect?

        for frame in frames {
            guard let bounds = opaqueBounds(in: frame) else { continue }
            unionBounds = unionBounds?.union(bounds) ?? bounds
        }

        guard let unionBounds else { return nil }
        return unionBounds.integral
    }

    private static func opaqueBounds(in image: CGImage) -> CGRect? {
        guard let data = image.dataProvider?.data,
              let bytes = CFDataGetBytePtr(data) else {
            return nil
        }

        let width = image.width
        let height = image.height
        let bytesPerRow = image.bytesPerRow

        var minX = width
        var minY = height
        var maxX = -1
        var maxY = -1

        for y in 0..<height {
            let rowOffset = y * bytesPerRow
            for x in 0..<width {
                let alpha = bytes[rowOffset + (x * 4) + 3]
                guard alpha > 0 else { continue }

                minX = min(minX, x)
                minY = min(minY, y)
                maxX = max(maxX, x)
                maxY = max(maxY, y)
            }
        }

        guard maxX >= minX, maxY >= minY else { return nil }
        return CGRect(
            x: CGFloat(minX),
            y: CGFloat(minY),
            width: CGFloat(maxX - minX + 1),
            height: CGFloat(maxY - minY + 1)
        )
    }

    private static func crop(_ image: CGImage, to bounds: CGRect) -> CGImage? {
        let cropX = max(0, Int(bounds.minX))
        let cropY = max(0, Int(bounds.minY))
        let cropRect = CGRect(
            x: CGFloat(cropX),
            y: CGFloat(cropY),
            width: CGFloat(min(image.width - cropX, Int(bounds.width))),
            height: CGFloat(min(image.height - cropY, Int(bounds.height)))
        )

        guard cropRect.width > 0, cropRect.height > 0 else { return nil }
        return image.cropping(to: cropRect)
    }

    private static func rasterizeRGBA(_ image: CGImage) -> CGImage? {
        let w = image.width
        let h = image.height
        guard let ctx = CGContext(
            data: nil, width: w, height: h,
            bitsPerComponent: 8, bytesPerRow: w * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        ctx.draw(image, in: CGRect(x: 0, y: 0, width: w, height: h))
        return ctx.makeImage()
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
