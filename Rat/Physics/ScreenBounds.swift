import AppKit

class ScreenBounds {
    let minX: CGFloat
    let maxX: CGFloat
    let minY: CGFloat
    let maxY: CGFloat
    let groundY: CGFloat

    init(screen: NSScreen) {
        let visible = screen.visibleFrame
        self.minX = visible.minX
        self.maxX = visible.maxX
        self.minY = visible.minY
        self.maxY = visible.maxY
        self.groundY = visible.minY - 5  // snug against the Dock
    }
}
