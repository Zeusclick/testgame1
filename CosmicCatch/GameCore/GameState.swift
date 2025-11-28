import Foundation

struct GameState {
    private(set) var score: Int = 0
    private(set) var lives: Int = 3
    private(set) var level: Int = 1
    private(set) var combo: Int = 0

    mutating func reset() {
        score = 0
        lives = 3
        level = 1
        combo = 0
    }

    mutating func applyCatch(points: Int) {
        let comboBonus = max(combo, 1)
        score += points * comboBonus
        combo += 1

        if score > 0 && score % 200 == 0 {
            level += 1
        }
    }

    mutating func registerMiss() {
        lives = max(lives - 1, 0)
        combo = 0
    }
}
