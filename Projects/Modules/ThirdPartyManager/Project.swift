import ProjectDescription
import ProjectDescriptionHelpers

let frameworkName: String = "ThirdPartyManager"

let frameworkTargets: [Target] = FrameworkFactory(
    dependency: .init(
        frameworkDependencies: [
            .SPM.Alamofire,
            .SPM.Swinject,
            .SPM.Then,
            .SPM.SnapKit,
            .SPM.ReactorKit,
            .SPM.RxSwift,
            .SPM.RxCocoa,
            .SPM.SpotifyiOS,
            .SPM.Kingfisher,
            .SPM.RxDataSources,
            .SPM.RevenueCat,
        ],
        unitTestsDependencies: []
    )
).build(
    payload: .init(
        name: frameworkName,
        destinations: .iOS,
        product: .staticFramework,
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
