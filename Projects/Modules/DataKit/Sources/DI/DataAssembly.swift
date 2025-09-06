import Foundation
import DIKit
import DomainKit
import FoundationKit
import Swinject

public final class DataAssembly: DIAssembly {
    
    public init() {}
    
    public func assemble(container: Container) {
        assembleServices(container: container)
        assembleRepositories(container: container)
    }
    
    private func assembleServices(container: Container) {
        container.register(SpotifyServiceProtocol.self) { _ in
            SpotifyService.shared
        }
        .inObjectScope(.container)
    }
    
    private func assembleRepositories(container: Container) {
        container.register(SpotifyRepository.self) { resolver in
            let service = resolver.resolve(SpotifyServiceProtocol.self)!
            return SpotifyRepositoryImpl(service: service)
        }
        .inObjectScope(.container)
    }
}