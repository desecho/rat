import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var petWindow: PetWindow!
    private var ratView: RatView!
    private var animationSystem: AnimationSystem!
    private var stateMachine: StateMachine!
    private var ratPet: RatPet!
    private var mouseTracker: MouseTracker!
    private var statusBarController: StatusBarController!
    private var animationController: AnimationController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let screen = NSScreen.main else { return }

        ratPet = RatPet()
        // Screen coordinates: bottom-center, above the Dock
        let visible = screen.visibleFrame
        ratPet.position = CGPoint(
            x: visible.midX,
            y: visible.minY
        )

        ratView = RatView(ratPet: ratPet)

        petWindow = PetWindow()
        petWindow.contentView = ratView
        petWindow.trackPosition(ratPet.position)

        animationController = AnimationController()
        ratView.animationController = animationController

        let screenBounds = ScreenBounds(screen: screen)

        stateMachine = StateMachine(ratPet: ratPet, screenBounds: screenBounds, animationController: animationController)

        mouseTracker = MouseTracker(ratPet: ratPet, stateMachine: stateMachine)

        animationSystem = AnimationSystem(
            ratPet: ratPet,
            ratView: ratView,
            stateMachine: stateMachine,
            animationController: animationController,
            petWindow: petWindow
        )

        statusBarController = StatusBarController(ratPet: ratPet, stateMachine: stateMachine, screenBounds: screenBounds)

        ratView.onMouseDown = { [weak self] event in
            self?.stateMachine.forceTransition(to: .dragged)
        }
        ratView.onMouseUp = { [weak self] event in
            self?.stateMachine.forceTransition(to: .falling)
        }
        ratView.onMouseDragged = { [weak self] event in
            guard let self = self else { return }
            // Convert to screen coordinates
            let screenPoint = NSEvent.mouseLocation
            self.ratPet.position = CGPoint(x: screenPoint.x, y: screenPoint.y - PetConfig.renderHeight / 2)
        }
        ratView.onRightMouseDown = { [weak self] event in
            guard let self = self else { return }
            let menu = ContextMenuBuilder.build(ratPet: self.ratPet, stateMachine: self.stateMachine, screenBounds: screenBounds)
            NSMenu.popUpContextMenu(menu, with: event, for: self.ratView)
        }

        petWindow.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)

        animationSystem.start()
        mouseTracker.start()
    }

    func applicationWillTerminate(_ notification: Notification) {
        animationSystem?.stop()
        mouseTracker?.stop()
    }
}
