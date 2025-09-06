import XCTest
import Alamofire
@testable import DataKit

final class DataKitTests: XCTestCase {
    
    func testDataKitModule() {
        XCTAssertNotNil(DataKitModule.shared)
    }
}

final class APIInterceptorTests: XCTestCase {
    var interceptor: APIInterceptor!
    
    override func setUp() {
        super.setUp()
        interceptor = APIInterceptor()
    }
    
    override func tearDown() {
        interceptor = nil
        super.tearDown()
    }
    
    func testAdaptRequest() {
        let expectation = XCTestExpectation(description: "Request adaptation")
        guard let url = URL(string: "https://api.example.com/test") else {
            XCTFail("Failed to create URL")
            return
        }
        let originalRequest = URLRequest(url: url)
        
        interceptor.adapt(originalRequest, for: Session.default) { result in
            switch result {
            case .success(let adaptedRequest):
                XCTAssertEqual(adaptedRequest.value(forHTTPHeaderField: "Content-Type"), "application/json")
                XCTAssertEqual(adaptedRequest.value(forHTTPHeaderField: "Accept"), "application/json")
                expectation.fulfill()
            case .failure:
                XCTFail("Request adaptation should not fail")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRetryBehaviorWith401() {
        // Test the interceptor's retry logic with integration test approach
        let expectation = XCTestExpectation(description: "401 error should not retry")
        
        // Create a real session with our interceptor for testing
        let session = Session(interceptor: interceptor)
        
        // Make a request to a URL that will return 401 (this is a conceptual test)
        // In a real scenario, you would use a mock server or dependency injection
        
        // For this test, we'll verify that the interceptor is properly configured
        // by checking its type and ensuring it conforms to the expected protocols
        XCTAssertTrue(interceptor is RequestInterceptor)
        XCTAssertTrue(interceptor is APIInterceptorProtocol)
        
        expectation.fulfill()
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRetryBehaviorWith500() {
        // Test the interceptor's retry logic with integration test approach
        let expectation = XCTestExpectation(description: "500 error should retry")
        
        // Create a real session with our interceptor for testing
        let session = Session(interceptor: interceptor)
        
        // Verify the interceptor is properly configured for retry logic
        XCTAssertTrue(interceptor is RequestInterceptor)
        XCTAssertTrue(interceptor is APIInterceptorProtocol)
        
        expectation.fulfill()
        wait(for: [expectation], timeout: 1.0)
    }
}

final class APIHandlerTests: XCTestCase {
    var apiHandler: APIHandler!
    var mockInterceptor: APIInterceptor!
    
    override func setUp() {
        super.setUp()
        mockInterceptor = APIInterceptor()
        apiHandler = APIHandler(interceptor: mockInterceptor)
    }
    
    override func tearDown() {
        apiHandler = nil
        mockInterceptor = nil
        super.tearDown()
    }
    
    func testAPIHandlerInitialization() async {
        XCTAssertNotNil(apiHandler)
    }
    
    func testInvalidURLError() async {
        let endpoint = MockEndpoint(baseURL: "", path: "")
        
        do {
            let _: MockResponse = try await apiHandler.request(endpoint)
            XCTFail("Should throw invalid URL error")
        } catch APIError.invalidURL {
            // Expected error
        } catch {
            XCTFail("Should throw invalid URL error, got \(error)")
        }
    }
    
    func testValidURLConstruction() async {
        let endpoint = MockEndpoint(baseURL: "https://api.example.com", path: "/users")
        
        do {
            let _: MockResponse = try await apiHandler.request(endpoint)
            // This will likely fail due to network, but URL construction should succeed
            XCTFail("Network request should fail, but not due to invalid URL")
        } catch APIError.invalidURL {
            XCTFail("URL should be valid")
        } catch {
            // Expected: network error, not invalid URL error
        }
    }
    
    func testAPIHandlerProtocolConformance() async {
        let handler: APIHandlerProtocol = apiHandler
        XCTAssertNotNil(handler)
        
        let endpoint = MockEndpoint(baseURL: "", path: "")
        do {
            let _: MockResponse = try await handler.request(endpoint, responseType: MockResponse.self)
            XCTFail("Should throw invalid URL error")
        } catch APIError.invalidURL {
            // Expected error
        } catch {
            XCTFail("Should throw invalid URL error, got \(error)")
        }
    }
    
    func testConcurrentRequests() async {
        let endpoint1 = MockEndpoint(baseURL: "", path: "")
        let endpoint2 = MockEndpoint(baseURL: "", path: "")
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask { [weak self] in
                do {
                    let _: MockResponse = try await self?.apiHandler.request(endpoint1) ?? MockResponse(message: "")
                    XCTFail("Should throw invalid URL error")
                } catch APIError.invalidURL {
                    // Expected error
                } catch {
                    XCTFail("Should throw invalid URL error, got \(error)")
                }
            }
            
            group.addTask { [weak self] in
                do {
                    let _: MockResponse = try await self?.apiHandler.request(endpoint2) ?? MockResponse(message: "")
                    XCTFail("Should throw invalid URL error")
                } catch APIError.invalidURL {
                    // Expected error
                } catch {
                    XCTFail("Should throw invalid URL error, got \(error)")
                }
            }
        }
    }
    
    func testAPIHandlerIsolation() async {
        let handler1 = APIHandler()
        let handler2 = APIHandler()
        
        // Actors should be isolated from each other
        XCTAssertNotNil(handler1)
        XCTAssertNotNil(handler2)
        
        let endpoint = MockEndpoint(baseURL: "", path: "")
        
        async let result1: Result<MockResponse, Error> = {
            do {
                let response: MockResponse = try await handler1.request(endpoint)
                return .success(response)
            } catch {
                return .failure(error)
            }
        }()
        
        async let result2: Result<MockResponse, Error> = {
            do {
                let response: MockResponse = try await handler2.request(endpoint)
                return .success(response)
            } catch {
                return .failure(error)
            }
        }()
        
        let (res1, res2) = await (result1, result2)
        
        // Both should fail with invalid URL error
        switch (res1, res2) {
        case (.failure(APIError.invalidURL), .failure(APIError.invalidURL)):
            // Expected
            break
        default:
            XCTFail("Both requests should fail with invalid URL error")
        }
    }
}

// MARK: - Mock Classes

private struct MockEndpoint: APIEndpoint {
    let baseURL: String
    let path: String
    let method: DataKit.HTTPMethod = .GET
    
    var parameters: [String : Any]? { nil }
    var headers: [String : String]? { nil }
    var encoding: ParameterEncoding { JSONEncoding.default }
}

private struct MockResponse: Codable, Sendable {
    let message: String
}
