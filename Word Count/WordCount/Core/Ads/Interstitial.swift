
import SwiftUI
import GoogleMobileAds

class Interstitial: NSObject, FullScreenContentDelegate, ObservableObject {
    
    @Published var interstitialAdLoaded: Bool = false
    
    var InterstitialAd: InterstitialAd?
    
    override init() {
        super.init()
        LoadInterstitial()
    }
    
    //インタースティシャル広告専用ID
    //テスト用：ca-app-pub-3940256099942544/4411468910
    //let adUnitID = "ca-app-pub-3940256099942544/4411468910"
    //本番用：ca-app-pub-1474069724283041/1992433431
    let adUnitID = "ca-app-pub-1474069724283041/1992433431"
    
    func LoadInterstitial() {
        GoogleMobileAds.InterstitialAd.load(with: adUnitID, request: Request()) { (ad, error) in
            if let error = error {
                print("😭: 読み込みに失敗しました - \(error.localizedDescription)")
                self.interstitialAdLoaded = false
                return
            }
            
            print("😍: 読み込みに成功しました")
            self.interstitialAdLoaded = true
            self.InterstitialAd = ad
            self.InterstitialAd?.fullScreenContentDelegate = self
        }
    }
    
    // インタースティシャル広告の表示
    func ShowInterstitial() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScenes = scenes.first as? UIWindowScene
        let root = windowScenes?.keyWindow?.rootViewController
        
        if let ad = InterstitialAd {
            ad.present(from: root!)
            self.interstitialAdLoaded = false
        } else {
            print("😭: 広告の準備ができていませんでした")
            self.interstitialAdLoaded = false
            self.LoadInterstitial()
        }
    }
    
    // 失敗通知
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("インタースティシャル広告の表示に失敗しました - \(error.localizedDescription)")
        self.interstitialAdLoaded = false
        self.LoadInterstitial()
    }
    
    // 表示通知
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("インタースティシャル広告を表示しました")
        self.interstitialAdLoaded = false
    }
    
    // クローズ通知
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("インタースティシャル広告を閉じました")
        self.interstitialAdLoaded = false
        self.LoadInterstitial()
    }
}
