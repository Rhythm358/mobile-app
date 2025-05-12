//
//  SettingView.swift
//  MemoApp

import Foundation
import SafariServices
import SwiftUI

struct SettingView: View {

    // @AppStorage:データを永続化
    @AppStorage(wrappedValue: 0, "appearanceMode") var appearanceMode
    @AppStorage(wrappedValue: 0, "selectedOption") var selectedOption
    @AppStorage("TimerFlag") var TimerFlag: Bool = false

    // @State：変数の値が変更されるたびに、bodyを更新
    @State var selectedPickerIndex = 0
    @State private var showPrivacyPolicy = false

    // @ObservedObject:複数のデータを外部ファイルと共有
    @ObservedObject var timerManager: TimerManager

    let availableMinutes = Array(1...60)

    var body: some View {
        List {
            HStack {
                Image(systemName: "hands.sparkles").foregroundColor(
                    .blue)
                Button("   Review on AppStore") {
                    ReviewLink()  // レビューに遷移
                }
            }
            HStack {
                if #available(iOS 16.0, *) {
                    ShareLink(
                        "Share this app",
                        item: URL(
                            string:
                                "https://apps.apple.com/us/app/camerawordcount/id1663102426?ign-itscg=30200&ign-itsct=apps_box_link"
                        )!, message: Text("Message")
                    )
                } else {
                    // Fallback on earlier versions
                }
            }
            // プライバシーポリシーへの遷移ボタンを追加
            HStack {
                Image(systemName: "lock.shield")
                    .foregroundColor(.blue)
                Button("    Privacy Policy") {
                    showPrivacyPolicy = true
                }
            }
            HStack {
                Image(systemName: "camera")
                NavigationLink("Camera Setting") {
                    CameraView()  // カメラビューに遷移
                }
            }
            HStack {
                Image(systemName: "mic")
                NavigationLink("  Microphon Setting") {
                    MicrophoneView()  // マイクビューに遷移
                }
            }
            HStack {
                Image(systemName: "sunglasses")
                Picker("Appearance setting", selection: $appearanceMode) {
                    Text("Follow system")
                        .tag(0)
                    Text("Dark mode")
                        .tag(1)
                    Text("Light mode")
                        .tag(2)
                }
            }  // Light HStackここまで
            .listSectionSeparator(.hidden)
            VStack {
                HStack {
                    Image(systemName: "timer")
                    Toggle(" Timer On/Off", isOn: $TimerFlag)
                        .onChange(of: TimerFlag) { newValue in
                            //=====画面更新用=====//
                            //再描画するためタイマ時間を更新することは無駄な処理だが、
                            //ビューの更新ができないので追加
                            timerManager.setTimerLength(
                                minutes: availableMinutes[
                                    selectedPickerIndex] * 60)
                            selectedOption = selectedPickerIndex
                            //==================//
                        }
                }  // TimerToggle HStackここまで
                HStack {
                    //Image(systemName: "timer")
                    Picker(
                        selection: $selectedPickerIndex,
                        label: Text("       Time")
                    ) {
                        ForEach(0..<availableMinutes.count) { index in
                            Text("\(availableMinutes[index]) min")
                        }
                    }
                    .pickerStyle(DefaultPickerStyle())  //スタイル
                    .onChange(of: selectedPickerIndex) { newValue in
                        timerManager.setTimerLength(
                            minutes: availableMinutes[
                                selectedPickerIndex] * 60)
                        selectedOption = selectedPickerIndex
                    }  // onchangeここまで
                    .onAppear {
                        //前回の選択位置からPickerを選択
                        selectedPickerIndex = selectedOption
                    }  // onAppearここまで
                    //Text("value: \(selectedPickerIndex)")
                }  // Timer HStackここまで
            }
        }
        .navigationTitle("Setting")
        .navigationBarTitleDisplayMode(.inline)  // タイトル表示モード指定
        .sheet(isPresented: $showPrivacyPolicy) {
            SafariView(
                url: URL(
                    string:
                        "https://ss529678.stars.ne.jp/PrivacyPolicy.html"
                )!)

        }
    }  // bodyここまで

    // SafariViewControllerをSwiftUIで使用するためのラッパー
    struct SafariView: UIViewControllerRepresentable {
        let url: URL

        func makeUIViewController(context: Context) -> SFSafariViewController {
            return SFSafariViewController(url: url)
        }

        func updateUIViewController(
            _ uiViewController: SFSafariViewController, context: Context
        ) {}
    }

    func ReviewLink() {
        let application = UIApplication.shared
        application.open(
            URL(
                string:
                    "https://apps.apple.com/us/app/camerawordcount/id1663102426?ign-itscg=30200&ign-itsct=apps_box_link"
            )!, options: [.universalLinksOnly: true])
    }

    struct CameraView: View {
        // インタースティシャル広告
        //@ObservedObject var interstitial = Interstitial()

        var body: some View {
            TabView {
                Image("Home").resizable().scaledToFit()
                Image("Settings").resizable().scaledToFit()
                Image("GeneralLanguage").resizable().scaledToFit()
                Image("Language").resizable().scaledToFit()
                Image("ScanText").resizable().scaledToFit()
            }
            .tabViewStyle(PageTabViewStyle())  //ページ切り替えのスタイル
            .indexViewStyle(
                PageIndexViewStyle(backgroundDisplayMode: .always)
            )  // 角丸半透明の背景を表示
            .navigationTitle("Camera Setting")
            .navigationBarTitleDisplayMode(.inline)  // タイトル表示モード指定
            //        .onAppear(){
            //            //print("Help View Appeared")
            //            interstitial.LoadInterstitial()  // インタースティシャル広告ロード
            //        }
            //        .onDisappear(){
            //            //print("Helop Disappeared")
            //            interstitial.ShowInterstitial() // インタースティシャル広告を表示
            //        }
            // バナー広告を表示
            //AdMobBannerView().frame(width: 320, height: 50)
        }

    }

    struct MicrophoneView: View {
        // インタースティシャル広告
        //@ObservedObject var interstitial = Interstitial()

        var body: some View {

            TabView {
                Image("Home").resizable().scaledToFit()
                Image("Settings").resizable().scaledToFit()
                Image("GeneralKeyboard").resizable().scaledToFit()
                Image("Keyboards").resizable().scaledToFit()
                Image("Microphone").resizable().scaledToFit()
            }
            .tabViewStyle(PageTabViewStyle())  //ページ切り替えのスタイル
            .indexViewStyle(
                PageIndexViewStyle(backgroundDisplayMode: .always)
            )  //角丸半透明の背景を表示
            .navigationTitle("Microphone Setting")
            .navigationBarTitleDisplayMode(.inline)  // タイトル表示モード指定
            //        .onAppear(){
            //            //print("Help View Appeared")
            //            //interstitial.LoadInterstitial() // インタースティシャル広告ロード
            //        }
            //        .onDisappear(){
            //            //print("Helop Disappeared")
            //            interstitial.ShowInterstitial() // インタースティシャル広告を表示
            //        }
            // バナー広告を表示
            //AdMobBannerView().frame(width: 320, height: 50)
        }
    }

}
