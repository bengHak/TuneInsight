import Foundation
import Swinject

public protocol DIAssembly {
    func assemble(container: Container)
}

public final class DIContainer {
    public static let shared = DIContainer()
    
    private let container = Container()
    private var assemblies: [DIAssembly] = []
    
    private init() {}
    
    public func addAssembly(_ assembly: DIAssembly) {
        assemblies.append(assembly)
        assembly.assemble(container: container)
    }
    
    public func resolve<T>(_ type: T.Type) -> T? {
        return container.resolve(type)
    }
    
    public func resolve<T>(_ type: T.Type, name: String?) -> T? {
        return container.resolve(type, name: name)
    }
    
    public func register<T>(_ type: T.Type, name: String? = nil, factory: @escaping (Resolver) -> T) {
        container.register(type, name: name, factory: factory)
    }
}

public class DIResolver {
    private let container: DIContainer
    
    public init(container: DIContainer = .shared) {
        self.container = container
    }
    
    public func resolve<T>(_ type: T.Type) -> T? {
        return container.resolve(type)
    }
    
    public func resolve<T>(_ type: T.Type, name: String?) -> T? {
        return container.resolve(type, name: name)
    }
}

public func resolve<T>(_ type: T.Type) -> T? {
    return DIContainer.shared.resolve(type)
}

public func resolve<T>(_ type: T.Type, name: String?) -> T? {
    return DIContainer.shared.resolve(type, name: name)
}
