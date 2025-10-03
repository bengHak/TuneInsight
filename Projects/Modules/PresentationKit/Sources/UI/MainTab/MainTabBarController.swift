import UIKit
import FoundationKit

public final class MainTabBarController: UITabBarController {
    public weak var coordinator: MainTabBarCoordinator?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = CustomColor.background
        setupTabBar()
    }
    
    private func setupTabBar() {
        tabBar.tintColor = CustomColor.accent
        tabBar.unselectedItemTintColor = CustomColor.secondaryText
        if #unavailable(iOS 26) {
            let appearance = UITabBarAppearance()
            appearance.backgroundColor = CustomColor.background
            appearance.stackedLayoutAppearance.normal.iconColor = CustomColor.secondaryText
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: CustomColor.secondaryText]
            appearance.stackedLayoutAppearance.selected.iconColor = CustomColor.accent
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: CustomColor.accent]
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    public func setupViewControllers(
        homeNav: UINavigationController,
        statisticsNav: UINavigationController,
        playlistNav: UINavigationController,
        settingsNav: UINavigationController
    ) {
        homeNav.tabBarItem = UITabBarItem(title: "tab.home".localized(), image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        statisticsNav.tabBarItem = UITabBarItem(title: "statistics.title".localized(), image: UIImage(systemName: "chart.bar"), selectedImage: UIImage(systemName: "chart.bar.fill"))
        playlistNav.tabBarItem = UITabBarItem(title: "playlist.title".localized(), image: UIImage(systemName: "music.note.list"), selectedImage: UIImage(systemName: "music.note.list"))
        settingsNav.tabBarItem = UITabBarItem(title: "settings.title".localized(), image: UIImage(systemName: "gearshape"), selectedImage: UIImage(systemName: "gearshape.fill"))
        
        setViewControllers([homeNav, statisticsNav, playlistNav, settingsNav], animated: false)
    }
}
