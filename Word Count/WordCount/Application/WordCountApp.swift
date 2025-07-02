import AppTrackingTransparency
import GoogleMobileAds
import SwiftUI

@main
struct WordCountApp: App {
    let persistenceController = PersistenceController.shared
    
    @AppStorage(wrappedValue: 0, "appearanceMode") var appearanceMode
    @StateObject private var pointManager = PointManager()
    @State private var bannerSize: CGSize = .zero
    
    init() {
        setupATTAndAds()
    }
    
    var body: some Scene {
        WindowGroup {
            VStack(spacing: 0) {
                // MemoListViewを表示
                MemoListView()
                    .environment(
                        \.managedObjectContext,
                         persistenceController.container.viewContext
                    )
                    .environmentObject(pointManager)
                    .applyAppearenceSetting(
                        DarkModeSetting(rawValue: self.appearanceMode)
                        ?? .followSystem
                    )
                
                // 最適化されたバナー表示
                dynamicBannerView
            }
        }
    }
    
    // バナー表示の計算プロパティ
    private var dynamicBannerView: some View {
        Group {
            if bannerSize.height > 0 {
                // 実際のサイズが確定したバナー
                BannerView(bannerSize: $bannerSize)
                    .frame(
                        width: bannerSize.width,
                        height: bannerSize.height
                    )
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 0))
                    .animation(.easeInOut(duration: 0.3), value: bannerSize)
            } else {
                // 読み込み中のプレースホルダー
                BannerView(bannerSize: $bannerSize)
                    .frame(
                        width: UIScreen.main.bounds.width,
                        height: 50
                    )
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 0))
            }
        }
    }
    
    private func setupATTAndAds() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            ATTrackingManager.requestTrackingAuthorization { status in
                MobileAds.shared.requestConfiguration.testDeviceIdentifiers = ["GADSimulatorID"]
                MobileAds.shared.start(completionHandler: nil)
            }
        }
    }
}

// ダークモード対応
extension View {
    @ViewBuilder
    func applyAppearenceSetting(_ setting: DarkModeSetting) -> some View {
        switch setting {
        case .followSystem:
            self.preferredColorScheme(.none)
        case .darkMode:
            self.preferredColorScheme(.dark)
        case .lightMode:
            self.preferredColorScheme(.light)
        }
    }
}
