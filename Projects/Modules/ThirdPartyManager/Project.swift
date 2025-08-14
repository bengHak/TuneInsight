import ProjectDescription
import ProjectDescriptionHelpers

let frameworkName: String = "ThirdPartyManager"

let frameworkTargets: [Target] = FrameworkFactory(
    dependency: .init(
        frameworkDependencies: [
            .SPM.ComposableArchitecture,
            .SPM.Alamofire,
            .SPM.Swinject,
            .SPM.Then,
            .SPM.SnapKit,
            .SPM.ReactorKit,
            .SPM.RxSwift,
            .SPM.RxCocoa,
            .SPM.SpotifyiOS,
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
