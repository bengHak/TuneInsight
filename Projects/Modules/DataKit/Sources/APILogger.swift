import Foundation
import Alamofire
import os.log

public enum APILogLevel: Int, CaseIterable, Sendable {
    case none = 0
    case basic = 1
    case headers = 2
    case body = 3
    case verbose = 4
}

public protocol APILoggerProtocol: Sendable {
    var logLevel: APILogLevel { get }
    func logRequest(_ request: URLRequest, endpoint: APIEndpoint?)
    func logResponse(_ response: HTTPURLResponse?, data: Data?, error: Error?, duration: TimeInterval)
    func logRetry(_ request: Request, attempt: Int, error: Error)
}

public final class APILogger: APILoggerProtocol, Sendable {
    public static let shared = APILogger()
    
    private let subsystem = "com.sparkish.SpotifyStats.API"
    
    // 카테고리별 Logger
    private let requestLogger: Logger
    private let responseLogger: Logger
    private let errorLogger: Logger
    private let retryLogger: Logger
    private let debugLogger: Logger
    
    public let logLevel: APILogLevel
    
    private init() {
        requestLogger = Logger(subsystem: subsystem, category: "api.request")
        responseLogger = Logger(subsystem: subsystem, category: "api.response")
        errorLogger = Logger(subsystem: subsystem, category: "api.error")
        retryLogger = Logger(subsystem: subsystem, category: "api.retry")
        debugLogger = Logger(subsystem: subsystem, category: "api.debug")
        
        #if DEBUG
        logLevel = .verbose
        #else
        logLevel = .none
        #endif
    }
    
    // MARK: - Request Logging
    
    public func logRequest(_ request: URLRequest, endpoint: APIEndpoint? = nil) {
        guard logLevel != .none else { return }
        
        let method = request.httpMethod ?? "UNKNOWN"
        let url = request.url?.absoluteString ?? "Unknown URL"
        
        requestLogger.debug("🚀 \(method) \(url)")
        
        if logLevel.rawValue >= APILogLevel.headers.rawValue {
            logRequestHeaders(request.allHTTPHeaderFields)
        }
        
        if logLevel.rawValue >= APILogLevel.body.rawValue {
            logRequestBody(request.httpBody)
            
            if let endpoint = endpoint {
                logEndpointParameters(endpoint)
            }
        }
        
        if logLevel == .verbose {
            logRequestDetails(request)
        }
    }
    
    private func logRequestHeaders(_ headers: [String: String]?) {
        guard let headers = headers, !headers.isEmpty else { return }
        
        requestLogger.debug("📋 Headers:")
        for (key, value) in headers.sorted(by: { $0.key < $1.key }) {
            if isSensitiveKey(key) {
                requestLogger.debug("   \(key): [REDACTED]")
            } else {
                requestLogger.debug("   \(key): \(value)")
            }
        }
    }
    
    private func logRequestBody(_ body: Data?) {
        guard let body = body, !body.isEmpty else { return }
        
        let sizeString = ByteCountFormatter.string(fromByteCount: Int64(body.count), countStyle: .binary)
        requestLogger.debug("📦 Body (\(sizeString)):")
        
        if let jsonString = formatJSON(from: body) {
            requestLogger.debug("Body JSON: \(jsonString)")
        } else if let string = String(data: body, encoding: .utf8) {
            requestLogger.debug("Body Text: \(string)")
        } else {
            requestLogger.debug("Body: Binary data (\(body.count) bytes)")
        }
    }
    
    private func logEndpointParameters(_ endpoint: APIEndpoint) {
        if let queryParams = endpoint.queryParameters, !queryParams.isEmpty {
            debugLogger.debug("🔗 Query Parameters:")
            for (key, value) in queryParams {
                debugLogger.debug("   \(key, privacy: .public): \(String(describing: value), privacy: .public)")
            }
        }
        
        if let bodyParams = endpoint.bodyParameters, !bodyParams.isEmpty {
            debugLogger.debug("📦 Body Parameters:")
            for (key, value) in bodyParams {
                debugLogger.debug("   \(key, privacy: .public): \(String(describing: value), privacy: .private)")
            }
        }
    }
    
    private func logRequestDetails(_ request: URLRequest) {
        if let cachePolicy = request.cachePolicy.description {
            debugLogger.debug("💾 Cache Policy: \(cachePolicy, privacy: .public)")
        }
        debugLogger.debug("⏱️ Timeout: \(request.timeoutInterval, privacy: .public)s")
    }
    
    // MARK: - Response Logging
    
    public func logResponse(_ response: HTTPURLResponse?, data: Data?, error: Error?, duration: TimeInterval) {
        guard logLevel != .none else { return }
        
        guard let response = response else {
            errorLogger.error("❓ API RESPONSE (No Response)")
            if let error = error {
                errorLogger.error("❌ Error: \(error.localizedDescription, privacy: .public)")
            }
            return
        }
        
        let statusCode = response.statusCode
        let url = response.url?.absoluteString ?? "Unknown URL"
        let durationString = String(format: "%.3fs", duration)
        let statusEmoji = getStatusEmoji(statusCode)
        let statusMessage = HTTPURLResponse.localizedString(forStatusCode: statusCode)
        
        if statusCode >= 400 {
            responseLogger.error("\(statusEmoji, privacy: .public) \(statusCode, privacy: .public) \(statusMessage, privacy: .public) (\(durationString, privacy: .public))")
            responseLogger.error("   \(url, privacy: .public)")
        } else {
            responseLogger.info("\(url, privacy: .public) \n\(statusEmoji, privacy: .public) \(statusCode, privacy: .public) \(statusMessage, privacy: .public) (\(durationString, privacy: .public))")
        }
        
        if let error = error {
            errorLogger.error("❌ Error: \(error.localizedDescription, privacy: .public)")
        }
        
        if logLevel.rawValue >= APILogLevel.headers.rawValue {
            logResponseHeaders(response.allHeaderFields)
        }
        
        if logLevel.rawValue >= APILogLevel.body.rawValue {
            logResponseBody(data)
        }
        
        if logLevel == .verbose {
            logResponseDetails(response)
        }
    }
    
