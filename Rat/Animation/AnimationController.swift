import AppKit

class AnimationController {
    private var sequences: [String: AnimationSequence] = [:]
    private(set) var currentSequenceName: String = "idle"

    init() {
        registerAll()
    }

    private func registerAll() {
        register(name: "idle", frameCount: 4)
        register(name: "walk", frameCount: 4)
        register(name: "sleep", frameCount: 3)
        register(name: "eat", frameCount: 4)
        register(name: "climb", frameCount: 4)
        register(name: "dragged", frameCount: 2)
        register(name: "fall", frameCount: 2)
    }

    private func register(name: String, frameCount: Int, looping: Bool = true) {
        let sheet = SpriteSheet.generate(name: name, frameCount: frameCount)
        sequences[name] = AnimationSequence(name: name, spriteSheet: sheet, looping: looping)
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
