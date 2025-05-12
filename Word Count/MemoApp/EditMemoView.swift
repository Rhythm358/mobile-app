//
//  InputView.swift
//  MemoApp
//
//

import SwiftUI


// メモを編集するビュー
struct EditMemoView: View {
    @ObservedObject var viewModel = ViewModel()
    // インタースティシャル広告
    @ObservedObject var interstitial = Interstitial()

    // 編集対象のメモ
    private var memo: Memo
    // CoreDataのコンテキストを取得（データベースへのアクセスを管理）
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    // @State：変数の値が変更されるたびに、bodyを更新
    // タイトルと内容を保持する状態変数
    @State private var title: String
    @State private var inputText: String
    @State private var Chars_num: Int
    @State private var Words_num: Int
    @State private var str = ""
    @State private var letter_counter = ""
    @State private var orientation = UIDevice.current.orientation
    @State private var arr:[String] = []
    @State private var Arr:[String] = []
    @State private var textEditorHeight: CGFloat = UIScreen.main.bounds.height * 0.7 // 初期値を設定

    @AppStorage("str_advice") var str_advice = ""

    // @AppStorage:データを永続化 (初期値"")
    @AppStorage("TimerFlag") var TimerFlag = false

    // イニシャライザ（初期化メソッド）
    init(memo: Memo) {
        self.memo = memo
        self.title = memo.title ?? "" // メモのタイトルを初期化
        self.inputText = memo.content ?? "" // メモの内容を初期化
        self.Chars_num = Int(memo.charsNum)
        self.Words_num = Int(memo.wordsNum)
    }

    // @FocusState:フォーカス対象の管理
    @FocusState  var isActive:Bool

    // @StateObject:Viewが表示されてから消えるまで(.onAppearから.onDisAppearまで)
    @StateObject var timerManager = TimerManager()


    let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
        .makeConnectable()
        .autoconnect()

