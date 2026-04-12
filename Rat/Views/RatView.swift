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
        spriteLayer.contentsGravity = .resize
        spriteLayer.contentsScale = NSScreen.main?.backingScaleFactor ?? 2.0

        layer!.addSublayer(spriteLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    func updateSprite() {
        guard let controller = animationController else { return }
        let currentFrame = controller.currentFrame()
        if let currentFrame {
            spriteLayer.contents = currentFrame
        }

        let w = PetConfig.renderWidth
        let h = PetConfig.renderHeight

        var transform = CATransform3DIdentity
        spriteLayer.transform = CATransform3DIdentity
        if ratPet.isClimbing {
            if ratPet.climbingSide == .left {
                transform = CATransform3DMakeRotation(.pi / 2, 0, 0, 1)
                transform = CATransform3DConcat(CATransform3DMakeScale(1, -1, 1), transform)
            } else {
                transform = CATransform3DMakeRotation(.pi / 2, 0, 0, 1)
            }
            // Rotate a normal ground-sized sprite inside a tall climbing view.
            self.frame = CGRect(x: 0, y: 0, width: h, height: w)
            spriteLayer.bounds = CGRect(x: 0, y: 0, width: w, height: h)
            spriteLayer.position = CGPoint(x: h / 2, y: w / 2)
        } else {
            if ratPet.facingLeft {
                transform = CATransform3DMakeScale(-1, 1, 1)
            }
            if let currentFrame {
                let spriteFrame = Self.widthFitFrame(
                    imageSize: CGSize(width: currentFrame.width, height: currentFrame.height),
                    width: w
                )
                self.frame = CGRect(x: 0, y: 0, width: w, height: max(h, spriteFrame.height))
                spriteLayer.frame = spriteFrame
            } else {
                self.frame = CGRect(x: 0, y: 0, width: w, height: h)
                spriteLayer.frame = CGRect(x: 0, y: 0, width: w, height: h)
            }
        }

        spriteLayer.transform = transform
    }

    private static func widthFitFrame(imageSize: CGSize, width: CGFloat) -> CGRect {
        guard imageSize.width > 0, imageSize.height > 0 else {
            return CGRect(x: 0, y: 0, width: width, height: PetConfig.renderHeight)
        }

        let scale = width / imageSize.width
        let fittedSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        return CGRect(
            x: 0,
            y: 0,
            width: fittedSize.width,
            height: fittedSize.height
        )
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
