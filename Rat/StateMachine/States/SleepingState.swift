import Foundation

class SleepingState: PetState {
    let stateID: RatStateID = .sleeping
    private var elapsed: TimeInterval = 0
    private var duration: TimeInterval = 0

    func enter(ratPet: RatPet, screenBounds: ScreenBounds, animationController: AnimationController) {
        elapsed = 0
        duration = TimeInterval.random(in: PetConfig.sleepMinDuration...PetConfig.sleepMaxDuration)
        ratPet.velocity = .zero
        ratPet.isClimbing = false
        animationController.play("sleep")
    }

    func exit(ratPet: RatPet) {}

    func update(dt: TimeInterval, ratPet: RatPet, screenBounds: ScreenBounds) -> RatStateID? {
        elapsed += dt
        ratPet.rest(dt: dt)

        if elapsed >= duration || ratPet.energy >= PetConfig.maxEnergy * 0.9 {
            return .idle
        }
        return nil
    }
}
