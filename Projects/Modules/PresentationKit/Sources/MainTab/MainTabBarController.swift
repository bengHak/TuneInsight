import UIKit

public final class MainTabBarController: UITabBarController {
    public weak var coordinator: MainTabBarCoordinator?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .systemGray
        tabBar.backgroundColor = .systemBackground
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.1
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -1)
        tabBar.layer.shadowRadius = 8
    }
    
    public func setupViewControllers(
        homeNav: UINavigationController,
        statisticsNav: UINavigationController,
        playlistNav: UINavigationController,
        settingsNav: UINavigationController
    ) {
        homeNav.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        statisticsNav.tabBarItem = UITabBarItem(title: "통계", image: UIImage(systemName: "chart.bar"), selectedImage: UIImage(systemName: "chart.bar.fill"))
        playlistNav.tabBarItem = UITabBarItem(title: "플레이리스트", image: UIImage(systemName: "music.note.list"), selectedImage: UIImage(systemName: "music.note.list"))
        settingsNav.tabBarItem = UITabBarItem(title: "설정", image: UIImage(systemName: "gearshape"), selectedImage: UIImage(systemName: "gearshape.fill"))
        
        setViewControllers([homeNav, statisticsNav, playlistNav, settingsNav], animated: false)
    }
}