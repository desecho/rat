import AppKit

class SpriteSheet {
    let frames: [CGImage]

    init(frames: [CGImage]) {
        self.frames = frames
    }

    static func generate(name: String, frameCount: Int, size: Int = 32) -> SpriteSheet {
        if let referenceFrames = ReferenceSprite.generate(name: name, frameCount: frameCount) {
            return SpriteSheet(frames: referenceFrames)
        }

        var frames: [CGImage] = []
        for i in 0..<frameCount {
            let image = SpriteGenerator.generateFrame(name: name, frameIndex: i, size: size)
            frames.append(image)
        }
        return SpriteSheet(frames: frames)
    }
}

private enum ReferenceSprite {
    private static let baseFrame: CGImage? = load()

    static func generate(name: String, frameCount: Int) -> [CGImage]? {
        guard let baseFrame else { return nil }

        let yOffsets = offsets(for: name, frameCount: frameCount)
        let frames = yOffsets.compactMap { render(baseFrame: baseFrame, yOffset: $0) }
        guard frames.count == frameCount else { return nil }
        return frames
    }

    private static func load() -> CGImage? {
        guard let url = Bundle.main.url(forResource: "rat-reference", withExtension: "png"),
              let image = NSImage(contentsOf: url) else {
            return nil
        }

        var rect = CGRect(origin: .zero, size: image.size)
        return image.cgImage(forProposedRect: &rect, context: nil, hints: nil)
    }

    private static func offsets(for name: String, frameCount: Int) -> [Int] {
        let pattern: [Int]

        switch name {
        case "walk":
            pattern = [0, 2, 0, 1]
        case "climb":
            pattern = [0, 1, 0, 1]
        case "sleep":
            pattern = [1, 0, 1]
        case "eat":
            pattern = [0, 1, 0, 1]
        case "dragged":
            pattern = [0, 1]
        case "fall":
            pattern = [0, 2]
        default:
            pattern = [0, 1, 0, 0]
        }

        if pattern.count == frameCount {
            return pattern
        }

        return (0..<frameCount).map { pattern[$0 % pattern.count] }
    }

    private static func render(baseFrame: CGImage, yOffset: Int) -> CGImage? {
        let width = baseFrame.width
        let height = baseFrame.height

        guard let ctx = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }

        ctx.clear(CGRect(x: 0, y: 0, width: width, height: height))
        ctx.interpolationQuality = .none
        ctx.draw(
            baseFrame,
            in: CGRect(
                x: 0,
                y: -CGFloat(yOffset),
                width: CGFloat(width),
                height: CGFloat(height)
            )
        )
        return ctx.makeImage()
    }
}

class SpriteGenerator {
    private static let palette: [(r: Double, g: Double, b: Double, a: Double)] = [
        (0.00, 0.00, 0.00, 0.00), // 0: transparent
        (0.10, 0.10, 0.12, 1.00), // 1: outline
        (0.27, 0.27, 0.30, 1.00), // 2: deep shadow
        (0.43, 0.43, 0.45, 1.00), // 3: body gray
        (0.58, 0.58, 0.60, 1.00), // 4: highlight gray
        (0.80, 0.80, 0.82, 1.00), // 5: belly
        (0.90, 0.68, 0.70, 1.00), // 6: ear / nose pink
        (0.78, 0.56, 0.58, 1.00), // 7: tail / paw pink
        (0.98, 0.98, 1.00, 1.00), // 8: eye / snore
        (0.12, 0.12, 0.12, 0.35), // 9: soft shadow
    ]

