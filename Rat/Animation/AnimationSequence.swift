import AppKit

class AnimationSequence {
    let name: String
    let spriteSheet: SpriteSheet
    let looping: Bool
    private let frameDuration: TimeInterval
    private(set) var currentFrameIndex: Int = 0
    private var elapsed: TimeInterval = 0
    var isFinished: Bool = false

    init(name: String, spriteSheet: SpriteSheet, looping: Bool = true, frameDuration: TimeInterval = PetConfig.frameDuration) {
        self.name = name
        self.spriteSheet = spriteSheet
        self.looping = looping
        self.frameDuration = frameDuration
    }

    func reset() {
        currentFrameIndex = 0
        elapsed = 0
        isFinished = false
    }

    func update(dt: TimeInterval) {
        elapsed += dt
        if elapsed >= frameDuration {
            elapsed -= frameDuration
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
