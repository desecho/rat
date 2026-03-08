import Foundation

class FallingState: PetState {
    let stateID: RatStateID = .falling
    private var bounceCount = 0

    func enter(ratPet: RatPet, screenBounds: ScreenBounds, animationController: AnimationController) {
        ratPet.isClimbing = false
        bounceCount = 0
        if ratPet.velocity.y >= 0 {
            ratPet.velocity.y = 0
        }
        animationController.play("fall")
    }

    func exit(ratPet: RatPet) {
        ratPet.velocity = .zero
    }

    func update(dt: TimeInterval, ratPet: RatPet, screenBounds: ScreenBounds) -> RatStateID? {
        // Apply gravity
        ratPet.velocity.y -= PetConfig.fallGravity * CGFloat(dt)
        ratPet.velocity.y = max(-PetConfig.terminalVelocity, ratPet.velocity.y)

        ratPet.position.y += ratPet.velocity.y * CGFloat(dt)

        // Hit ground
        if ratPet.position.y <= screenBounds.groundY {
            ratPet.position.y = screenBounds.groundY
            bounceCount += 1

            if bounceCount >= 3 || abs(ratPet.velocity.y) < 20 {
                return .idle
            }

            // Bounce
            ratPet.velocity.y = abs(ratPet.velocity.y) * PetConfig.bounceDecay
        }

        return nil
    }
}
