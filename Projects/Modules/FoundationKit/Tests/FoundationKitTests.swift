import XCTest
@testable import FoundationKit

final class FoundationKitTests: XCTestCase {
    
    func testFoundationKitModule() {
        // FoundationKit 모듈 테스트
        XCTAssertNotNil(FoundationKitModule.shared)
    }
}
