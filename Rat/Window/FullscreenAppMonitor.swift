import AppKit
import CoreGraphics

@_silgen_name("CGSMainConnectionID")
private func CGSMainConnectionID() -> Int

@_silgen_name("CGSCopyManagedDisplaySpaces")
private func CGSCopyManagedDisplaySpaces(_ connection: Int) -> CFArray

class FullscreenAppMonitor {
    private let ownProcessIdentifier: pid_t
    private let onVisibilityChange: (Bool) -> Void
    private var timer: Timer?
    private var isRatVisible = true

    init(ownProcessIdentifier: pid_t, onVisibilityChange: @escaping (Bool) -> Void) {
        self.ownProcessIdentifier = ownProcessIdentifier
        self.onVisibilityChange = onVisibilityChange
    }

    func start() {
        let workspace = NSWorkspace.shared.notificationCenter
        workspace.addObserver(
            self,
            selector: #selector(workspaceStateChanged),
            name: NSWorkspace.didActivateApplicationNotification,
            object: nil
        )
        workspace.addObserver(
            self,
            selector: #selector(activeSpaceChanged),
            name: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil
        )

        timer = Timer(timeInterval: 0.25, repeats: true) { [weak self] _ in
            self?.updateVisibility()
        }
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
        updateVisibility()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }

    @objc private func workspaceStateChanged(_ notification: Notification) {
        updateVisibility(forceNotifyWhenVisible: false)
    }

    @objc private func activeSpaceChanged(_ notification: Notification) {
        updateVisibility(forceNotifyWhenVisible: true)
    }

    private func updateVisibility(forceNotifyWhenVisible: Bool = false) {
        let shouldShowRat = !isFullscreenAppVisible()
        guard shouldShowRat != isRatVisible || shouldShowRat && forceNotifyWhenVisible else { return }

        isRatVisible = shouldShowRat
        onVisibilityChange(shouldShowRat)
    }

    private func isFullscreenAppVisible() -> Bool {
        if isCurrentSpaceFullscreen() {
            return true
        }

        return isFullscreenWindowVisible()
    }

    private func isCurrentSpaceFullscreen() -> Bool {
        let displaySpaces = CGSCopyManagedDisplaySpaces(CGSMainConnectionID()) as NSArray
        return displaySpaces.contains { display in
            guard
                let display = display as? NSDictionary,
                let currentSpace = display["Current Space"] as? NSDictionary,
                let type = currentSpace["type"] as? NSNumber
            else {
                return false
            }

            return type.intValue != 0
        }
    }

    private func isFullscreenWindowVisible() -> Bool {
        guard let frontmostProcessIdentifier = NSWorkspace.shared.frontmostApplication?.processIdentifier,
              frontmostProcessIdentifier != ownProcessIdentifier else {
            return false
        }

        let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
        guard let windowInfo = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
            return false
        }

        return windowInfo.contains { info in
            guard
                let ownerPID = info[kCGWindowOwnerPID as String] as? NSNumber,
                ownerPID.int32Value == frontmostProcessIdentifier,
                let layer = info[kCGWindowLayer as String] as? NSNumber,
                layer.intValue >= 0,
                let boundsDictionary = info[kCGWindowBounds as String] as? NSDictionary,
                let bounds = CGRect(dictionaryRepresentation: boundsDictionary)
            else {
                return false
            }

            if let isOnscreen = info[kCGWindowIsOnscreen as String] as? NSNumber,
               !isOnscreen.boolValue {
                return false
            }

            if let alpha = info[kCGWindowAlpha as String] as? NSNumber,
               alpha.doubleValue <= 0 {
                return false
            }

            return isFullscreenBounds(bounds)
        }
    }

    private func isFullscreenBounds(_ bounds: CGRect) -> Bool {
        NSScreen.screens.contains { screen in
            let screenFrame = screen.frame
            return size(bounds.size, matches: screenFrame.size, tolerance: 2)
                || size(
                    bounds.size,
                    matches: CGSize(
                        width: screenFrame.width * screen.backingScaleFactor,
                        height: screenFrame.height * screen.backingScaleFactor
                    ),
                    tolerance: 4
                )
        }
    }

    private func size(_ first: CGSize, matches second: CGSize, tolerance: CGFloat) -> Bool {
        abs(first.width - second.width) <= tolerance
            && abs(first.height - second.height) <= tolerance
    }
}
