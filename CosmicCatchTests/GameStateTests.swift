import XCTest
@testable import CosmicCatch

final class GameStateTests: XCTestCase {
    func testComboIncreasesScore() {
        var state = GameState()
        let scoring = DefaultScoringService()
        let shard = CollectibleDefinition.defaultCatalog.first!
        let first = state.applyCatch(points: shard.baseValue, definition: shard, scoring: scoring)
        let second = state.applyCatch(points: shard.baseValue, definition: shard, scoring: scoring)
        XCTAssertGreaterThan(second, first)
        XCTAssertEqual(state.combo, 2)
    }

    func testHazardRemovesLife() {
        var state = GameState()
        state.registerHazard(.removeLife)
        XCTAssertEqual(state.lives, 2)
    }
}
