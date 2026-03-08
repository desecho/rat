import AppKit
import QuartzCore

class CursorBehavior {
    private let ratPet: RatPet
    private let stateMachine: StateMachine
    private var cooldown: TimeInterval = 0
    private var lastUpdate: TimeInterval = 0

    init(ratPet: RatPet, stateMachine: StateMachine) {
        self.ratPet = ratPet
        self.stateMachine = stateMachine
        self.lastUpdate = CACurrentMediaTime()
    }

    func update(cursorPosition: CGPoint) {
        let now = CACurrentMediaTime()
        let dt = now - lastUpdate
        lastUpdate = now

        if cooldown > 0 {
            cooldown -= dt
            return
        }

        let ratCenter = CGPoint(
            x: ratPet.position.x,
            y: ratPet.position.y + PetConfig.renderSize / 2
        )
        let dx = cursorPosition.x - ratCenter.x
        let dy = cursorPosition.y - ratCenter.y
        let distance = sqrt(dx * dx + dy * dy)

        let current = stateMachine.currentStateID
        guard current != .dragged && current != .falling && current != .cursorInteract else { return }

        if distance < PetConfig.cursorNoticeRadius {
            stateMachine.forceTransition(to: .cursorInteract)
            if let interactState = stateMachine.currentState as? CursorInteractState {
                interactState.cursorPosition = cursorPosition
            }
            cooldown = 3.0
        }
    }
}
