import AppKit

class ContextMenuBuilder {
    static func build(ratPet: RatPet, stateMachine: StateMachine) -> NSMenu {
        let menu = NSMenu()

        let feedItem = NSMenuItem(title: "Feed", action: #selector(MenuActions.feed), keyEquivalent: "")
        feedItem.target = MenuActions.shared
        MenuActions.shared.stateMachine = stateMachine
        menu.addItem(feedItem)

        let sleepTitle = stateMachine.currentStateID == .sleeping ? "Wake Up" : "Sleep"
        let sleepItem = NSMenuItem(title: sleepTitle, action: #selector(MenuActions.toggleSleep), keyEquivalent: "")
        sleepItem.target = MenuActions.shared
        menu.addItem(sleepItem)

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
}