    private func logResponseHeaders(_ headers: [AnyHashable: Any]) {
        guard !headers.isEmpty else { return }
        
        responseLogger.debug("📋 Response Headers:")
        let sortedHeaders = headers.sorted { String(describing: $0.key) < String(describing: $1.key) }
        
        for (key, value) in sortedHeaders {
            let keyString = String(describing: key)
            let valueString = String(describing: value)
            
            if isSensitiveKey(keyString) {
                responseLogger.debug("   \(keyString, privacy: .public): \(valueString, privacy: .private)")
            } else {
                responseLogger.debug("   \(keyString, privacy: .public): \(valueString, privacy: .public)")
            }
        }
    }
    
    private func logResponseBody(_ data: Data?) {
        guard let data = data, !data.isEmpty else {
            responseLogger.debug("📦 Response Body: <Empty>")
            return
        }
        
        let sizeString = ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .binary)
        responseLogger.debug("📦 Response Body (\(sizeString, privacy: .public)):")
        
        if let jsonString = formatJSON(from: data) {
            responseLogger.debug("Response JSON: \(jsonString, privacy: .private)")
        } else if let string = String(data: data, encoding: .utf8) {
            responseLogger.debug("Response Text: \(string, privacy: .private)")
        } else {
            responseLogger.debug("Response: Binary data (\(data.count, privacy: .public) bytes)")
        }
    }
    
    private func logResponseDetails(_ response: HTTPURLResponse) {
        if let mimeType = response.mimeType {
            debugLogger.debug("📄 MIME Type: \(mimeType, privacy: .public)")
        }
        if let encoding = response.textEncodingName {
            debugLogger.debug("🔤 Encoding: \(encoding, privacy: .public)")
        }
        if response.expectedContentLength != -1 {
            let size = ByteCountFormatter.string(fromByteCount: response.expectedContentLength, countStyle: .binary)
            debugLogger.debug("📊 Expected Size: \(size, privacy: .public)")
        }
    }
    
    // MARK: - Retry Logging
    
    public func logRetry(_ request: Request, attempt: Int, error: Error) {
        guard logLevel.rawValue >= APILogLevel.basic.rawValue else { return }
        
        let url = request.request?.url?.absoluteString ?? "Unknown URL"
        
        retryLogger.debug("🔄 API RETRY (Attempt \(attempt, privacy: .public))")
        retryLogger.debug("   \(url, privacy: .public)")
        retryLogger.error("   ⚠️ Reason: \(error.localizedDescription, privacy: .public)")
    }
    
    // MARK: - Helper Methods
    
    private func getStatusEmoji(_ statusCode: Int) -> String {
        switch statusCode {
        case 200...299:
            return "✅"
        case 300...399:
            return "↩️"
        case 400...499:
            return "❌"
        case 500...599:
            return "💥"
        default:
            return "❓"
        }
    }
    
    private func isSensitiveKey(_ key: String) -> Bool {
        let sensitiveKeys = ["authorization", "token", "password", "secret", "key"]
        let lowercaseKey = key.lowercased()
        
        return sensitiveKeys.contains { lowercaseKey.contains($0) }
    }
    
    private func formatJSON(from data: Data) -> String? {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys])
            
            return String(data: prettyData, encoding: .utf8)
        } catch {
            // JSON 파싱 실패 시 nil 반환
            return nil
        }
    }
}

// MARK: - Extensions

extension APILogLevel: CustomStringConvertible {
    public var description: String {
        switch self {
        case .none:
            return "None"
        case .basic:
            return "Basic"
        case .headers:
            return "Headers"
        case .body:
            return "Body"
        case .verbose:
            return "Verbose"
        }
    }
}

extension URLRequest.CachePolicy {
    var description: String? {
        switch self {
        case .useProtocolCachePolicy:
            return "Use Protocol Cache Policy"
        case .reloadIgnoringLocalCacheData:
            return "Reload Ignoring Local Cache Data"
        case .reloadIgnoringLocalAndRemoteCacheData:
            return "Reload Ignoring Local and Remote Cache Data"
        case .returnCacheDataElseLoad:
            return "Return Cache Data Else Load"
        case .returnCacheDataDontLoad:
            return "Return Cache Data Don't Load"
        case .reloadRevalidatingCacheData:
            return "Reload Revalidating Cache Data"
        @unknown default:
            return nil
        }
    }
}

// MARK: - Measurement Helper

internal final class APITimer: Sendable {
    private let startTime: CFAbsoluteTime
    
    init() {
        startTime = CFAbsoluteTimeGetCurrent()
    }
    
    var duration: TimeInterval {
        return CFAbsoluteTimeGetCurrent() - startTime
    }
}
