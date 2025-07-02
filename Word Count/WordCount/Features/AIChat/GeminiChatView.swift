import SwiftUI

struct GeminiChatView: View {
    @ObservedObject var viewModel: GeminiChatViewModel
    @State private var inputText = ""
    @FocusState private var isTextFieldFocused: Bool
    @AppStorage("message_counter") var messageCounter = 0
    //@StateObject private var interstitialAd = Interstitial()
    @FocusState private var isKeyboardActive: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    // メッセージ表示エリア
                    messageListView
                    
                    Spacer()
                    
                    // 入力エリア
                    messageInputArea
                }
                .padding(.init(
                    top: geometry.safeAreaInsets.top + 10,
                    leading: 20,
                    bottom: geometry.safeAreaInsets.bottom + 10,
                    trailing: 20
                ))
                .onTapGesture {
                    isTextFieldFocused.toggle()
                }
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea(.keyboard, edges: .bottom)
                
                // ローディング表示
                if viewModel.isProcessing {
                    loadingOverlay
                }
            }
        }
        .navigationTitle("AI Chat")
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("確認"),
                message: Text(viewModel.errorMessage)
            )
        }
        //        .onAppear {
        //            interstitialAd.LoadInterstitial()
        //        }
    }
    
    // MARK: - メッセージリスト表示
    private var messageListView: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                ForEach(viewModel.messages, id: \.self) { message in
                    MessageBubbleView(message: message)
                }
                
                Color.clear
                    .padding(.bottom, 60)
                    .id("bottom")
            }
            .onChange(of: viewModel.messages) { _ in
                withAnimation {
                    scrollProxy.scrollTo("bottom")
                }
            }
        }
    }
    
    // MARK: - メッセージ入力エリア
    private var messageInputArea: some View {
        HStack {
            Image(systemName: "cpu")
                .font(.title2)
                .foregroundColor(.blue)
            
            ZStack(alignment: .leading) {
                TextEditor(text: $inputText)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.gray, lineWidth: 1)
                    )
                    .frame(height: 60)
                    .border(Color.blue, width: 1)
                    .focused($isKeyboardActive)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("完了") {
                                isKeyboardActive = false
                            }
                        }
                    }
                
                if inputText.isEmpty {
                    Text("メッセージを入力してください")
                        .foregroundColor(Color(uiColor: .placeholderText))
                        .allowsHitTesting(false)
                        .padding(20)
                        .padding(.top, 5)
                }
            }
            
            Button {
                sendMessage()
            } label: {
                Image(systemName: "paperplane")
                    .foregroundColor(.blue)
                    .font(.title2)
            }
        }
    }
    
    // MARK: - ローディング表示
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            LoadingIndicatorView()
        }
    }
    
    // MARK: - メッセージ送信処理
    private func sendMessage() {
        isTextFieldFocused = false
        viewModel.sendMessage(text: inputText)
        messageCounter += 1
        
        //        if messageCounter >= 4 {
        //            interstitialAd.ShowInterstitial()
        //            messageCounter = 0
        //        }
        
        inputText = ""
    }
}

// MARK: - メッセージバブル表示
struct MessageBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        let borderColor: Color = message.role == .user ? Color.mint : Color.orange
        
        Text(message.content)
            .padding(10)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(borderColor, lineWidth: 2)
            )
            .font(.title3)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - ローディングインジケーター
struct LoadingIndicatorView: UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<LoadingIndicatorView>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: .large)
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<LoadingIndicatorView>) {
        uiView.startAnimating()
    }
}
