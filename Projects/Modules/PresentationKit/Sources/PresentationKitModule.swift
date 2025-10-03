import UIKit

// PresentationKit 모듈의 기본 소스 파일
// UI 및 프레젠테이션 레이어 관련 기능들이 여기에 위치합니다.
public final class PresentationKitModule {
    public static let shared = PresentationKitModule()
    
    private init() {}
    
    public func configure() {
        setGlobalNavigationBar()
    }
    
    private func setGlobalNavigationBar() {
        let appearance = UINavigationBarAppearance()
        
        appearance.titleTextAttributes = [
            .foregroundColor: CustomColor.primaryText,
        ]
        
        appearance.largeTitleTextAttributes = [
            .foregroundColor: CustomColor.primaryText,
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = .white
    }
}
