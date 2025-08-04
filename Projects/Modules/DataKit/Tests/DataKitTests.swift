import XCTest
@testable import DataKit

final class DataKitTests: XCTestCase {
    
    func testDataKitModule() {
        // DataKit 모듈 테스트
        XCTAssertNotNil(DataKitModule.shared)
    }
}
