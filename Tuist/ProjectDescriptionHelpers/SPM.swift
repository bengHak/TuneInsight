//
//  SPM.swift
//  Config
//
//  Created by 고병학 on 2023/01/25.
//

import ProjectDescription

public extension TargetDependency {
    public struct SPM {}
}

public extension TargetDependency.SPM {
    static let Swinject = Self.external("Swinject")
    static let ComposableArchitecture = Self.external("ComposableArchitecture")
    static let Alamofire = Self.external("Alamofire")
    
    private static func external(_ name: String) -> TargetDependency {
        return TargetDependency.external(name: name)
    }
    
    private static func package(product: String) -> TargetDependency {
        return TargetDependency.package(product: product)
    }
}
