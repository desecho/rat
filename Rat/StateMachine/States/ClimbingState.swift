import Foundation

class ClimbingState: PetState {
    let stateID: RatStateID = .climbing
    private var startY: CGFloat = 0
    private var climbedHeight: CGFloat = 0

    func enter(ratPet: RatPet, screenBounds: ScreenBounds, animationController: AnimationController) {
        startY = ratPet.position.y
        climbedHeight = 0
        ratPet.isClimbing = true
        ratPet.velocity = CGPoint(x: 0, y: PetConfig.climbSpeed)

        if ratPet.climbingSide == .left {
            ratPet.position.x = screenBounds.minX + PetConfig.renderHeight / 2
        } else {
            ratPet.position.x = screenBounds.maxX - PetConfig.renderHeight / 2
        }
        animationController.play("climb")
    }

    func exit(ratPet: RatPet) {
        ratPet.isClimbing = false
        ratPet.velocity = .zero
    }

    func update(dt: TimeInterval, ratPet: RatPet, screenBounds: ScreenBounds) -> RatStateID? {
        ratPet.position.y += PetConfig.climbSpeed * CGFloat(dt)
        climbedHeight = ratPet.position.y - startY

        // Stop at max climb height or top of screen
        if climbedHeight >= PetConfig.climbMaxHeight ||
           ratPet.position.y >= screenBounds.maxY - PetConfig.renderHeight {
            // Let go and fall
            return .falling
        }

        return nil
    }
}
