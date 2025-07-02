using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using GoogleMobileAds.Api;
using Crystal;

public class AdMobScript : MonoBehaviour
{
    private BannerView bannerView;

    public void Start()
    {

        // Google AdMob Initial
        MobileAds.Initialize(initStatus => { });

        this.RequestBanner();
    }

    private void RequestBanner()
    {
#if UNITY_ANDROID
        string adUnitId = "ca-app-pub-1474069724283041/7364983531"; // 広告ユニットID
#elif UNITY_IPHONE
        string adUnitId = "ca-app-pub-1474069724283041/2511331852"; // 広告ユニットID
#else
    string adUnitId = "unexpected_platform";
#endif

        // Create a 320x50 banner at the bottom of the screen.
        this.bannerView = new BannerView(adUnitId, AdSize.Banner, AdPosition.Top);

        // Create an empty ad request.
        AdRequest request = new AdRequest();

        // Load the banner with the request.
        bannerView.LoadAd(request);

    }
}