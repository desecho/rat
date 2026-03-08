import Foundation

class StateMachine {
    private var states: [RatStateID: PetState] = [:]
    private(set) var currentState: PetState
    private let ratPet: RatPet
    private let screenBounds: ScreenBounds
    private let animationController: AnimationController

    var currentStateID: RatStateID { currentState.stateID }

    init(ratPet: RatPet, screenBounds: ScreenBounds, animationController: AnimationController) {
        self.ratPet = ratPet
        self.screenBounds = screenBounds
        self.animationController = animationController

        let idle = IdleState()
        let walking = WalkingState()
        let sleeping = SleepingState()
        let eating = EatingState()
        let climbing = ClimbingState()
        let dragged = DraggedState()
        let falling = FallingState()
        let cursorInteract = CursorInteractState()

        states[.idle] = idle
        states[.walking] = walking
        states[.sleeping] = sleeping
        states[.eating] = eating
        states[.climbing] = climbing
        states[.dragged] = dragged
        states[.falling] = falling
        states[.cursorInteract] = cursorInteract

        currentState = idle
        idle.enter(ratPet: ratPet, screenBounds: screenBounds, animationController: animationController)
    }

    func update(dt: TimeInterval) {
        if let nextID = currentState.update(dt: dt, ratPet: ratPet, screenBounds: screenBounds) {
            transition(to: nextID)
        }
    }

    func forceTransition(to stateID: RatStateID) {
        transition(to: stateID)
    }

    private func transition(to stateID: RatStateID) {
        guard let nextState = states[stateID] else { return }
        currentState.exit(ratPet: ratPet)
        currentState = nextState
        nextState.enter(ratPet: ratPet, screenBounds: screenBounds, animationController: animationController)
    }
}
