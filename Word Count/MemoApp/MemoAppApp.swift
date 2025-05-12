import AppTrackingTransparency
import GoogleMobileAds
import SwiftUI

// アプリケーションのエントリーポイントを定義
@main
struct MemoAppApp: App {
    // データ管理用のコントローラーを取得
    let persistenceController = PersistenceController.shared
    // ダークモード対応
    @AppStorage(wrappedValue: 0, "appearanceMode") var appearanceMode
    @StateObject var appOpen = AppOpen()

    init() {
        // アプリ起動時にATTと広告の設定を行う
        setupATTAndAds()
    }

    var body: some Scene {
        // メインのウィンドウを設定
        WindowGroup {
            // ContentViewを表示
            ContentView()
                // 環境変数にCoreDataのコンテキストを設定
                .environment(
                    \.managedObjectContext,
                    persistenceController.container.viewContext
                )
                // ダークモード対応
                .applyAppearenceSetting(
                    DarkModeSetting(rawValue: self.appearanceMode)
                        ?? .followSystem
                )

        }
        .onChange(of: appOpen.appOpenAdLoaded) { newValue in
                    if newValue {
                        appOpen.presentAppOpenAd()
                    }
                }
    }

    // ATTの許可要求と広告の初期化を行う関数
    private func setupATTAndAds() {
        // アプリ起動後1秒遅延させて実行
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // App Tracking Transparencyの許可をユーザーにリクエスト
            ATTrackingManager.requestTrackingAuthorization { status in
                // Google Admob広告の初期化
                GADMobileAds.sharedInstance().start(completionHandler: nil)
                // アプリ起動時広告のロード
                self.appOpen.loadAppOpenAd()
            }
        }
    }
}

//ダークモード対応
extension View {
    @ViewBuilder
    func applyAppearenceSetting(_ setting: DarkModeSetting) -> some View {
        switch setting {
        case .followSystem:
            self
                .preferredColorScheme(.none)
        case .darkMode:
            self
                .preferredColorScheme(.dark)
        case .lightMode:
            self
                .preferredColorScheme(.light)
        }
    }
}
