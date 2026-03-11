import AppKit
import QuartzCore

class AnimationSystem {
    private let ratPet: RatPet
    private let ratView: RatView
    private let stateMachine: StateMachine
    private let animationController: AnimationController
    private let petWindow: PetWindow
    private var timer: Timer?
    private var lastTimestamp: TimeInterval = 0

    init(ratPet: RatPet, ratView: RatView, stateMachine: StateMachine, animationController: AnimationController, petWindow: PetWindow) {
        self.ratPet = ratPet
        self.ratView = ratView
        self.stateMachine = stateMachine
        self.animationController = animationController
        self.petWindow = petWindow
    }

    func start() {
        lastTimestamp = CACurrentMediaTime()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        let now = CACurrentMediaTime()
        let dt = min(now - lastTimestamp, 1.0 / 30.0)
        lastTimestamp = now

        stateMachine.update(dt: dt)
        animationController.update(dt: dt)
        ratPet.updateNeeds(dt: dt)

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        ratView.updateSprite()
        petWindow.trackPosition(ratPet.position, isClimbing: ratPet.isClimbing)
        CATransaction.commit()
    }
}
