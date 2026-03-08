import AppKit

class AnimationSequence {
    let name: String
    let spriteSheet: SpriteSheet
    let looping: Bool
    private(set) var currentFrameIndex: Int = 0
    private var elapsed: TimeInterval = 0
    var isFinished: Bool = false

    init(name: String, spriteSheet: SpriteSheet, looping: Bool = true) {
        self.name = name
        self.spriteSheet = spriteSheet
        self.looping = looping
    }

    func reset() {
        currentFrameIndex = 0
        elapsed = 0
        isFinished = false
    }

    func update(dt: TimeInterval) {
        elapsed += dt
        if elapsed >= PetConfig.frameDuration {
            elapsed -= PetConfig.frameDuration
            currentFrameIndex += 1
            if currentFrameIndex >= spriteSheet.frames.count {
                if looping {
                    currentFrameIndex = 0
                } else {
                    currentFrameIndex = spriteSheet.frames.count - 1
                    isFinished = true
                }
            }
        }
    }

    func currentFrame() -> CGImage? {
        guard !spriteSheet.frames.isEmpty else { return nil }
        return spriteSheet.frames[currentFrameIndex]
    }
}
