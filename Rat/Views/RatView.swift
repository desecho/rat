import AppKit

class RatView: NSView {
    private let ratPet: RatPet
    private let spriteLayer = CALayer()
    var animationController: AnimationController?

    var onMouseDown: ((NSEvent) -> Void)?
    var onMouseUp: ((NSEvent) -> Void)?
    var onMouseDragged: ((NSEvent) -> Void)?
    var onRightMouseDown: ((NSEvent) -> Void)?

    init(ratPet: RatPet) {
        self.ratPet = ratPet
        let w = PetConfig.renderWidth
        let h = PetConfig.renderHeight
        super.init(frame: CGRect(x: 0, y: 0, width: w, height: h))
        wantsLayer = true

        spriteLayer.frame = CGRect(x: 0, y: 0, width: w, height: h)
        spriteLayer.magnificationFilter = .nearest
        spriteLayer.contentsGravity = .resizeAspect
        spriteLayer.contentsScale = NSScreen.main?.backingScaleFactor ?? 2.0

        layer!.addSublayer(spriteLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    func updateSprite() {
        guard let controller = animationController else { return }
        if let frame = controller.currentFrame() {
            spriteLayer.contents = frame
        }

        let w = PetConfig.renderWidth
        let h = PetConfig.renderHeight

        var transform = CATransform3DIdentity
        if ratPet.isClimbing {
            if ratPet.climbingSide == .left {
                transform = CATransform3DMakeRotation(-.pi / 2, 0, 0, 1)
            } else {
                transform = CATransform3DMakeRotation(.pi / 2, 0, 0, 1)
            }
            // Swap width/height so the rotated sprite isn't squished
            self.frame = CGRect(x: 0, y: 0, width: h, height: w)
            spriteLayer.frame = CGRect(x: 0, y: 0, width: h, height: w)
        } else {
            if ratPet.facingLeft {
                transform = CATransform3DMakeScale(-1, 1, 1)
            }
            self.frame = CGRect(x: 0, y: 0, width: w, height: h)
            spriteLayer.frame = CGRect(x: 0, y: 0, width: w, height: h)
        }

        spriteLayer.transform = transform
    }

    override func mouseDown(with event: NSEvent) {
        onMouseDown?(event)
    }

    override func mouseUp(with event: NSEvent) {
        onMouseUp?(event)
    }

    override func mouseDragged(with event: NSEvent) {
        onMouseDragged?(event)
    }

    override func rightMouseDown(with event: NSEvent) {
        onRightMouseDown?(event)
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
}
