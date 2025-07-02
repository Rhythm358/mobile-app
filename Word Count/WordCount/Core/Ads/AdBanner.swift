
import Foundation
import GoogleMobileAds
import SwiftUI

struct BannerView: UIViewControllerRepresentable {
    @Binding var bannerSize: CGSize
    
    init(bannerSize: Binding<CGSize> = .constant(.zero)) {
        self._bannerSize = bannerSize
    }
    
    func makeUIViewController(context _: Context) -> UIViewController {
        let viewController = GADBannerViewController()
        viewController.onSizeChange = { size in
            DispatchQueue.main.async {
                self.bannerSize = size
            }
        }
        return viewController
    }
    
    func updateUIViewController(_: UIViewController, context _: Context) {}
}

class GADBannerViewController: UIViewController, BannerViewDelegate {
    var bannerView: GoogleMobileAds.BannerView!
    var onSizeChange: ((CGSize) -> Void)?
    
    // 統一された広告ユニットID（memolistのみ）
    private let adUnitID = "ca-app-pub-1474069724283041/5265890697"
    
    // デバイス統合型の制限値
    private var maxBannerHeightRatio: CGFloat { 0.15 }  // 統一
    private var maxBannerHeight: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 300 : 120
    }
    private let minBannerHeight: CGFloat = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🎯 AdBanner初期化")
        preloadBanner()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if bannerView == nil {
            loadBanner()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            guard let self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.loadBanner()
            }
        }
    }
    
    func preloadBanner() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.loadBanner()
        }
    }
    
    func loadBanner() {
        bannerView?.removeFromSuperview()
        
        let adSize = getOptimalAdSize()
        bannerView = GoogleMobileAds.BannerView(adSize: adSize)
        bannerView.adUnitID = adUnitID
        bannerView.delegate = self
        bannerView.rootViewController = self
        
        let request = Request()
        request.scene = view.window?.windowScene
        bannerView.load(request)
        setAdView(bannerView)
    }
    
    // デバイス別優先順位に基づくアドサイズ選択
    func getOptimalAdSize() -> AdSize {
        let screenBounds = UIScreen.main.bounds
        let safeArea = view.safeAreaLayoutGuide.layoutFrame
        let bannerWidth = safeArea.width
        let screenHeight = screenBounds.height
        let safeAreaHeight = safeArea.height
        let effectiveHeight = max(safeAreaHeight, screenHeight * 0.8)
        
        // 統一された制限計算
        let maxAllowedHeight = min(effectiveHeight * maxBannerHeightRatio, maxBannerHeight)
        
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let deviceType = isPad ? "iPad" : "iPhone"
        
        print("📊 AdSize判定 - デバイス: \(deviceType)")
        print("📊 Screen: \(screenBounds.size), Safe Area: \(safeArea.size)")
        print("📊 利用可能領域 - Width: \(bannerWidth), Max Height: \(maxAllowedHeight)")
        
        // デバイス別の明確な分岐
        if isPad {
            return selectIPadAdSize(bannerWidth: bannerWidth, maxAllowedHeight: maxAllowedHeight)
        } else {
            // iPhone大画面判定（iPhone X以降 = 812px以上）
            let isLargeIPhone = screenHeight >= 812
            return selectIPhoneAdSize(
                bannerWidth: bannerWidth,
                maxAllowedHeight: maxAllowedHeight,
                isLargeScreen: isLargeIPhone,
                screenHeight: screenHeight
            )
        }
    }
    
    // iPhone専用の優先順位選択（改善版）
    private func selectIPhoneAdSize(bannerWidth: CGFloat, maxAllowedHeight: CGFloat, isLargeScreen: Bool, screenHeight: CGFloat) -> AdSize {
        if isLargeScreen {
            print("📊 iPhone（大画面）優先順位判定開始 - 画面高さ: \(screenHeight)")
            
            // iPhone Pro以降（6.1インチ以上）でMediumRectangle使用
            // 条件緩和：900px → 844px（iPhone 12 Pro以降）
            if screenHeight >= 844 && bannerWidth >= 300 && maxAllowedHeight >= 100 {  // 110 → 100に緩和
                print("🎯 iPhone（大画面）: MediumRectangle (300×250) 選択 - 最高収益（iPhone Pro対応）")
                return AdSizeMediumRectangle
            }
            
            // 既存のLargeBanner条件
            if bannerWidth >= 320 && maxAllowedHeight >= 85 {
                print("🎯 iPhone（大画面）: LargeBanner (320×100) 選択 - 高収益")
                return AdSizeLargeBanner
            }
            
            print("🎯 iPhone（大画面）: AdaptiveBanner 選択 - 安定収益")
            return currentOrientationAnchoredAdaptiveBanner(width: bannerWidth)
            
        } else {
            // iPhone標準は変更なし
            print("📊 iPhone（標準）優先順位判定開始 - 画面高さ: \(screenHeight)")
            
            if bannerWidth >= 320 && maxAllowedHeight >= 85 {
                print("🎯 iPhone（標準）: LargeBanner (320×100) 選択 - 高収益")
                return AdSizeLargeBanner
            }
            
            print("🎯 iPhone（標準）: AdaptiveBanner 選択 - 安定収益")
            return currentOrientationAnchoredAdaptiveBanner(width: bannerWidth)
        }
    }
    
    // iPad専用の優先順位選択（改善版）
    private func selectIPadAdSize(bannerWidth: CGFloat, maxAllowedHeight: CGFloat) -> AdSize {
        print("📊 iPad優先順位判定開始")
        
        // 1. MediumRectangle条件を緩和
        if bannerWidth >= 300 && maxAllowedHeight >= 150 {  // 200 → 150に緩和
            print("🎯 iPad: MediumRectangle (300×250) 選択 - 最高収益")
            return AdSizeMediumRectangle
        }
        
        // 2. Leaderboard条件も微調整
        if bannerWidth >= 728 && maxAllowedHeight >= 60 {  // 70 → 60に緩和
            print("🎯 iPad: Leaderboard (728×90) 選択 - 高収益")
            return AdSizeLeaderboard
        }
        
        // 3. LargeBanner
        if bannerWidth >= 320 && maxAllowedHeight >= 70 {  // 80 → 70に緩和
            print("🎯 iPad: LargeBanner (320×100) 選択 - 標準収益")
            return AdSizeLargeBanner
        }
        
        print("🎯 iPad: AdaptiveBanner 選択 - フォールバック")
        return currentOrientationAnchoredAdaptiveBanner(width: bannerWidth)
    }

    
    func setAdView(_ view: GoogleMobileAds.BannerView) {
        bannerView = view
        self.view.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        
        let heightConstraint = bannerView.heightAnchor.constraint(lessThanOrEqualToConstant: maxBannerHeight)
        heightConstraint.priority = UILayoutPriority(999)
        
        NSLayoutConstraint.activate([
            bannerView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            bannerView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            bannerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            heightConstraint,
            bannerView.heightAnchor.constraint(greaterThanOrEqualToConstant: minBannerHeight)
        ])
    }
    
    // MARK: - BannerViewDelegate
    func bannerViewDidReceiveAd(_ bannerView: GoogleMobileAds.BannerView) {
        let actualSize = CGSize(width: bannerView.frame.width, height: bannerView.frame.height)
        let heightRatio = actualSize.height / UIScreen.main.bounds.height
        
        onSizeChange?(actualSize)
        
        print("✅ Banner loaded successfully")
        print("   サイズ: \(bannerView.adSize)")
        print("   実際: \(actualSize)")
        print("   画面比率: \(String(format: "%.1f", heightRatio * 100))%")
        print("   デバイス: \(UIDevice.current.userInterfaceIdiom == .pad ? "iPad" : "iPhone")")
        
        // フェードイン効果
        bannerView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            bannerView.alpha = 1
        }
    }
    
    func bannerView(_ bannerView: GoogleMobileAds.BannerView, didFailToReceiveAdWithError error: Error) {
        print("❌ Banner failed to load: \(error.localizedDescription)")
        onSizeChange?(CGSize(width: UIScreen.main.bounds.width, height: minBannerHeight))
        
        // 5秒後にリトライ
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.loadBanner()
        }
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GoogleMobileAds.BannerView) {
        print("📊 Banner impression recorded")
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GoogleMobileAds.BannerView) {
        print("📱 Banner will present screen")
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GoogleMobileAds.BannerView) {
        print("📱 Banner will dismiss screen")
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GoogleMobileAds.BannerView) {
        print("📱 Banner did dismiss screen")
    }
}
