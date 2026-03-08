import Foundation

class CursorInteractState: PetState {
    let stateID: RatStateID = .cursorInteract
    private var elapsed: TimeInterval = 0
    private var behavior: CursorReaction = .follow
    var cursorPosition: CGPoint = .zero

    func enter(ratPet: RatPet, screenBounds: ScreenBounds, animationController: AnimationController) {
        elapsed = 0
        ratPet.isClimbing = false
        behavior = Bool.random() ? .follow : .flee
        animationController.play("walk")
    }

    func exit(ratPet: RatPet) {
        ratPet.velocity = .zero
    }

    func update(dt: TimeInterval, ratPet: RatPet, screenBounds: ScreenBounds) -> RatStateID? {
        elapsed += dt

        let dx = cursorPosition.x - ratPet.position.x
        let distance = abs(dx)

        switch behavior {
        case .follow:
            if distance > PetConfig.renderSize {
                let dir: CGFloat = dx > 0 ? 1 : -1
                ratPet.position.x += dir * PetConfig.cursorFollowSpeed * CGFloat(dt)
                ratPet.facingLeft = dir < 0
            }
        case .flee:
            if distance < PetConfig.cursorFleeRadius {
                let dir: CGFloat = dx > 0 ? -1 : 1
                ratPet.position.x += dir * PetConfig.cursorFleeSpeed * CGFloat(dt)
                ratPet.facingLeft = dir > 0
            }
        }

        // Keep in bounds
        ratPet.position.x = max(screenBounds.minX + PetConfig.renderSize / 2,
                                min(screenBounds.maxX - PetConfig.renderSize / 2, ratPet.position.x))
        ratPet.position.y = screenBounds.groundY

        // Return to normal after cursor moves away
        if distance > PetConfig.cursorNoticeRadius || elapsed > 8.0 {
            return .idle
        }

        return nil
    }
}

enum CursorReaction {
    case follow
    case flee
}
