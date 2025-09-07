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

public protocol APIHandlerProtocol: Sendable {
    func request<T: Decodable & Sendable>(_ endpoint: APIEndpoint) async throws -> T
    func request<T: Decodable & Sendable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T
}

public actor APIHandler: APIHandlerProtocol {
    private let session: Session
    private let interceptor: APIInterceptor
    private let logger: APILoggerProtocol
    
    public init(interceptor: APIInterceptor = APIInterceptor(), logger: APILoggerProtocol = APILogger.shared) {
        self.interceptor = interceptor
        self.logger = logger
        self.session = Session(interceptor: interceptor)
    }
    
    public func request<T: Decodable & Sendable>(_ endpoint: APIEndpoint) async throws -> T {
        let fullURL = try buildFullURL(for: endpoint)
        let timer = APITimer()
        
        return try await withCheckedThrowingContinuation { continuation in
            let urlRequest = createURLRequest(url: fullURL, endpoint: endpoint)
            
            logger.logRequest(urlRequest, endpoint: endpoint)
            
            let parameters = getRequestParameters(for: endpoint)
            let encoding = getParameterEncoding(for: endpoint)
            
            session.request(
                fullURL,
                method: endpoint.method.alamofireMethod,
                parameters: parameters,
                encoding: encoding,
                headers: HTTPHeaders(endpoint.headers ?? [:])
            )
            .validate()
            .responseData { [weak self] response in
                let duration = timer.duration
                switch response.result {
                case .success(let data):
                    self?.logger.logResponse(response.response, data: data, error: nil, duration: duration)
                    do {
                        let decodedData = try JSONDecoder().decode(T.self, from: data)
                        continuation.resume(returning: decodedData)
                    } catch {
                        let decodingError = APIError.decodingError(error)
                        self?.logger.logResponse(response.response, data: data, error: decodingError, duration: duration)
                        continuation.resume(throwing: decodingError)
                    }
                case .failure(let error):
                    let apiError = APIHandler.handleError(error, response: response.response)
                    self?.logger.logResponse(response.response, data: response.data, error: apiError, duration: duration)
                    continuation.resume(throwing: apiError)
                }
            }
        }
    }
    
    private func buildFullURL(for endpoint: APIEndpoint) throws -> URL {
        var urlComponents = URLComponents(string: endpoint.baseURL + endpoint.path)
        
        if let queryParameters = endpoint.queryParameters, !queryParameters.isEmpty {
            urlComponents?.queryItems = queryParameters.map { key, value in
                URLQueryItem(name: key, value: "\(value)")
            }
        }
        
        guard let url = urlComponents?.url else {
            throw APIError.invalidURL
        }
        
        return url
    }
    
    private func getRequestParameters(for endpoint: APIEndpoint) -> [String: Any]? {
        return endpoint.bodyParameters
    }
    
    private func getParameterEncoding(for endpoint: APIEndpoint) -> ParameterEncoding {
        switch endpoint.method {
        case .GET, .DELETE:
            return URLEncoding.default
        case .POST, .PUT, .PATCH:
            return JSONEncoding.default
        }
    }
    
    private func createURLRequest(url: URL, endpoint: APIEndpoint) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        if let headers = endpoint.headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let bodyParameters = endpoint.bodyParameters,
           !bodyParameters.isEmpty,
           let httpBody = try? JSONSerialization.data(withJSONObject: bodyParameters) {
            request.httpBody = httpBody
        }
        
        return request
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
    var queryParameters: [String: Any]? { get }
    var bodyParameters: [String: Any]? { get }
    var headers: [String: String]? { get }
    var encoding: ParameterEncoding { get }
}

public extension APIEndpoint {
    var parameters: [String: Any]? { nil }
    var queryParameters: [String: Any]? { nil }
    var bodyParameters: [String: Any]? { nil }
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
