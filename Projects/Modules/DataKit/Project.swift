import ProjectDescription
import ProjectDescriptionHelpers

let frameworkName: String = "DataKit"

let frameworkTargets: [Target] = FrameworkFactory(
    dependency: .init(
        frameworkDependencies: [
            Dep.Project.DomainKit,
            Dep.Project.FoundationKit,
            Dep.Project.DIKit,
        ],
        unitTestsDependencies: []
    )
).build(
    payload: .init(
        name: frameworkName,
        destinations: .iOS,
        product: .staticFramework
    )
)

let project = ProjectFactory(
    dependency: .init(
        appTargets: [],
        frameworkTargets: frameworkTargets
    )
).build(
    payload: .init(
        name: frameworkName,
        organizationName: "Sparkish"
    )
)
