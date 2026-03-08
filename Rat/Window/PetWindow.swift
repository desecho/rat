import AppKit

class PetWindow: NSWindow {
    init() {
        let size = PetConfig.renderSize
        super.init(
            contentRect: CGRect(x: 0, y: 0, width: size, height: size),
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        self.level = .floating
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.isMovableByWindowBackground = false
    }

    override var canBecomeKey: Bool { true }

    /// Move window so the sprite's bottom-center is at the given screen point
    func trackPosition(_ point: CGPoint) {
        let size = PetConfig.renderSize
        let origin = CGPoint(
            x: point.x - size / 2,
            y: point.y
        )
        setFrameOrigin(origin)
    }
}
