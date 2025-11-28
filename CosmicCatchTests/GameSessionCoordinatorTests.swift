import XCTest
@testable import CosmicCatch

final class GameSessionCoordinatorTests: XCTestCase {
    func testStartAndPauseFlow() {
        let coordinator = GameSessionCoordinator(services: .makeDefault())
        coordinator.start(challenge: .standard, sector: .coreNebula)
        XCTAssertTrue(coordinator.isGameRunning)
        coordinator.pause()
        XCTAssertTrue(coordinator.isPaused)
        coordinator.resume()
        XCTAssertFalse(coordinator.isPaused)
    }
}
