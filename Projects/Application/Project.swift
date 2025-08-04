import ProjectDescription
import ProjectDescriptionHelpers

let appName: String = "SpotifyStats"

let infoPlist: [String: Plist.Value] = [
    "CFBundleExecutable": "$(EXECUTABLE_NAME)",
    "CFBundleShortVersionString": "1.0",
    "CFBundleVersion": "1",
    "CFBundleIdentifier": "$(PRODUCT_BUNDLE_IDENTIFIER)",
    "CFBundleDisplayName": .init(stringLiteral: appName),
    "UIUserInterfaceStyle": "Light",
    "UILaunchScreen": [
        "UIColorName": "",
        "UIImageName": "",
    ],
    // UIKit lifecycle with UIScene + SceneDelegate
    "UIApplicationSceneManifest": [
        "UIApplicationSupportsMultipleScenes": false,
        "UISceneConfigurations": [
            "UIWindowSceneSessionRoleApplication": [
                [
                    "UISceneConfigurationName": "Default Configuration",
                    "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate"
                ]
            ]
        ]
    ]
]

// MARK: - App
let appTargets: [Target] = AppFactory(
    dependency: AppFactory.Dependency(
        appDependencies: [
            Dep.Project.FoundationKit,
            Dep.Project.DIKit,
            Dep.Project.DataKit,
            Dep.Project.DomainKit,
            Dep.Project.PresentationKit,
            Dep.Project.ThirdPartyManager,
        ],
        unitTestsDependencies: []
    )
).build(
    payload: AppFactory.Payload(
        bundleID: "kr.Sparkish.SpotifyStats",
        name: appName,
        destinations: .iOS,
        infoPlist: infoPlist
    )
)

// MARK: - Project
let project = ProjectFactory(
    dependency: ProjectFactory.Dependency(
        appTargets: appTargets,
        frameworkTargets: []
    )
).build(
    payload: ProjectFactory.Payload(
        name: appName,
        organizationName: "Sparkish"
    )
)