    static func generateFrame(name: String, frameIndex: Int, size: Int) -> CGImage {
        let bitmap: [[Int]]
        switch name {
        case "idle": bitmap = idleFrames[frameIndex % idleFrames.count]
        case "walk": bitmap = walkFrames[frameIndex % walkFrames.count]
        case "sleep": bitmap = sleepFrames[frameIndex % sleepFrames.count]
        case "eat": bitmap = eatFrames[frameIndex % eatFrames.count]
        case "climb": bitmap = climbFrames[frameIndex % climbFrames.count]
        case "dragged": bitmap = draggedFrames[frameIndex % draggedFrames.count]
        case "fall": bitmap = fallFrames[frameIndex % fallFrames.count]
        default: bitmap = idleFrames[0]
        }

        let ctx = CGContext(
            data: nil,
            width: size,
            height: size,
            bitsPerComponent: 8,
            bytesPerRow: size * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        ctx.clear(CGRect(x: 0, y: 0, width: size, height: size))

        for row in 0..<min(bitmap.count, size) {
            for col in 0..<min(bitmap[row].count, size) {
                let idx = bitmap[row][col]
                if idx == 0 { continue }
                let c = palette[idx]
                ctx.setFillColor(red: c.r, green: c.g, blue: c.b, alpha: c.a)
                ctx.fill(CGRect(x: col, y: size - 1 - row, width: 1, height: 1))
            }
        }

        return ctx.makeImage()!
    }

    private static func p(_ s: String) -> String {
        if s.count < 32 {
            return s + String(repeating: " ", count: 32 - s.count)
        }
        return String(s.prefix(32))
    }

    private static func makeRows(_ strings: [String], topPadding: Int = 0) -> [[Int]] {
        var rows = Array(repeating: "", count: topPadding) + strings
        if rows.count < 32 {
            rows.append(contentsOf: Array(repeating: "", count: 32 - rows.count))
        }

        return rows.prefix(32).map { p($0) }.map { row in
            row.map { ch -> Int in
                if let n = Int(String(ch)) { return n }
                return 0
            }
        }
    }

    // MARK: Idle

    static let idleFrames: [[[Int]]] = [idleBase, idleSniff, idleBase, idleEarTwitch]

    static let idleBase: [[Int]] = makeRows([
        "                  99   99",
        "                 9166116619",
        "                 91666666611",
        "                911444444411",
        "7             1133333333333311",
        " 7          11334444443338333311",
        " 77       1133333333333333333311",
        "  771111133333333333333333331166",
        "   771333333333333333333333311 1",
        "   13333333334444443333333311  1",
        "   13333333333335555533333333311",
        "   13334444335555555533333333311",
        "    113333335555555555113333311",
        "     17 17  1355555551 17 71",
        "      7  7   11555511  7  7",
    ], topPadding: 12)

    static let idleSniff: [[Int]] = makeRows([
        "                  99   99",
        "                 9166116619",
        "                 91666666611",
        "                911444444411",
        "7             1133333333333311",
        " 7          11334444443338333311",
        " 77       1133333333333333333311",
        "  771111133333333333333333311666",
        "   77133333333333333333333311  1",
        "   1333333333444444333333311   1",
        "   13333333333335555533333333311",
        "   13334444335555555533333333311",
        "    113333335555555555113333311",
        "     17 17  1355555551 17 71",
        "      7  7   11555511  7  7",
    ], topPadding: 12)

    static let idleEarTwitch: [[Int]] = makeRows([
        "                 99    99",
        "                9166 116619",
        "                916661666611",
        "                 11444444411",
        "7             1133333333333311",
        " 7          11334444443338333311",
        " 77       1133333333333333333311",
        "  771111133333333333333333331166",
        "   771333333333333333333333311 1",
        "   13333333334444443333333311  1",
        "   13333333333335555533333333311",
        "   13334444335555555533333333311",
        "    113333335555555555113333311",
        "     17 17  1355555551 17 71",
        "      7  7   11555511  7  7",
    ], topPadding: 11)

    // MARK: Walk

    static let walkFrames: [[[Int]]] = [walkF0, walkF1, walkF2, walkF3]

    static let walkF0: [[Int]] = makeRows([
        "                  99   99",
        "                 9166116619",
        "                 91666666611",
        "                911444444411",
        "7             1133333333333311",
        " 7          11334444443338333311",
        " 77       1133333333333333333311",
        "  771111133333333333333333331166",
        "   771333333333333333333333311 1",
        "   13333333334444443333333311  1",
        "   13333333333335555533333333311",
        "   13334444335555555533333333311",
        "    113333335555555555113333311",
        "     17  7   17 17",
        "      7  7    7 7",
    ], topPadding: 12)

    static let walkF1: [[Int]] = makeRows([
        "                  99   99",
        "                 9166116619",
        "                 91666666611",
        "                911444444411",
        "7             1133333333333311",
        " 7          11334444443338333311",
        " 77       1133333333333333333311",
        "  771111133333333333333333331166",
        "   771333333333333333333333311 1",
        "   13333333334444443333333311  1",
        "   13333333333335555533333333311",
        "   13334444335555555533333333311",
        "    113333335555555555113333311",
        "      17 17  7 17",
        "       7  7   7  7",
    ], topPadding: 12)

    static let walkF2: [[Int]] = makeRows([
        "                  99   99",
        "                 9166116619",
        "                 91666666611",
        "                911444444411",
        "7             1133333333333311",
        " 7          11334444443338333311",
        " 77       1133333333333333333311",
        "  771111133333333333333333331166",
        "   771333333333333333333333311 1",
        "   13333333334444443333333311  1",
        "   13333333333335555533333333311",
        "   13334444335555555533333333311",
        "    113333335555555555113333311",
        "     17 17   17 7",
        "      7  7    7  7",
    ], topPadding: 12)

    static let walkF3: [[Int]] = makeRows([
        "                  99   99",
        "                 9166116619",
        "                 91666666611",
        "                911444444411",
        "7             1133333333333311",
        " 7          11334444443338333311",
        " 77       1133333333333333333311",
        "  771111133333333333333333331166",
        "   771333333333333333333333311 1",
        "   13333333334444443333333311  1",
        "   13333333333335555533333333311",
        "   13334444335555555533333333311",
        "    113333335555555555113333311",
        "      17  7  17 17",
        "       7  7   7  7",
    ], topPadding: 12)

    // MARK: Sleep

    static let sleepFrames: [[[Int]]] = [sleepF0, sleepF1, sleepF2]

    static let sleepF0: [[Int]] = makeRows([
        "              88",
        "             8  8",
        "              88",
        "            91661",
        "           133331",
        "7777      1333333111",
        "    7   1333333333311",
        "     7 13334455533311",
        "      713335555553311",
        "       13333333333311",
        "        1111111111111",
    ], topPadding: 15)

    static let sleepF1: [[Int]] = makeRows([
        "             88",
        "            8  8",
        "             88",
        "           88",
        "          8  8",
        "            91661",
        "           133331",
        "7777      1333333111",
        "    7   1333333333311",
        "     7 13334455533311",
        "      713335555553311",
        "       13333333333311",
        "        1111111111111",
    ], topPadding: 14)

    static let sleepF2: [[Int]] = makeRows([
        "            88",
        "           8  8",
        "            88",
        "          88",
        "         8  8",
        "          88",
        "            91661",
        "           133331",
        "7777      1333333111",
        "    7   1333333333311",
        "     7 13334455533311",
        "      713335555553311",
        "       13333333333311",
        "        1111111111111",
    ], topPadding: 13)

    // MARK: Eat

    static let eatFrames: [[[Int]]] = [eatF0, eatF1, eatF2, eatF1]

    static let eatF0: [[Int]] = makeRows([
        "                  99   99",
        "                 9166116619",
        "                 91666666611",
        "                911444444411",
        "7             1133333333333311",
        " 7          11334444443338333311",
        " 77       1133333333333333333311",
        "  771111133333333333333333333116",
        "   771333333333333333333333311 6",
        "   13333333334444443333333311",
        "   13333333333335555533333333311",
        "   13334444335555555533333333311",
        "    113333335555555555113333311",
        "     17 17  1355555551 17 71",
        "      7  7   11555511  7  7",
    ], topPadding: 12)

    static let eatF1: [[Int]] = makeRows([
        "                  99   99",
        "                 9166116619",
        "7                91666666611",
        " 7              11444444411",
        "  7          113333333333311",
        "  77       1133444444333833311",
        "   77111113333333333333333116",
        "   1333333333444444333333311",
        "   133333333333355555333333311",
        "   133344443355555555333333311",
        "    11333333555555555511333311",
        "     17 17  1355555551 17 71",
        "      7  7   11555511  7  7",
    ], topPadding: 13)

    static let eatF2: [[Int]] = idleBase

    // MARK: Climb

    static let climbFrames: [[[Int]]] = [walkF0, walkF1, walkF2, walkF3]

    // MARK: Dragged

    static let draggedFrames: [[[Int]]] = [dragF0, dragF1]

    static let dragF0: [[Int]] = makeRows([
        "                  99   99",
        "                 9166116619",
        "                 91666666611",
        "                911444444411",
        "7             1133333333333311",
        " 7          11334444443338833311",
        " 77       1133333333333333333311",
        "  771111133333333333333333331166",
        "   77133333333335555533333333311",
        "   13334444335555555533333333311",
        "   133333333355555555113333311",
        "    1133333555555555113333311",
        "     17 17   17 17",
        "      7  7    7  7",
        "      7  7    7  7",
        "      7  7    7  7",
    ], topPadding: 10)

    static let dragF1: [[Int]] = makeRows([
        "                  99   99",
        "                 9166116619",
        "                 91666666611",
        "                911444444411",
        "7             1133333333333311",
        " 7          11334444443338833311",
        " 77       1133333333333333333311",
        "  771111133333333333333333331166",
        "   77133333333335555533333333311",
        "   13334444335555555533333333311",
        "   133333333355555555113333311",
        "    1133333555555555113333311",
        "     17 17   17 17",
        "     7   7   7   7",
        "      7  7    7  7",
        "     7   7   7   7",
    ], topPadding: 10)

    // MARK: Fall

    static let fallFrames: [[[Int]]] = [fallF0, fallF1]

    static let fallF0: [[Int]] = makeRows([
        "                  99   99",
        "                 9166116619",
        "                 91666666611",
        "                911444444411",
        "7             1133333333333311",
        " 7          11334444443338833311",
        " 77       1133333333333333333311",
        "  771111133333333333333333331166",
        "   77133333333335555533333333311",
        "   13334444335555555533333333311",
        "   133333333355555555113333311",
        "    1133333555555555113333311",
        "   7 17 17   17 17 7",
        "  7   7  7    7  7  7",
    ], topPadding: 10)

    static let fallF1: [[Int]] = makeRows([
        "                  99   99",
        "                 9166116619",
        "                 91666666611",
        "                911444444411",
        "7             1133333333333311",
        " 7          11334444443338833311",
        " 77       1133333333333333333311",
        "  771111133333333333333333331166",
        "   77133333333335555533333333311",
        "   13334444335555555533333333311",
        "   133333333355555555113333311",
        "    1133333555555555113333311",
        "  7  17 17   17 17  7",
        " 7    7  7    7  7   7",
    ], topPadding: 10)
}
