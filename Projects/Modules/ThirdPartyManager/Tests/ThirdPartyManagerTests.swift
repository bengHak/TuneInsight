import XCTest
@testable import ThirdPartyManager

final class ThirdPartyManagerTests: XCTestCase {
    
    func testThirdPartyManagerModule() {
        // ThirdPartyManager 모듈 테스트
        XCTAssertNotNil(ThirdPartyManagerModule.shared)
    }
}
