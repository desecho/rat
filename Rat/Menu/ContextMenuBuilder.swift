import AppKit

class ContextMenuBuilder {
    static func build(ratPet: RatPet, stateMachine: StateMachine, screenBounds: ScreenBounds) -> NSMenu {
        let menu = NSMenu()

        let feedItem = NSMenuItem(title: "Feed", action: #selector(MenuActions.feed), keyEquivalent: "")
        feedItem.target = MenuActions.shared
        MenuActions.shared.stateMachine = stateMachine
        MenuActions.shared.ratPet = ratPet
        MenuActions.shared.screenBounds = screenBounds
        menu.addItem(feedItem)

        let sleepTitle = stateMachine.currentStateID == .sleeping ? "Wake Up" : "Sleep"
        let sleepItem = NSMenuItem(title: sleepTitle, action: #selector(MenuActions.toggleSleep), keyEquivalent: "")
        sleepItem.target = MenuActions.shared
        menu.addItem(sleepItem)

        let climbItem = NSMenuItem(title: "Climb", action: #selector(MenuActions.climb), keyEquivalent: "")
        climbItem.target = MenuActions.shared
        menu.addItem(climbItem)

        menu.addItem(NSMenuItem.separator())

        let statusItem = NSMenuItem(title: "Energy: \(Int(ratPet.energy))% | Hunger: \(Int(ratPet.hunger))%", action: nil, keyEquivalent: "")
        statusItem.isEnabled = false
        menu.addItem(statusItem)

        return menu
    }
}

class MenuActions: NSObject {
    static let shared = MenuActions()
    var stateMachine: StateMachine?
    var ratPet: RatPet?
    var screenBounds: ScreenBounds?

    @objc func feed() {
        stateMachine?.forceTransition(to: .eating)
    }

    @objc func toggleSleep() {
        guard let sm = stateMachine else { return }
        if sm.currentStateID == .sleeping {
            sm.forceTransition(to: .idle)
        } else {
            sm.forceTransition(to: .sleeping)
        }
    }

    @objc func climb() {
        guard let ratPet = ratPet, let screenBounds = screenBounds else { return }
        let distToLeft = ratPet.position.x - screenBounds.minX
        let distToRight = screenBounds.maxX - ratPet.position.x
        ratPet.climbingSide = distToLeft <= distToRight ? .left : .right
        stateMachine?.forceTransition(to: .climbing)
    }
}
