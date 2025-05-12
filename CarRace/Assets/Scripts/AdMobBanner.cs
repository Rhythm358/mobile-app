using UnityEngine;
using System;
using GoogleMobileAds.Api;

public class AdMobBanner : MonoBehaviour
{

    private BannerView bannerView;              // BannerView型の変数bannerViewを宣言　この中にバナー広告の情報が入る
    private DeviceOrientation PrevOrientation;  // 直前のディスプレイ向き


    // 端末の向きを取得するメソッド
    DeviceOrientation getOrientation()
    {

        DeviceOrientation result = Input.deviceOrientation;

        // Unkownならピクセル数から判断
        if (result == DeviceOrientation.Unknown)
        {
            if (Screen.width < Screen.height)
            {
                result = DeviceOrientation.Portrait;
            }
            else
            {
                result = DeviceOrientation.LandscapeLeft;
            }
        }

        return result;
    }


    //シーン読み込み時からバナーを表示する
    //最初からバナーを表示したくない場合はこの関数を消してください。
    private void Start()
    {
        PrevOrientation = getOrientation(); // 端末の向きを取得するメソッド
        RequestBanner();                    // アダプティブバナーを表示する関数 呼び出し
    }

    //ボタン等に割り付けて使用
    //バナーを表示する関数
    public void BannerStart()
    {
        RequestBanner();//アダプティブバナーを表示する関数 呼び出し       
    }

    //ボタン等に割り付けて使用
    //バナーを削除する関数
    public void BannerDestroy()
    {
        bannerView.Destroy();//バナー削除
    }

    //アダプティブバナーを表示する関数
    private void RequestBanner()
    {
        //AndroidとiOSで広告IDが違うのでプラットフォームで処理を分けます。
        // 参考
        //【Unity】AndroidとiOSで処理を分ける方法
        // https://marumaro7.hatenablog.com/entry/platformsyoriwakeru

        #if UNITY_ANDROID
        string adUnitId = "ca-app-pub-1474069724283041/7256445044";//ここにAndroidのバナーIDを入力

        #elif UNITY_IPHONE
        string adUnitId = "ca-app-pub-1474069724283041/5015378791";//ここにiOSのバナーIDを入力

        #else
        string adUnitId = "unexpected_platform";
        #endif

        // 新しい広告を表示する前にバナーを削除
        if (bannerView != null)//もし変数bannerViewの中にバナーの情報が入っていたら
        {
            bannerView.Destroy();//バナー削除
        }

        //現在の画面の向き横幅を取得しバナーサイズを決定
        AdSize adaptiveSize =
                AdSize.GetCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(AdSize.FullWidth);


        //バナーを生成 new BannerView(バナーID,バナーサイズ,バナー表示位置)
        bannerView = new BannerView(adUnitId, adaptiveSize, AdPosition.Top);//バナー表示位置は
                                                                               //画面上に表示する場合：AdPosition.Top
                                                                               //画面下に表示する場合：AdPosition.Bottom


        //BannerView型の変数 bannerViewの各種状態 に関数を登録
        //bannerView.OnAdLoaded += HandleAdLoaded;//bannerViewの状態が バナー表示完了 となった時に起動する関数(関数名HandleAdLoaded)を登録
        //bannerView.OnAdFailedToLoad += HandleAdFailedToLoad;//bannerViewの状態が バナー読み込み失敗 となった時に起動する関数(関数名HandleAdFailedToLoad)を登録

        //リクエストを生成
        AdRequest adRequest = new AdRequest.Builder().Build();

        //広告表示
        bannerView.LoadAd(adRequest);
    }


    #region Banner callback handlers
    //バナー表示完了 となった時に起動する関数
    public void HandleAdLoaded(object sender, EventArgs args)
    {
        //Debug.Log("バナー表示完了");
    }

    //バナー読み込み失敗 となった時に起動する関数
    public void HandleAdFailedToLoad(object sender, AdFailedToLoadEventArgs args)
    {
        Debug.Log("バナー読み込み失敗" + args.LoadAdError);//args.Message:エラー内容        
    }
    #endregion

    void Update()
    {
        DeviceOrientation currentOrientation = getOrientation();

        if (PrevOrientation != currentOrientation)
        {
            // 画面の向きが変わった場合の処理
            RequestBanner();//アダプティブバナーを表示する関数 呼び出し

            PrevOrientation = currentOrientation;
        }
    }
}