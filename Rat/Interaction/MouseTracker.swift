import AppKit

class MouseTracker {
    private let ratPet: RatPet
    private let stateMachine: StateMachine
    private var globalMonitor: Any?
    private var cursorBehavior: CursorBehavior

    init(ratPet: RatPet, stateMachine: StateMachine) {
        self.ratPet = ratPet
        self.stateMachine = stateMachine
        self.cursorBehavior = CursorBehavior(ratPet: ratPet, stateMachine: stateMachine)
    }

    func start() {
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .leftMouseDragged]) { [weak self] event in
            self?.handleMouseMove()
        }
    }

    func stop() {
        if let monitor = globalMonitor {
            NSEvent.removeMonitor(monitor)
            globalMonitor = nil
        }
    }

    private func handleMouseMove() {
        let screenPoint = NSEvent.mouseLocation
        cursorBehavior.update(cursorPosition: screenPoint)
    }
}
