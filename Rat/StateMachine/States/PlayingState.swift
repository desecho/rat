import Foundation

class PlayingState: PetState {
    let stateID: RatStateID = .playing
    private var elapsed: TimeInterval = 0
    private var hasPlayed = false

    func enter(ratPet: RatPet, screenBounds: ScreenBounds, animationController: AnimationController) {
        elapsed = 0
        hasPlayed = false
        ratPet.velocity = .zero
        ratPet.isClimbing = false
        animationController.play("play")
    }

    func exit(ratPet: RatPet) {}

    func update(dt: TimeInterval, ratPet: RatPet, screenBounds: ScreenBounds) -> RatStateID? {
        elapsed += dt

        if elapsed >= PetConfig.playDuration / 2 && !hasPlayed {
            ratPet.play()
            hasPlayed = true
        }

        if elapsed >= PetConfig.playDuration {
            return .idle
        }
        return nil
    }
}
