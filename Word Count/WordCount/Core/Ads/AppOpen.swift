//
// AppOpen.swift
// WordCount
//


import GoogleMobileAds

class AppOpen: NSObject, FullScreenContentDelegate, ObservableObject {
    
    @Published var appOpenAdLoaded: Bool = false
    
    var appOpenAd: AppOpenAd?
    
    override init() {
        super.init()
        loadAppOpenAd()
    }
    
    func loadAppOpenAd() {
        let request = Request()
        AppOpenAd.load(
            with: "ca-app-pub-1474069724283041/9380523384",
            request: request,
            completionHandler: { [weak self] appOpenAdIn, error in
                if let error = error {
                    print("🚫 App Open Ad failed to load with error: \(error.localizedDescription)")
                    return
                }
                
                self?.appOpenAd = appOpenAdIn
                self?.appOpenAd?.fullScreenContentDelegate = self
                self?.appOpenAdLoaded = true
                print("🍊: 準備完了しました")
            }
        )
    }
    
    func presentAppOpenAd() {
        guard let root = self.appOpenAd else { return }
        root.present(from: (UIApplication.shared.windows.first?.rootViewController)!)
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        self.loadAppOpenAd()
        print("😭: エラー -> \(error)")
    }
    
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        self.loadAppOpenAd()
        print("🍅: 閉じました")
    }
}
