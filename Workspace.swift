import ProjectDescription
import ProjectDescriptionHelpers

let workspace = Workspace(
    name: "SpotifyStats",
    projects: [
        "Projects/Application",
        "Projects/Modules/DIKit",
        "Projects/Modules/DataKit",
        "Projects/Modules/DomainKit",
        "Projects/Modules/FoundationKit",
        "Projects/Modules/PresentationKit",
        "Projects/Modules/ThirdPartyManager"
    ]
)
