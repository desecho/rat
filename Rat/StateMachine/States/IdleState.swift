import Foundation

class IdleState: PetState {
    let stateID: RatStateID = .idle
    private var elapsed: TimeInterval = 0
    private var duration: TimeInterval = 0

    func enter(ratPet: RatPet, screenBounds: ScreenBounds, animationController: AnimationController) {
        elapsed = 0
        duration = TimeInterval.random(in: PetConfig.idleMinDuration...PetConfig.idleMaxDuration)
        ratPet.velocity = .zero
        ratPet.isClimbing = false
        animationController.play("idle")
    }

    func exit(ratPet: RatPet) {}

    func update(dt: TimeInterval, ratPet: RatPet, screenBounds: ScreenBounds) -> RatStateID? {
        elapsed += dt
        guard elapsed >= duration else { return nil }

        // Weighted random transition
        let sleepWeight = ratPet.isTired ? 0.4 : PetConfig.idleToSleepWeight
        let eatWeight = ratPet.isHungry ? 0.3 : PetConfig.idleToEatWeight
        let playWeight = ratPet.isBored ? 0.3 : PetConfig.idleToPlayWeight
        let walkWeight = PetConfig.idleToWalkWeight
        let totalWeight = walkWeight + sleepWeight + eatWeight + playWeight
        let roll = Double.random(in: 0..<totalWeight)
        var cumulative = 0.0

        cumulative += walkWeight
        if roll < cumulative { return .walking }

        cumulative += sleepWeight
        if roll < cumulative { return .sleeping }

        cumulative += eatWeight
        if roll < cumulative { return .eating }

        cumulative += playWeight
        if roll < cumulative { return .playing }

        return .walking
    }
}
