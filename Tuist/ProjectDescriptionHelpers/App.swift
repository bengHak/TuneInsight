//
//  App.swift
//  MyApplicationManifests
//
//  Created by 고병학 on 2023/01/25.
//

import ProjectDescription

let iOSTargetVersion: String = "17.0"
let deploymentTarget: DeploymentTargets = .iOS(iOSTargetVersion)

public struct AppFactory {
    
    public struct Dependency {
        
        let appDependencies: [TargetDependency]
        
        /// Quick, Nimble은 기본으로 갖고 있다.
        let unitTestsDependencies: [TargetDependency]
        
        public init(
            appDependencies: [TargetDependency],
            unitTestsDependencies: [TargetDependency]
        ) {
            
            self.appDependencies = appDependencies
            self.unitTestsDependencies = unitTestsDependencies
        }
    }
    
    public struct Payload {
        
        let bundleID: String
        let name: String
        let destinations: Destinations
        let infoPlist: [String: Plist.Value]
        
        public init(
            bundleID: String,
            name: String,
            destinations: Destinations,
            infoPlist: [String: Plist.Value]
        ) {
            self.bundleID = bundleID
            self.name = name
            self.destinations = destinations
            self.infoPlist = infoPlist
        }
    }
    
    private let dependency: Dependency
    
    public init(dependency: Dependency) {
        self.dependency = dependency
    }
    
    public func build(payload: Payload) -> [Target] {
        
        let mainTarget: Target = .target(
            name: payload.name,
            destinations: payload.destinations,
            product: .app,
            bundleId: payload.bundleID,
            deploymentTargets: deploymentTarget,
            infoPlist: .extendingDefault(with: payload.infoPlist),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            scripts: [.SwiftLintString],
            dependencies: self.dependency.appDependencies,
            settings: .settings(configurations: [
                .debug(name: "Debug", xcconfig: .relativeToRoot("BuildConfigurations/Debug.xcconfig")),
                .release(name: "Release", xcconfig: .relativeToRoot("BuildConfigurations/Release.xcconfig")),
            ])
        )
        
        let testTarget: Target = .target(
            name: "\(payload.name)Tests",
            destinations: payload.destinations,
            product: .unitTests,
            bundleId: payload.bundleID,
            deploymentTargets: deploymentTarget,
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: payload.name),
            ] + self.dependency.unitTestsDependencies
        )
        
        return [mainTarget, testTarget]
    }
}
