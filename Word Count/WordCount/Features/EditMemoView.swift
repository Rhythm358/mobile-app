import SwiftUI
import AVFoundation

// MARK: - EditMemoView
struct EditMemoView: View {
    // MARK: - Properties
    @ObservedObject var viewModel = GeminiChatViewModel()
    //@ObservedObject var interstitial = Interstitial()
    
    private var memo: Memo
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - State Variables
    @State private var title: String
    @State private var inputText: String
    @State private var Chars_num: Int
    @State private var Words_num: Int
    @State private var str = ""
    @State private var letter_counter = ""
    @State private var orientation = UIDevice.current.orientation
    @State private var arr: [String] = []
    @State private var Arr: [String] = []
    @State private var textEditorHeight: CGFloat = UIScreen.main.bounds.height * 0.7
    
    // MARK: - Speech Synthesis
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @State private var isSpeaking = false
    
    // MARK: - AI Function
    @State private var selectedAIFunction: AIFunctionType = .scoring
    @State private var showFunctionPicker = false
    @AppStorage("str_advice") var str_advice = ""
    @AppStorage("TimerFlag") var TimerFlag = false
    
    // MARK: - Focus & Timer
    @FocusState var isActive: Bool
    @StateObject var timerManager = TimerManager()
    
    // ポイント管理とリワード広告を追加
    @StateObject private var pointManager = PointManager()
    @StateObject private var rewardedAdManager = RewardedAdManager()
    @State private var showPointsAlert = false
    
    @State private var showSaveSuccessAlert = false
    @State private var showSaveErrorAlert = false
    @State private var showNoChangesAlert = false
    @State private var saveErrorMessage = ""
    
    @State private var saveToastMessage = ""
    @State private var showSaveToast = false
    @State private var saveToastColor = Color.green
    
    
    // AI機能利用に必要なポイント数
    private let aiCostPoints = 1
    
    // MARK: - Notification
    let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
        .makeConnectable()
        .autoconnect()
    
