import Foundation

struct PetConfig {
    // Sprite
    static let spriteSize: CGFloat = 32
    static let renderScale: CGFloat = 3
    static let renderSize: CGFloat = spriteSize * renderScale

    // Animation
    static let animationFPS: Double = 12
    static let frameDuration: TimeInterval = 1.0 / animationFPS

    // Movement
    static let walkSpeed: CGFloat = 40        // points per second
    static let climbSpeed: CGFloat = 30
    static let fallGravity: CGFloat = 600     // points per second^2
    static let bounceDecay: CGFloat = 0.4
    static let terminalVelocity: CGFloat = 500

    // State durations (seconds)
    static let idleMinDuration: TimeInterval = 2.0
    static let idleMaxDuration: TimeInterval = 6.0
    static let walkMinDuration: TimeInterval = 2.0
    static let walkMaxDuration: TimeInterval = 8.0
    static let sleepMinDuration: TimeInterval = 10.0
    static let sleepMaxDuration: TimeInterval = 30.0
    static let eatDuration: TimeInterval = 3.0
    static let climbMaxHeight: CGFloat = 200

    // Cursor interaction
    static let cursorNoticeRadius: CGFloat = 150
    static let cursorFleeRadius: CGFloat = 80
    static let cursorFollowSpeed: CGFloat = 60
    static let cursorFleeSpeed: CGFloat = 80

    // Energy / hunger
    static let maxEnergy: Double = 100
    static let maxHunger: Double = 100
    static let energyDecayRate: Double = 0.5    // per second
    static let hungerIncreaseRate: Double = 0.3 // per second
    static let sleepEnergyGain: Double = 2.0    // per second
    static let eatHungerReduction: Double = 30

    // Transition weights
    static let idleToWalkWeight: Double = 0.4
    static let idleToSleepWeight: Double = 0.15
    static let idleToEatWeight: Double = 0.1
    static let walkToIdleWeight: Double = 0.5
    static let walkToClimbWeight: Double = 0.3
}
