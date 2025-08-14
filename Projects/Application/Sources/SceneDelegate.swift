//  SceneDelegate.swift
//  SpotifyStats
import UIKit
import PresentationKit
import Then
import SnapKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    // Configure window and root view controller
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        // Ensure UIKit lifecycle is active via AppDelegate (see Projects/Application/Sources/AppDelegate.swift:5)
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        // Root: UINavigationController with SplashViewController (Projects/Application/Sources/SplashViewController.swift)
        let splashVC = SplashViewController()
        let navigationController = UINavigationController(rootViewController: splashVC)
        navigationController.navigationBar.isHidden = true
        
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
    }
    
    // Stubs for lifecycle (skeleton)
    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}

    // Handle Spotify OAuth redirect
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        // Pass to Spotify auth manager
        SpotifyAuthManager.shared.handle(url: url)
    }
}
