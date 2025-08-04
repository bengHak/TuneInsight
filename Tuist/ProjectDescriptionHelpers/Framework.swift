//
//  Framework.swift
//  ProjectDescriptionHelpers
//
//  Created by 고병학 on 2023/01/25.
//

import ProjectDescription

public struct FrameworkFactory {
    
    public struct Dependency {
        
        let frameworkDependencies: [TargetDependency]
        let unitTestsDependencies: [TargetDependency]
        
        public init(
            frameworkDependencies: [TargetDependency],
            unitTestsDependencies: [TargetDependency]
        ) {
            self.frameworkDependencies = frameworkDependencies
            self.unitTestsDependencies = unitTestsDependencies
        }
    }
    
    public struct Payload {
        
        let name: String
        let destinations: Destinations
        let product: Product
        
        public init(
            name: String,
            destinations: Destinations,
            product: Product
        ) {
            self.name = name
            self.destinations = destinations
            self.product = product
        }
    }
    
    private let dependency: Dependency
    
    public init(dependency: Dependency) {
        self.dependency = dependency
    }
    
    public func build(payload: Payload) -> [Target] {
        
        let sourceTarget: Target = .target(
            name: payload.name,
            destinations: payload.destinations,
            product: payload.product,
            bundleId: payload.name,
            deploymentTargets: deploymentTarget,
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            scripts: [.SwiftLintString],
            dependencies: self.dependency.frameworkDependencies
        )
        
        let testTarget: Target = .target(
            name: "\(payload.name)Tests",
            destinations: payload.destinations,
            product: .unitTests,
            bundleId: payload.name + "Tests",
            deploymentTargets: deploymentTarget,
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: [],
            dependencies: [
                .target(name: payload.name),
            ] + self.dependency.unitTestsDependencies
        )
        
        return [sourceTarget, testTarget]
    }
}
