import Foundation
import Swinject

// DIKit 모듈 - 의존성 주입을 위한 컨테이너 관리
public final class DIContainer {
    public static let shared = DIContainer()
    
    private let container = Container()
    
    private init() {
        setupDependencies()
    }
    
    public func resolve<T>(_ type: T.Type) -> T? {
        return container.resolve(type)
    }
    
    public func register<T>(_ type: T.Type, factory: @escaping (Resolver) -> T) {
        container.register(type, factory: factory)
    }
    
    private func setupDependencies() {
        // 기본 의존성들을 여기에 등록
        // 예: container.register(SomeProtocol.self) { _ in SomeImplementation() }
    }
}

// 편의를 위한 전역 함수들
public func resolve<T>(_ type: T.Type) -> T? {
    return DIContainer.shared.resolve(type)
}

public func register<T>(_ type: T.Type, factory: @escaping (Resolver) -> T) {
    DIContainer.shared.register(type, factory: factory)
}
