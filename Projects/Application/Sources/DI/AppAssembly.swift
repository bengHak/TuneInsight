import Foundation
import DIKit
import DataKit
import DomainKit
import PresentationKit

public final class AppAssembly {
    
    public init() {}
    
    public func setupDI() {
        let container = DIContainer.shared
        
        container.addAssembly(DataAssembly())
        container.addAssembly(DomainAssembly())
        container.addAssembly(PresentationAssembly())
    }
}