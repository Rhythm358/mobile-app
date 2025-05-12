//
//  AI_Chat_View.swift
//  Word Count
//

import SwiftUI


struct AI_Chat_View<ViewModel: ViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @State private var text = ""
    @FocusState var focus: Bool
    
    // @AppStorage:データを永続化
    @AppStorage("send_counter") var send_counter = 0
    // インタースティシャル広告
    @ObservedObject var interstitial = Interstitial()
    // @FocusState:フォーカス対象の管理
    @FocusState  var isActive:Bool
    
    var body: some View {
        // GeometryReader : 親ビューのサイズや位置を検出し、子ビューのレイアウトを調整するために使用
        // geometry.size       -> 親ビューのサイズ取得
        // geometry.frame(in:) -> 親ビューの座標空間取得
        GeometryReader { geometry in
            ZStack {
                VStack {
                    ScrollViewReader { proxy in
                        ScrollView {
                            ForEach(viewModel.messages, id: \.self) { message in

                                let borderColor: Color = message.role == .user ? Color.mint : Color.orange
                                
                                Text(message.content)
                                    .padding(10)    //文章周りの余白
                                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(borderColor, lineWidth: 2)) //枠線を追加
                                    .font(.title3)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            Color.clear.padding(.bottom, 60).id(200)
                        }
                        // 新しいメッセージが追加されるたびに、ビュー内のスクロール位置を自動的に最新のメッセージにスクロール
                        .onChange(of: viewModel.messages) { _ in
                            withAnimation {
                                // ビュー内の要素を指定のID（ここでは200）にスクロール
                                proxy.scrollTo(200)
                            }
                        }
                    }

                    Spacer()
                    HStack {
                        Image(systemName: "cpu") // システムアイコンの表示
                            .font(.title2)
                            .foregroundColor(Color.blue)
                        
                        ZStack(alignment : .leading){
                            TextEditor(text: $text)
                                .overlay(RoundedRectangle(cornerRadius: 5).stroke(.gray, lineWidth: 1)) // 枠線を丸くする
                                .frame(height: 60) // フレームサイズ指定
                                .border(Color.blue, width: 1)   // フレーム外枠の色と太さ指定
                                .focused($isActive)
                                .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()   // 右寄せにする
                                    Button("Done") {
                                        isActive = false  // フォーカスを外す
                                    }
                                }
                            }
                            if text.isEmpty {
                                Text("Input here")
                                    .foregroundColor(Color(uiColor: .placeholderText))
                                    .allowsHitTesting(false)
                                    .padding(20)
                                    .padding(.top, 5)
                            }
                        }
                        Button {
                            //print("Send Button Chlicked \(send_counter)")
                            focus = false
                            viewModel.askChatGPT(text: text)
                            send_counter += 1
                            if(send_counter>=4){
                                interstitial.ShowInterstitial() // インタースティシャル広告を表示
                                send_counter=0
                            }
                            text = ""
                        } label: {
                            Image(systemName: "paperplane") // システムアイコンの表示
                                .foregroundColor(Color.blue)
                                .font(.title2)
                        }
                    }
                }
                .padding( .init( // 余白を設定
                    top: geometry.safeAreaInsets.top + 10, leading: 20,
                    bottom: geometry.safeAreaInsets.bottom+10,
                    trailing: 20)
                )
                .onTapGesture { // ビュー全体がタップされたとき
                    focus.toggle()
                }
            }
            // ビューが画面全体に表示され、すべての外視範囲(ステータスバー（通知バー）、ノッチおよびホームインジケータ(ホームボタンなし))を無視
            .edgesIgnoringSafeArea(.all)
            //　キーボード出現時の自動スクロール対策
            .ignoresSafeArea(.keyboard, edges: .bottom)
            // くるくる回るアニメーション trueの場合：くるくる回る
            if viewModel.isAsking {
                withAnimation {
                    ZStack {
                        Color.black.opacity(0.5)
                            .edgesIgnoringSafeArea(.all)
                        ActivityIndicator()
                    }
                }
            }
        }
        .navigationTitle("AI Chat")
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Confirmation"),
                message: Text(viewModel.errorText)
            )
        }
        .onAppear(){
            interstitial.LoadInterstitial() // インタースティシャル広告ロード
        }
        
        //================================================
        // バナー広告を表示
        //AdMobBannerView().frame(width: 320, height: 50)
        //================================================
        
    }//bodyここまで
    
} //AI_Chat_Viewここまで


// UIViewRepresentable : SwiftUIでUIKitのUIView/UIViewControllerを使えるようにしてくれるwrapper
//makeUIView()/updateUIView()の中にUIKitのコードを実装することで、SwiftUI上でもUIKitの機能を使える
// くるくる回るスタイルのアクティビティインジケータを表示
struct ActivityIndicator: UIViewRepresentable {
    // ラップする UIView(UIActivityIndicatorView)のインスタンスを作って返す
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: .large)
    }
    // データの更新に応じてラップしている UIView を更新する
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        // アニメーション開始
        uiView.startAnimating()
    }
}
