import Foundation

enum RatStateID: String, CaseIterable {
    case idle
    case walking
    case sleeping
    case eating
    case climbing
    case dragged
    case falling
    case cursorInteract
}

protocol PetState: AnyObject {
    var stateID: RatStateID { get }
    func enter(ratPet: RatPet, screenBounds: ScreenBounds, animationController: AnimationController)
    func exit(ratPet: RatPet)
    func update(dt: TimeInterval, ratPet: RatPet, screenBounds: ScreenBounds) -> RatStateID?
}
