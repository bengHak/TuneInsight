import ProjectDescription
import ProjectDescriptionHelpers

let frameworkName: String = "PresentationKit"

let frameworkTargets: [Target] = FrameworkFactory(
    dependency: .init(
        frameworkDependencies: [
            Dep.Project.DIKit,
            Dep.Project.DomainKit,
            Dep.Project.FoundationKit,
            Dep.Project.ThirdPartyManager,
        ],
        unitTestsDependencies: []
    )
).build(
    payload: .init(
        name: frameworkName,
        destinations: .iOS,
        product: .framework
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
