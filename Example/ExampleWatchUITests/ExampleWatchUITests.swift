import XCTest

final class ExampleWatchUITests: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  @MainActor
  func testAppLaunches() {
    let app = XCUIApplication()
    app.launch()

    XCTAssertTrue(app.wait(for: .runningForeground, timeout: 15))
  }
}
