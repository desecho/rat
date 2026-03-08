import Foundation

class EatingState: PetState {
    let stateID: RatStateID = .eating
    private var elapsed: TimeInterval = 0
    private var hasEaten = false

    func enter(ratPet: RatPet, screenBounds: ScreenBounds, animationController: AnimationController) {
        elapsed = 0
        hasEaten = false
        ratPet.velocity = .zero
        ratPet.isClimbing = false
        animationController.play("eat")
    }

    func exit(ratPet: RatPet) {}

    func update(dt: TimeInterval, ratPet: RatPet, screenBounds: ScreenBounds) -> RatStateID? {
        elapsed += dt

        if elapsed >= PetConfig.eatDuration / 2 && !hasEaten {
            ratPet.feed()
            hasEaten = true
        }

        if elapsed >= PetConfig.eatDuration {
            return .idle
        }
        return nil
    }
}
