import XCTest
@testable import PresentationKit

final class PresentationKitTests: XCTestCase {
    
    func testPresentationKitModule() {
        // PresentationKit 모듈 테스트
        XCTAssertNotNil(PresentationKitModule.shared)
    }
}
