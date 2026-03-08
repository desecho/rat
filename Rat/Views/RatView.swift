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
        let size = PetConfig.renderSize
        super.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        wantsLayer = true

        spriteLayer.frame = CGRect(x: 0, y: 0, width: size, height: size)
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

        let size = PetConfig.renderSize

        var transform = CATransform3DIdentity
        if ratPet.isClimbing {
            if ratPet.climbingSide == .left {
                transform = CATransform3DMakeRotation(-.pi / 2, 0, 0, 1)
            } else {
                transform = CATransform3DMakeRotation(.pi / 2, 0, 0, 1)
            }
        } else if ratPet.facingLeft {
            transform = CATransform3DMakeScale(-1, 1, 1)
        }

        spriteLayer.transform = transform
        spriteLayer.frame = CGRect(x: 0, y: 0, width: size, height: size)
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