    // MARK: - Initializer
    init(memo: Memo) {
        self.memo = memo
        self._title = State(initialValue: memo.title ?? "")
        self._inputText = State(initialValue: memo.content ?? "")
        self._Chars_num = State(initialValue: Int(memo.charsNum))
        self._Words_num = State(initialValue: Int(memo.wordsNum))
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                // メインコンテンツ
                GeometryReader { geometry in
                    let frameWidth = geometry.size.width * 0.9
                    let frameHeight = geometry.size.height * 0.9
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Title Input
                            titleSection
                            
                            // Main Content Area
                            contentSection(frameWidth: frameWidth, frameHeight: frameHeight)
                            
                            // Statistics and Controls
                            statisticsSection
                            
                            // AI Functions
                            aiFunctionSection
                            
                            // Loading Indicator
                            if viewModel.isProcessing {
                                loadingOverlay
                            }
                            
                            // Advice Display
                            adviceSection
                            
                        }
                    }
                    .background(backgroundGradient)
                }
            }
            .onReceive(orientationChanged) { _ in
                self.orientation = UIDevice.current.orientation
            }
            .onTapGesture {
                UIApplication.shared.closeKeyboard()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(StackNavigationViewStyle())
            .toolbarRole(.editor)
            .toolbar {
                // 上部ツールバー
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ClockView()) {
                        Image(systemName: "clock")
                            .foregroundColor(.blue)
                    }
                    
                    speechButton
                    
                    saveButton
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    // ナビゲーションバーにポイント表示
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String.localizedStringWithFormat(
                            NSLocalizedString("Points: %d", comment: "Points display"),
                            pointManager.currentPoints
                        ))
                        .font(.caption)
                        .fontWeight(.semibold)
                    }
                }
            }
            // アラート追加
            .overlay(
                // 保存トースト
                VStack {
                    if showSaveToast {
                        HStack {
                            Image(systemName: saveToastColor == .green ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .foregroundColor(saveToastColor)
                            
                            Text(saveToastMessage)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    Spacer()
                }
                    .padding(.top, 60)
                , alignment: .top
            )
            .alert(NSLocalizedString("保存完了", comment: "Save success alert title"), isPresented: $showSaveSuccessAlert) {
                Button(NSLocalizedString("OK", comment: "OK button")) { }
            } message: {
                Text(NSLocalizedString("メモが正常に保存されました", comment: "Save success message"))
            }
            
            .alert(NSLocalizedString("保存エラー", comment: "Save error alert title"), isPresented: $showSaveErrorAlert) {
                Button(NSLocalizedString("OK", comment: "OK button")) { }
            } message: {
                Text(NSLocalizedString("メモの保存に失敗しました", comment: "Save error message") + ": \(saveErrorMessage)")
            }
            
            .alert(NSLocalizedString("変更なし", comment: "No changes alert title"), isPresented: $showNoChangesAlert) {
                Button(NSLocalizedString("OK", comment: "OK button")) { }
            } message: {
                Text(NSLocalizedString("変更がないため保存をスキップしました", comment: "No changes message"))
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Properties
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.blue.opacity(0.05),
                Color(.systemBackground),
                Color(.systemBackground),
                Color.blue.opacity(0.08)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // ポイント表示セクション
    private var pointsDisplaySection: some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
            Text("ポイント: \(pointManager.currentPoints)")
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: {
                watchAdForPoints()
            }) {
                HStack {
                    Image(systemName: "play.rectangle.fill")
                        .foregroundColor(.blue)
                    Text("広告を見る (+5)")
                        .font(.caption)
                }
            }
            .disabled(rewardedAdManager.isShowingAd || !rewardedAdManager.isAdLoaded)
            // ポイント不足アラート
            .alert(NSLocalizedString("ポイントが不足しています", comment: "Insufficient points alert"), isPresented: $showPointsAlert) {
                Button(NSLocalizedString("広告を見る", comment: "Watch ad button")) {
                    watchAdForPoints()
                }
                Button(NSLocalizedString("キャンセル", comment: "Cancel button")) { }
            } message: {
                Text(String.localizedStringWithFormat(
                    NSLocalizedString("AI機能を使用するには%dポイント必要です。動画広告を見ると5ポイントもらえます。", comment: "Points needed message"),
                    aiCostPoints
                ))
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    // AI機能セクション（ポイント表示統合版）
    private var aiFunctionSection: some View {
        VStack(spacing: 15) {
            // ポイント状況とリワード広告ボタン
            HStack {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String.localizedStringWithFormat(
                        NSLocalizedString("Points: %d", comment: "Points display"),
                        pointManager.currentPoints
                    ))
                    .font(.subheadline)
                    .fontWeight(.medium)
                }
                
                Spacer()
                
                Button(action: {
                    watchAdForPoints()
                }) {
                    HStack {
                        Image(systemName: "play.rectangle.fill")
                            .foregroundColor(.blue)
                        Text(NSLocalizedString("Watch Ad (+5)", comment: "Watch ad button"))
                            .font(.caption)
                    }
                }
                .disabled(rewardedAdManager.isShowingAd || !rewardedAdManager.isAdLoaded)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            AIFunctionSelector()
            
            Button(action: {
                executeAIFunction()
            }) {
                HStack {
                    Image(systemName: "cpu.fill")
                        .foregroundColor(.white)
                    Text(String.localizedStringWithFormat(
                        NSLocalizedString("AI分析を実行 (-%dポイント)", comment: "AI execution button"),
                        aiCostPoints
                    ))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            .disabled(inputText.isEmpty || viewModel.isProcessing || !pointManager.hasEnoughPoints(aiCostPoints))
            .opacity(inputText.isEmpty || !pointManager.hasEnoughPoints(aiCostPoints) ? 0.6 : 1.0)
        }
        .padding(.horizontal)
    }
    
    private func showSaveToast(_ message: String, color: Color) {
        saveToastMessage = message
        saveToastColor = color
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            showSaveToast = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                showSaveToast = false
            }
        }
    }
    
    
    // MARK: - View Components
    private var titleSection: some View {
        TextField(NSLocalizedString("Title", comment: "Title placeholder"), text: $title)
            .font(.title)
            .multilineTextAlignment(.center)
    }
    
    private func contentSection(frameWidth: CGFloat, frameHeight: CGFloat) -> some View {
        VStack {
            if TimerFlag {
                TimerSection()
            }
            
            Spacer()
            
            TextEditor(text: $inputText)
                .focused($isActive)
                .toolbar { toolbarContent }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 1)
                )
                .onReceive(NotificationCenter.default.publisher(for: UITextView.textDidChangeNotification)) { _ in
                    updateCounts()
                }
        }
        .frame(width: frameWidth, height: frameHeight)
        .onReceive(orientationChanged) { _ in
            self.orientation = UIDevice.current.orientation
        }
    }
    
    private var statisticsSection: some View {
        HStack {
            CountView(title: "Chars", value: "\(Chars_num)", height: 0.15)
            CountView(title: "Words", value: "\(Words_num)", height: 0.15)
        }
        .padding(.all)
    }
    
    // AI機能実行処理
    private func executeAIFunction() {
        // ポイントが足りるかチェック
        if !pointManager.hasEnoughPoints(aiCostPoints) {
            showPointsAlert = true
            return
        }
        
        // ポイントを消費
        if pointManager.consumePoints(aiCostPoints) {
            print("AI Function Button tapped: \(selectedAIFunction.rawValue)")
            str_advice = ""
            Task {
                await viewModel.sendMessageWithFunction(text: inputText, functionType: selectedAIFunction)
            }
        }
    }
    
    // 広告視聴でポイント獲得
    private func watchAdForPoints() {
        rewardedAdManager.showRewardedAd { success in
            if success {
                DispatchQueue.main.async {
                    self.pointManager.addPoints(5) // ← ここで5ポイント付与
                    print("ユーザーが5ポイントを獲得しました")
                }
            }
        }
    }
    
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            ActivityIndicator()
        }
        .animation(.easeInOut, value: viewModel.isProcessing)
    }
    
    private var adviceSection: some View {
        AdviceView()
    }
    
    private var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ClockView()) {
                    Image(systemName: "clock")
                        .foregroundColor(.blue)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                speechButton
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                saveButton
            }
        }
    }
    
    private var speechButton: some View {
        Button(action: {
            if isSpeaking {
                stopSpeech()
            } else {
                speakText()
            }
        }) {
            HStack {
                Image(systemName: isSpeaking ? "speaker.slash.fill" : "speaker.2.fill")
                    .foregroundColor(isSpeaking ? .red : .blue)
                Text(NSLocalizedString("Speak", comment: "Speech button"))
            }
        }
        .disabled(inputText.isEmpty)
    }
    
    private var saveButton: some View {
        Button(action: { saveMemo() }) {
            HStack {
                Image(systemName: "folder.badge.plus")
                Text(NSLocalizedString("Save", comment: "Save button"))
            }
        }
    }
}

