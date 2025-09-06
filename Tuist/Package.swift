// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        productTypes: [
            "Alamofire": .framework,
            "ComposableArchitecture": .framework,
            "Swinject": .framework,
            "Then": .framework,
            "SnapKit": .framework,
            "ReactorKit": .framework,
            "RxSwift": .framework,
            "RxCocoa": .framework,
            "RxRelay": .framework,
            "SpotifyiOS": .framework,
        ]
    )

#endif

let package = Package(
    name: "SpotifyStats",
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.8.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.5.0"),
        .package(url: "https://github.com/Swinject/Swinject", from: "2.8.0"),
        .package(url: "https://github.com/devxoul/Then", from: "3.0.0"),
        .package(url: "https://github.com/SnapKit/SnapKit", from: "5.7.0"),
        .package(url: "https://github.com/ReactorKit/ReactorKit", from: "3.2.0"),
        .package(url: "https://github.com/ReactiveX/RxSwift", from: "6.6.0"),
        .package(url: "https://github.com/spotify/ios-sdk", from: "5.0.1"),
    ]
)
