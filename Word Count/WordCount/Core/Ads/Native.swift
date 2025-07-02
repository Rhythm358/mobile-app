//
// SwiftUIView.swift
// Word Count
//

import SwiftUI
import GoogleMobileAds

struct NativeView: UIViewControllerRepresentable {
    //最初の一回だけ呼び出される
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = GADNativeViewController()
        return viewController
    }
    
    //更新が必要になった場合に呼び出される
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}

class GADNativeViewController: UIViewController, NativeAdDelegate, NativeAdLoaderDelegate {
    var heightConstraint: NSLayoutConstraint?
    var adLoader: AdLoader!
    var nativeAdView: GoogleMobileAds.NativeAdView!
    
    //ネイティブ広告専用ID
    //テスト用 ：ca-app-pub-3940256099942544/3986624511
    //本番用 ：ca-app-pub-1474069724283041/4751079861
    //本番用を使用するときは、ネイティブ広告バリデータ(アプリが公開される前にポリシー違反を検出ツール)を無効にする
    //（Word-Count-Info.plist>GADNativeAdValidatorEnabled = false）
    let adUnitID = "ca-app-pub-1474069724283041/4751079861"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard
            let nibObjects = Bundle.main.loadNibNamed("NativeAdView", owner: nil, options: nil),
            let adView = nibObjects.first as? GoogleMobileAds.NativeAdView
        else {
            return assert(false, "Could not load nib file for adView")
        }
        
        setAdView(adView)
        refreshAd()
    }
    
    func setAdView(_ view: GoogleMobileAds.NativeAdView) {
        nativeAdView = view
        self.view.addSubview(nativeAdView)
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
        
        let viewDictionary = ["_nativeAdView": nativeAdView!]
        self.view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[_nativeAdView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
        )
        
        self.view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[_nativeAdView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
        )
    }
    
    func refreshAd() {
        adLoader = AdLoader(
            adUnitID: adUnitID, rootViewController: self,
            adTypes: [.native],
            options: nil
        )
        
        adLoader.delegate = self
        adLoader.load(Request())
    }
    
    func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
        guard let rating = starRating?.doubleValue else {
            return nil
        }
        
        if rating >= 5 {
            return UIImage(named: "stars_5")
        } else if rating >= 4.5 {
            return UIImage(named: "stars_4_5")
        } else if rating >= 4 {
            return UIImage(named: "stars_4")
        } else if rating >= 3.5 {
            return UIImage(named: "stars_3_5")
        } else {
            return nil
        }
    }
    
    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: GoogleMobileAds.NativeAd) {
        nativeAd.delegate = self
        heightConstraint?.isActive = false
        
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        nativeAdView.bodyView?.isHidden = nativeAd.body == nil
        
        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
        
        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        nativeAdView.iconView?.isHidden = nativeAd.icon == nil
        
        (nativeAdView.starRatingView as? UIImageView)?.image = imageOfStars(from: nativeAd.starRating)
        nativeAdView.starRatingView?.isHidden = nativeAd.starRating == nil
        
        (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
        nativeAdView.storeView?.isHidden = nativeAd.store == nil
        
        (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
        nativeAdView.priceView?.isHidden = nativeAd.price == nil
        
        (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil
        
        nativeAdView.callToActionView?.isUserInteractionEnabled = false
        nativeAdView.nativeAd = nativeAd
    }
    
    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        print("\(adLoader) failed with error: \(error.localizedDescription)")
    }
}