// MARK: - Timer Section
extension EditMemoView {
    private func TimerSection() -> some View {
        VStack {
            HStack {
                Text(secondsToMinutesAndSeconds(seconds: timerManager.secondsLeft))
                    .font(.system(size: 20))
                
                Image(systemName: timerManager.timerMode == .running ? "pause.circle.fill" : "play.circle.fill")
                    .foregroundColor(.red)
                    .onTapGesture {
                        timerManager.timerMode == .running ?
                        timerManager.pause() :
                        timerManager.start()
                    }
                
                if timerManager.timerMode == .paused {
                    Image(systemName: "gobackward")
                        .onTapGesture {
                            timerManager.reset()
                        }
                }
            }
        }
    }
}

// MARK: - Toolbar Content
extension EditMemoView {
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Text(String.localizedStringWithFormat(
                NSLocalizedString("chars_count", comment: "Character count display"),
                Chars_num
            ))
            Text(String.localizedStringWithFormat(
                NSLocalizedString("words_count", comment: "Word count display"),
                Words_num
            ))
            Spacer()
            Button(NSLocalizedString("Done", comment: "Done button")) {
                isActive = false
            }
        }
    }
}

// MARK: - Helper Functions
extension EditMemoView {
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
            if title == "Chars" {
                Text(String.localizedStringWithFormat(
                    NSLocalizedString("chars_count", comment: "Character count display"),
                    Int(value) ?? 0
                ))
                .padding()
                Text(NSLocalizedString("(Space not included)", comment: "Character count explanation"))
            } else if title == "Words" {
                Text(String.localizedStringWithFormat(
                    NSLocalizedString("words_count", comment: "Word count display"),
                    Int(value) ?? 0
                ))
                .padding()
            }
        }
        .frame(
            width: UIScreen.main.bounds.width * 0.45,
            height: UIScreen.main.bounds.height * height,
            alignment: .center
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.blue, lineWidth: 2)
        )
    }
    
    private func secondsToMinutesAndSeconds(seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Speech Functions
extension EditMemoView {
    private func speakText() {
        guard !inputText.isEmpty else { return }
        
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: inputText)
        
        // Language Detection
        if inputText.range(of: "[ひらがなカタカナ漢字]", options: .regularExpression) != nil {
            utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP") ??
            AVSpeechSynthesisVoice.speechVoices().first
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US") ??
            AVSpeechSynthesisVoice.speechVoices().first
        }
        
        // Speech Settings
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.8
        utterance.volume = 0.8
        utterance.pitchMultiplier = 1.0
        
        DispatchQueue.main.async {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
                try AVAudioSession.sharedInstance().setActive(true)
                self.speechSynthesizer.speak(utterance)
                self.isSpeaking = true
            } catch {
                print("音声読み上げの設定に失敗しました: \(error)")
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.checkSpeechStatus()
        }
    }
    
    private func stopSpeech() {
        speechSynthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }
    
    private func checkSpeechStatus() {
        if !speechSynthesizer.isSpeaking {
            isSpeaking = false
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                checkSpeechStatus()
            }
        }
    }
}