    // ビューの見た目や構成を定義するプロパティ
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    TextField("Title", text: $title)
                        .font(.title) // タイトルのフォントサイズを設定
                        .multilineTextAlignment(.center)
                    Group {
                        VStack {
                            if(TimerFlag == true){
                                TimerSection()
                            }
                            Spacer()
                            TextEditor(text: $inputText)
                                .focused($isActive)
                                .toolbar { toolbarContent }
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
                                .onReceive(NotificationCenter.default.publisher(for: UITextView.textDidChangeNotification)) { obj in
                                    updateCounts()
                                }
                        }
                        .frame(
                            width: geometry.size.width * 0.9, // geometryサイズを使用
                            height: geometry.size.height * 0.9
                        )
                    }
                    .onReceive(orientationChanged) { _ in self.orientation = UIDevice.current.orientation }
                    Spacer()
                    Group {
                        HStack {
                            CountView(title: "Chars", value: "\(Chars_num)", height: 0.15)
                            CountView(title: "Words", value: "\(Words_num)", height: 0.15)
                        } // HStackここまで
                        .padding(.all)
                        // ================================
                        // ネイティブアドバンス広告表示
                        //NativeView().frame(height: 150)
                        // ================================
                        ScoringButton()
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
                        AdviceView()
                        Spacer()
                    }
                    .onReceive(orientationChanged) { _ in self.orientation = UIDevice.current.orientation }
                } // ScrollViewここまで
                // タップでテキストフィールドからフォーカスを外す処理
                .onTapGesture { UIApplication.shared.closeKeyboard() }
                .navigationBarTitleDisplayMode(.inline)
            }
        } // NavigationStackここまで
        .onAppear(){
            interstitial.LoadInterstitial() // インタースティシャル広告ロード
        }
        // iPadでもiPhoneと同様に全画面表示させるためのスタイル設定
        .navigationViewStyle(StackNavigationViewStyle())
        // ナビゲーションバーのタイトル表示モードを設定
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    inputText = ""
                    letter_counter = ""
                    Arr.removeAll()
                }){
                    HStack {
                        Image(systemName: "eraser.line.dashed")
                        Text("Erase")
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                // 保存ボタン
                Button(action: {saveMemo()}){
                    HStack {
                        Image(systemName: "folder.badge.plus")
                        Text("Save")
                    }
                }
            }
        }
    } // bodyここまで

    private func TimerSection() -> some View {
        HStack {
            Text(secondsToMinutesAndSeconds(seconds: timerManager.secondsLeft))
                .font(.system(size: 20))

            Image(systemName: timerManager.timerMode == .running ? "pause.circle.fill" : "play.circle.fill")
                .foregroundColor(.red)
                .onTapGesture(perform: {
                    timerManager.timerMode == .running ?
                    timerManager.pause() :
                    timerManager.start()
                })

            if timerManager.timerMode == .paused {
                Image(systemName: "gobackward")
                    .onTapGesture(perform: {
                        timerManager.reset()
                    })
            }
        }
    }

    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Text("Chars：\(Chars_num)  ")
            Text("Words：\(Words_num)")
            Spacer()
            Button("Done") {
                isActive = false
            }
        }
    }

    private func updateCounts() {
        withAnimation(.none) {
            let str = inputText.removeWhitespacesAndNewlines
            let arr = str.components(separatedBy: CharacterSet(charactersIn: " ,.。？?！!\n"))
            let filteredArr = arr.filter { $0 != "" }
            Chars_num = str.count
            Words_num = filteredArr.count
        }
    }

    private func CountView(title: String, value: String, height: CGFloat) -> some View {
        VStack {
            Text("\(title)：\(value)").padding()
            if title == "Chars" {
                Text("(Space not included)")
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.45,
               height: UIScreen.main.bounds.height * height,
               alignment: .center)
        .overlay(RoundedRectangle(cornerRadius: 10)
            .stroke(Color.blue, lineWidth: 2)
        )
    }

    // メモを保存する関数
    private func saveMemo() {
        memo.title = title // タイトルを更新
        memo.content = inputText // 内容を更新
        memo.updatedAt = Date() // 更新日時を設定
        memo.timerFlag = TimerFlag
        memo.charsNum = Int32(Chars_num)
        memo.wordsNum = Int32(Words_num)
        // データを保存（エラーが発生してもクラッシュしないように）
        do {
            try viewContext.save()
            // 保存が完了したら遷移元のビューを閉じる
            presentationMode.wrappedValue.dismiss()
        } catch {
            // エラー処理
            print("Failed to save memo: \(error)")
        }
    }

    private func ScoringButton() -> some View {
        Button(action: {
            print("Scoring Button tapped")
            print(str)
            str_advice = ""
            Task {
                await viewModel.askChatGPT2(text: inputText)
            }
        }) {
            Text("Scoring", comment: "ローカライズ")
                .fontWeight(.semibold)
                .frame(width: 160, height: 48)
                .foregroundColor(Color.primary)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(.green), lineWidth: 2)
                )
        }
        .padding(.all)
    }

    private func AdviceView() -> some View {
        ScrollView {
            Text(str_advice)
                .padding(10)
        }
        .padding(.all)
        .frame(height: UIScreen.main.bounds.height * 0.5)
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .overlay(RoundedRectangle(cornerRadius: 10)
            .stroke(Color.green, lineWidth: 2)
        )
        .onChange(of: viewModel.messages) { _ in
            str_advice = viewModel.messages
                .filter { $0.role == .assistant }
                .map { $0.content }
                .joined(separator: "\n")
            // Check if new messages contain any content
            if !str_advice.isEmpty {
                // Display interstitial ad when new messages are received
                interstitial.ShowInterstitial()
            }
        }
        .textSelection(.enabled)
        .padding(.vertical)
    }

}

// プレビュー用の構造体
struct EditMemoView_Previews: PreviewProvider {
    static var previews: some View {
        // ダミーのメモを渡してプレビューを表示
        EditMemoView(memo: Memo())
    }
}


extension UIApplication {
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension String {
    var removeWhitespacesAndNewlines: String {
        self.filter { !$0.isWhitespace && !$0.isNewline }
    }
}
