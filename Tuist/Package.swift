// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        productTypes: [
            "Alamofire": .framework,
            "ComposableArchitecture": .framework,
            "Swinject": .framework,
        ]
    )

#endif

let package = Package(
    name: "SpotifyStats",
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.8.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.5.0"),
        .package(url: "https://github.com/Swinject/Swinject", from: "2.8.0"),
    ]
)
