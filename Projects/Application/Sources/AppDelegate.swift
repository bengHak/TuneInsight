//  AppDelegate.swift
//  SpotifyStats
import UIKit
import DIKit
import PresentationKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: UIApplicationDelegate

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        setupDependencyInjection()
        PresentationKitModule.shared.configure()
        return true
    }
    
    private func setupDependencyInjection() {
        let appAssembly = AppAssembly()
        appAssembly.setupDI()
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Ensure we use the default configuration and SceneDelegate
        let configuration = UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
    
    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
        // No-op
    }
}
