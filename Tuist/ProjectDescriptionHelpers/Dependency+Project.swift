//
//  Dependency+Project.swift
//  ProjectDescriptionHelpers
//
//  Created by Template Generator
//

import ProjectDescription

public extension TargetDependency {
    public struct Project {}
}

public extension TargetDependency.Project {
    // Core Modules
    static let FoundationKit = Self.project("FoundationKit", path: .relativeToRoot("Projects/Modules/FoundationKit"))
    static let DIKit = Self.project("DIKit", path: .relativeToRoot("Projects/Modules/DIKit"))
    
    // Domain Layer
    static let DomainKit = Self.project("DomainKit", path: .relativeToRoot("Projects/Modules/DomainKit"))
    
    // Data Layer
    static let DataKit = Self.project("DataKit", path: .relativeToRoot("Projects/Modules/DataKit"))
    
    // Presentation Layer
    static let PresentationKit = Self.project("PresentationKit", path: .relativeToRoot("Projects/Modules/PresentationKit"))
    
    // Third Party Manager
    static let ThirdPartyManager = Self.project("ThirdPartyManager", path: .relativeToRoot("Projects/Modules/ThirdPartyManager"))
    
    private static func project(_ name: String, path: Path) -> TargetDependency {
        return TargetDependency.project(target: name, path: path)
    }
}

// Convenience typealias for shorter access
public typealias Dep = TargetDependency
