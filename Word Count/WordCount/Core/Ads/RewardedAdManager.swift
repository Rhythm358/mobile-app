import SwiftUI
import GoogleMobileAds

class RewardedAdManager: NSObject, ObservableObject, FullScreenContentDelegate {
    @Published var isAdLoaded = false
    @Published var isShowingAd = false
    
    private var rewardedAd: RewardedAd?
    //private let adUnitID = "ca-app-pub-3940256099942544/1712485313" // テスト用ID
    private let adUnitID = "ca-app-pub-1474069724283041/5231972305" // 本番用ID
    
    override init() {
        super.init()
        loadRewardedAd()
    }
    
    func loadRewardedAd() {
        Task {
            do {
                rewardedAd = try await RewardedAd.load(
                    with: adUnitID,
                    request: Request()
                )
                rewardedAd?.fullScreenContentDelegate = self
                DispatchQueue.main.async {
                    self.isAdLoaded = true
                    print("リワード広告が正常に読み込まれました")
                }
            } catch {
                DispatchQueue.main.async {
                    print("リワード広告の読み込みに失敗: \(error.localizedDescription)")
                    self.isAdLoaded = false
                }
            }
        }
    }
    
    func showRewardedAd(completion: @escaping (Bool) -> Void) {
        guard let rewardedAd = rewardedAd else {
            print("リワード広告が読み込まれていません")
            completion(false)
            return
        }
        
        isShowingAd = true
        rewardedAd.present(from: nil) {
            // ユーザーが広告を最後まで視聴した場合の報酬処理
            let reward = rewardedAd.adReward
            print("Reward amount: \(reward.amount)")
            completion(true)
        }
    }
    
    // MARK: - FullScreenContentDelegate
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        isShowingAd = false
        loadRewardedAd() // 次の広告を読み込み
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        isShowingAd = false
        print("リワード広告の表示に失敗: \(error.localizedDescription)")
    }
}
