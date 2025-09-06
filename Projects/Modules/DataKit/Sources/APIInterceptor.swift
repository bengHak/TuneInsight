import Foundation
import Alamofire

public protocol APIInterceptorProtocol {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void)
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void)
}

public final class APIInterceptor: RequestInterceptor, APIInterceptorProtocol, Sendable {
    
    public init() {}
    
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var adaptedRequest = urlRequest
        
        adaptedRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        adaptedRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        completion(.success(adaptedRequest))
    }
    
    public func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        switch response.statusCode {
        case 401:
            print("[APIInterceptor] 401 Unauthorized error occurred - Authentication failed")
            completion(.doNotRetry)
        case 500...599:
            if request.retryCount < 2 {
                completion(.retryWithDelay(1.0))
            } else {
                completion(.doNotRetryWithError(error))
            }
        default:
            completion(.doNotRetryWithError(error))
        }
    }
}