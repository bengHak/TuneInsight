import Foundation
import Alamofire
import FoundationKit

public protocol APIInterceptorProtocol {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void)
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void)
}

public final class APIInterceptor: RequestInterceptor, APIInterceptorProtocol, Sendable {
    private let logger: APILoggerProtocol
    private let tokenStorage: TokenStorageProtocol
    private let authAPI: SpotifyAuthAPIProtocol
    
    public init(
        logger: APILoggerProtocol = APILogger.shared,
        tokenStorage: TokenStorageProtocol = TokenStorage.shared,
        authAPI: SpotifyAuthAPIProtocol = SpotifyAuthAPI()
    ) {
        self.logger = logger
        self.tokenStorage = tokenStorage
        self.authAPI = authAPI
    }
    
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var adaptedRequest = urlRequest
        adaptedRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        adaptedRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        // Spotify API 호출에 대해서는 최신 액세스 토큰을 반영하도록 시도
        if let host = adaptedRequest.url?.host, host.contains("api.spotify.com") {
            Task { [weak self] in
                guard let self = self else { return }
                do {
                    // 토큰 만료 시 선제적으로 리프레시 시도
                    if let token = try? self.tokenStorage.loadToken(), token.isExpired {
                        let newToken = try await self.authAPI.refreshAccessToken()
                        try self.tokenStorage.saveToken(newToken)
                    }
                    if let accessToken = try? self.tokenStorage.getCurrentAccessToken() {
                        adaptedRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                    }
                    self.logger.logRequest(adaptedRequest, endpoint: nil)
                    completion(.success(adaptedRequest))
                } catch {
                    // 리프레시 실패 시 기존 요청 그대로 진행 (서버에서 401 응답 시 retry에서 처리)
                    self.logger.logRequest(adaptedRequest, endpoint: nil)
                    completion(.success(adaptedRequest))
                }
            }
            return
        }

        logger.logRequest(adaptedRequest, endpoint: nil)
        completion(.success(adaptedRequest))
    }
    
    public func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        switch response.statusCode {
        case 401:
            // 401인 경우 토큰 리프레시를 시도하고, 성공 시 재시도
            Task { [weak self] in
                guard let self else { return }
                do {
                    let newToken = try await self.authAPI.refreshAccessToken()
                    try self.tokenStorage.saveToken(newToken)
                    self.logger.logRetry(request, attempt: request.retryCount + 1, error: error)
                    completion(.retry)
                } catch {
                    // 리프레시 실패 시 재시도하지 않음
                    completion(.doNotRetryWithError(error))
                }
            }
        case 500...599:
            if request.retryCount < 2 {
                logger.logRetry(request, attempt: request.retryCount + 1, error: error)
                completion(.retryWithDelay(1.0))
            } else {
                completion(.doNotRetryWithError(error))
            }
        default:
            completion(.doNotRetryWithError(error))
        }
    }
}
