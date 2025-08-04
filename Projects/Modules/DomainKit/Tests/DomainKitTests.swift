import XCTest
@testable import DomainKit

final class DomainKitTests: XCTestCase {
    
    func testDomainKitModule() {
        // DomainKit 모듈 테스트
        XCTAssertNotNil(DomainKitModule.shared)
    }
}
