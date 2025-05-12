//
//  AdBanner.swift
//  MemoApp
//


import Foundation
import GoogleMobileAds
import SwiftUI

struct BannerView: UIViewControllerRepresentable {
    func makeUIViewController(context _: Context) -> UIViewController {
        let viewController = GADBannerViewController()
        return viewController
    }

    func updateUIViewController(_: UIViewController, context _: Context) {}
}

class GADBannerViewController: UIViewController, GADBannerViewDelegate {
    var bannerView: GADBannerView!

    // バーナー広告ユニット ID
    // テスト用：ca-app-pub-3940256099942544/2934735716
    // 本番用：ca-app-pub-1474069724283041/5265890697
    let adUnitID = "ca-app-pub-1474069724283041/5265890697"

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadBanner()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            guard let self else { return }
            self.loadBanner()
        }
    }

    func loadBanner() {
        // 既存のバナーを削除
        bannerView?.removeFromSuperview()

        // アダプティブバナーのサイズを取得
        let bannerWidth = view.frame.size.width
        let adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(bannerWidth)

        bannerView = GADBannerView(adSize: adSize)
        bannerView.adUnitID = adUnitID
        bannerView.delegate = self
        bannerView.rootViewController = self

        let request = GADRequest()
        request.scene = view.window?.windowScene
        bannerView.load(request)

        setAdView(bannerView)
    }

    func setAdView(_ view: GADBannerView) {
        bannerView = view
        self.view.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false

        // レイアウト制約を設定
        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            bannerView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // GADBannerViewDelegate メソッド
        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            print("Banner loaded successfully")
        }

        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            print("Failed to load banner ad: \(error.localizedDescription)")
        }
}
