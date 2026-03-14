import AppKit

class StatusBarController {
    private var statusItem: NSStatusItem
    private let ratPet: RatPet
    private let stateMachine: StateMachine
    private let screenBounds: ScreenBounds

    init(ratPet: RatPet, stateMachine: StateMachine, screenBounds: ScreenBounds) {
        self.ratPet = ratPet
        self.stateMachine = stateMachine
        self.screenBounds = screenBounds

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.title = "R"
            button.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .bold)
        }

        setupMenu()
    }

    private func setupMenu() {
        let menu = NSMenu()

        let feedItem = NSMenuItem(title: "Feed", action: #selector(feedRat), keyEquivalent: "f")
        feedItem.target = self
        menu.addItem(feedItem)

        let sleepItem = NSMenuItem(title: "Sleep / Wake", action: #selector(toggleSleep), keyEquivalent: "s")
        sleepItem.target = self
        menu.addItem(sleepItem)

        let climbItem = NSMenuItem(title: "Climb", action: #selector(climbWall), keyEquivalent: "c")
        climbItem.target = self
        menu.addItem(climbItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    @objc private func feedRat() {
        stateMachine.forceTransition(to: .eating)
    }

    @objc private func toggleSleep() {
        if stateMachine.currentStateID == .sleeping {
            stateMachine.forceTransition(to: .idle)
        } else {
            stateMachine.forceTransition(to: .sleeping)
        }
    }

    @objc private func climbWall() {
        let distToLeft = ratPet.position.x - screenBounds.minX
        let distToRight = screenBounds.maxX - ratPet.position.x
        ratPet.climbingSide = distToLeft <= distToRight ? .left : .right
        stateMachine.forceTransition(to: .climbing)
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
