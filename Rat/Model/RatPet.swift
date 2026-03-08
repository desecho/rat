import Foundation

enum ClimbSide {
    case left, right
}

class RatPet {
    var position: CGPoint = .zero
    var velocity: CGPoint = .zero
    var facingLeft: Bool = false
    var isClimbing: Bool = false
    var climbingSide: ClimbSide = .left

    var energy: Double = PetConfig.maxEnergy
    var hunger: Double = 0

    func updateNeeds(dt: TimeInterval) {
        energy = max(0, energy - PetConfig.energyDecayRate * dt)
        hunger = min(PetConfig.maxHunger, hunger + PetConfig.hungerIncreaseRate * dt)
    }

    func feed() {
        hunger = max(0, hunger - PetConfig.eatHungerReduction)
    }

    func rest(dt: TimeInterval) {
        energy = min(PetConfig.maxEnergy, energy + PetConfig.sleepEnergyGain * dt)
    }

    var isTired: Bool { energy < 20 }
    var isHungry: Bool { hunger > 70 }
}
