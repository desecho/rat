import AppKit

class PetWindow: NSWindow {
    init() {
        let w = PetConfig.renderWidth
        let h = PetConfig.renderHeight
        super.init(
            contentRect: CGRect(x: 0, y: 0, width: w, height: h),
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
        let origin = CGPoint(
            x: point.x - PetConfig.renderWidth / 2,
            y: point.y
        )
        setFrameOrigin(origin)
    }
}