// MARK: - Data Management
extension EditMemoView {
    
    private func saveMemo() {
        memo.title = title
        memo.content = inputText
        memo.updatedAt = Date()
        memo.timerFlag = TimerFlag
        memo.charsNum = Int32(Chars_num)
        memo.wordsNum = Int32(Words_num)
        
        do {
            if viewContext.hasChanges {
                try viewContext.save()
                print("✅ メモが正常に保存されました")
                
                // 画面遷移を削除し、成功アラートのみ表示
                DispatchQueue.main.async {
                    self.viewContext.refreshAllObjects()
                    self.showSaveSuccessAlert = true
                }
            } else {
                // 変更がない場合（画面遷移なし）
                print("📝 変更がないため保存をスキップしました")
                showNoChangesAlert = true
            }
        } catch {
            print("❌ メモの保存に失敗しました: \(error)")
            saveErrorMessage = error.localizedDescription
            showSaveErrorAlert = true
        }
    }
}

// MARK: - AI Functions
extension EditMemoView {
    private func ScoringButton() -> some View {
        Button(action: {
            print("AI Function Button tapped: \(selectedAIFunction.rawValue)")
            str_advice = ""
            Task {
                await viewModel.sendMessageWithFunction(text: inputText, functionType: selectedAIFunction)
            }
        }) {
            Text(NSLocalizedString("実行", comment: "Execute button"))
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
    
    private func AIFunctionSelector() -> some View {
        VStack(spacing: 10) {
            // Function Selection Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showFunctionPicker.toggle()
                }
            }) {
                HStack {
                    Text(selectedAIFunction.localizedTitle)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: showFunctionPicker ? "chevron.up" : "chevron.down")
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(showFunctionPicker ? 180 : 0))
                        .animation(.easeInOut(duration: 0.3), value: showFunctionPicker)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 1)
                )
            }
            
            // Function Picker Dropdown
            if showFunctionPicker {
                functionPickerView
            }
        }
        .padding(.horizontal)
    }
    
    private var functionPickerView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(AIFunctionType.allCases, id: \.self) { function in
                    Button(action: {
                        selectedAIFunction = function
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showFunctionPicker = false
                        }
                    }) {
                        HStack {
                            Text(function.localizedTitle)
                                .font(.system(size: 15))
                                .foregroundColor(.primary)
                            Spacer()
                            if selectedAIFunction == function {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            selectedAIFunction == function ?
                            Color.blue.opacity(0.1) : Color.clear
                        )
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(maxHeight: 250)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
    
    private func AdviceView() -> some View {
        SelectableTextView(text: str_advice)
            .frame(
                minHeight: UIScreen.main.bounds.height * 0.65,
                maxHeight: UIScreen.main.bounds.height * 0.85
            )
            .frame(width: UIScreen.main.bounds.width * 0.9)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.green, lineWidth: 2)
            )
            .onChange(of: viewModel.messages) { _ in
                str_advice = viewModel.messages
                    .filter { $0.role == .assistant }
                    .map { $0.content }
                    .joined(separator: "\n")
                // インタースティシャル広告の表示をコメントアウト
                // if !str_advice.isEmpty {
                //     interstitial.ShowInterstitial()
                // }
            }
            .padding(.vertical)
    }
    
}


// MARK: - Preview
struct EditMemoView_Previews: PreviewProvider {
    static var previews: some View {
        EditMemoView(memo: createDummyMemo())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
    
    static func createDummyMemo() -> Memo {
        let context = PersistenceController.preview.container.viewContext
        let memo = Memo(context: context)
        memo.title = "Sample Title"
        memo.content = "Sample Content"
        memo.updatedAt = Date()
        return memo
    }
}

// MARK: - Extensions
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

// MARK: - ActivityIndicator
struct ActivityIndicator: UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: .large)
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        uiView.startAnimating()
    }
}

// MARK: - SelectableTextView
struct SelectableTextView: UIViewRepresentable {
    let text: String
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = true
        textView.backgroundColor = UIColor.clear
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = UIColor.label
        textView.showsVerticalScrollIndicator = true
        textView.showsHorizontalScrollIndicator = false
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
}
