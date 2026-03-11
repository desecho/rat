import AppKit

class AnimationController {
    private var sequences: [String: AnimationSequence] = [:]
    private(set) var currentSequenceName: String = "idle"

    init() {
        registerAll()
    }

    private func registerAll() {
        register(name: "idle", frameCount: 4, fps: 5)
        register(name: "walk", frameCount: 4, fps: 10)
        register(name: "sleep", frameCount: 4, fps: 2)
        register(name: "eat", frameCount: 4, fps: 8)
        registerAlias(name: "climb", source: "walk", fps: 8)
        registerAlias(name: "dragged", source: "idle", fps: 4)
        registerAlias(name: "fall", source: "idle", fps: 6)
    }

    private func registerAlias(name: String, source: String, fps: Double, looping: Bool = true) {
        guard let sourceSeq = sequences[source] else { return }
        sequences[name] = AnimationSequence(
            name: name,
            spriteSheet: sourceSeq.spriteSheet,
            looping: looping,
            frameDuration: 1.0 / fps
        )
    }

    private func register(name: String, frameCount: Int, fps: Double, looping: Bool = true) {
        let sheet = SpriteSheet.generate(name: name, frameCount: frameCount)
        sequences[name] = AnimationSequence(
            name: name,
            spriteSheet: sheet,
            looping: looping,
            frameDuration: 1.0 / fps
        )
    }

    func play(_ name: String) {
        guard name != currentSequenceName else { return }
        guard sequences[name] != nil else { return }
        currentSequenceName = name
        sequences[name]?.reset()
    }

    func update(dt: TimeInterval) {
        sequences[currentSequenceName]?.update(dt: dt)
    }

    func currentFrame() -> CGImage? {
        return sequences[currentSequenceName]?.currentFrame()
    }
}
