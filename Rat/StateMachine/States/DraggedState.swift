import Foundation

class DraggedState: PetState {
    let stateID: RatStateID = .dragged

    func enter(ratPet: RatPet, screenBounds: ScreenBounds, animationController: AnimationController) {
        ratPet.velocity = .zero
        ratPet.isClimbing = false
        animationController.play("dragged")
    }

    func exit(ratPet: RatPet) {}

    func update(dt: TimeInterval, ratPet: RatPet, screenBounds: ScreenBounds) -> RatStateID? {
        // Stays in dragged state until mouse up triggers force transition
        return nil
    }
}
