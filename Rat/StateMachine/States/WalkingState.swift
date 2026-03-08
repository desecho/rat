import Foundation

class WalkingState: PetState {
    let stateID: RatStateID = .walking
    private var elapsed: TimeInterval = 0
    private var duration: TimeInterval = 0

    func enter(ratPet: RatPet, screenBounds: ScreenBounds, animationController: AnimationController) {
        elapsed = 0
        duration = TimeInterval.random(in: PetConfig.walkMinDuration...PetConfig.walkMaxDuration)
        ratPet.isClimbing = false

        // Pick random direction
        let goLeft = Bool.random()
        ratPet.facingLeft = goLeft
        ratPet.velocity = CGPoint(
            x: goLeft ? -PetConfig.walkSpeed : PetConfig.walkSpeed,
            y: 0
        )
        animationController.play("walk")
    }

    func exit(ratPet: RatPet) {
        ratPet.velocity = .zero
    }

    func update(dt: TimeInterval, ratPet: RatPet, screenBounds: ScreenBounds) -> RatStateID? {
        elapsed += dt

        // Move
        ratPet.position.x += ratPet.velocity.x * CGFloat(dt)

        // Keep on ground
        ratPet.position.y = screenBounds.groundY

        // Check screen edges
        if ratPet.position.x <= screenBounds.minX + PetConfig.renderSize / 2 {
            ratPet.position.x = screenBounds.minX + PetConfig.renderSize / 2
            // Chance to climb
            let roll = Double.random(in: 0...1)
            if roll < PetConfig.walkToClimbWeight {
                ratPet.climbingSide = .left
                return .climbing
            }
            // Turn around
            ratPet.facingLeft = false
            ratPet.velocity.x = PetConfig.walkSpeed
        } else if ratPet.position.x >= screenBounds.maxX - PetConfig.renderSize / 2 {
            ratPet.position.x = screenBounds.maxX - PetConfig.renderSize / 2
            let roll = Double.random(in: 0...1)
            if roll < PetConfig.walkToClimbWeight {
                ratPet.climbingSide = .right
                return .climbing
            }
            ratPet.facingLeft = true
            ratPet.velocity.x = -PetConfig.walkSpeed
        }

        if elapsed >= duration {
            let roll = Double.random(in: 0...1)
            if roll < PetConfig.walkToIdleWeight {
                return .idle
            }
            return .idle
        }

        return nil
    }
}
