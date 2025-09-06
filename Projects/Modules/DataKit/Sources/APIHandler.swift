import Foundation
import Alamofire
import Combine

public enum APIError: Error {
    case invalidURL
    case noData
    case decodingError(Error)
    case networkError(Error)
    case serverError(statusCode: Int)
    case unauthorized
    case unknown(Error)
}

public protocol APIHandlerProtocol {
    func request<T: Decodable & Sendable>(_ endpoint: APIEndpoint) async throws -> T
    func request<T: Decodable & Sendable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T
}

public actor APIHandler: APIHandlerProtocol {
    private let session: Session
    private let interceptor: APIInterceptor
    
    public init(interceptor: APIInterceptor = APIInterceptor()) {
        self.interceptor = interceptor
        self.session = Session(interceptor: interceptor)
    }
    
    public func request<T: Decodable & Sendable>(_ endpoint: APIEndpoint) async throws -> T {
        guard let url = URL(string: endpoint.baseURL + endpoint.path) else {
            throw APIError.invalidURL
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(
                url,
                method: endpoint.method.alamofireMethod,
                parameters: endpoint.parameters,
                encoding: endpoint.encoding,
                headers: HTTPHeaders(endpoint.headers ?? [:])
            )
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let decodedData = try JSONDecoder().decode(T.self, from: data)
                        continuation.resume(returning: decodedData)
                    } catch {
                        continuation.resume(throwing: APIError.decodingError(error))
                    }
                case .failure(let error):
                    let apiError = APIHandler.handleError(error, response: response.response)
                    continuation.resume(throwing: apiError)
                }
            }
        }
    }
    
    public func request<T: Decodable & Sendable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        return try await request(endpoint)
    }
    
    private static func handleError(_ error: AFError, response: HTTPURLResponse?) -> APIError {
        guard let statusCode = response?.statusCode else {
            return APIError.networkError(error)
        }
        
        switch statusCode {
        case 401:
            return APIError.unauthorized
        case 500...599:
            return APIError.serverError(statusCode: statusCode)
        default:
            return APIError.networkError(error)
        }
    }
}

public protocol APIEndpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: [String: Any]? { get }
    var headers: [String: String]? { get }
    var encoding: ParameterEncoding { get }
}

public extension APIEndpoint {
    var parameters: [String: Any]? { nil }
    var headers: [String: String]? { nil }
    var encoding: ParameterEncoding { JSONEncoding.default }
}

public enum HTTPMethod: String, CaseIterable {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
    
    var alamofireMethod: Alamofire.HTTPMethod {
        switch self {
        case .GET:
            return .get
        case .POST:
            return .post
        case .PUT:
            return .put
        case .DELETE:
            return .delete
        case .PATCH:
            return .patch
        }
    }
}
