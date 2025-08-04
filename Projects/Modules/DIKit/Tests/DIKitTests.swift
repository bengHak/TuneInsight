import XCTest
@testable import DIKit

final class DIKitTests: XCTestCase {
    
    func testDIKitModule() {
        // DIKit 모듈 테스트
        XCTAssertNotNil(DIKitModule.shared)
    }
}
