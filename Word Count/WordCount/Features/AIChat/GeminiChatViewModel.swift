import Foundation
import SwiftUI
import GoogleGenerativeAI

// MARK: - AI機能タイプ定義
enum AIFunctionType: String, CaseIterable {
    case scoring = "📊 AI採点・評価"
    case brushUp = "✨ 文章ブラッシュアップ"
    case grammarCheck = "🎯 文法チェック＆修正"
    case expressionImprovement = "💡 表現力向上提案"
    case nativeRewrite = "🌟 ネイティブ風リライト"
    case testPrep = "📝 TOEIC/IELTS対策添削"
    case wordCount = "📊 詳細文字数分析"
    case readability = "📖 読みやすさ分析"
    
    // 多言語化対応のプロパティを追加
    var localizedTitle: String {
        return NSLocalizedString(self.rawValue, comment: "AI Function Type")
    }
    
    var prompt: String {
        let currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        
        switch self {
        case .scoring:
            if currentLanguage == "ja" {
                return """
            あなたは経験豊富な英語教師です。以下の英文を総合的に評価し、採点してください。
            【評価項目】
            1. 文法の正確性（25点満点）
            2. 語彙の適切性（25点満点）
            3. 文章構成・論理性（25点満点）
            4. 表現の自然さ（25点満点）
            
            【出力形式】
            - 総合点：XX/100点
            - 各項目の詳細評価
            - 良い点を3つ
            - 改善すべき点を3つ
            - 具体的な修正提案
            
            評価対象の英文：
            """
            } else {
                return """
            You are an experienced English teacher. Please evaluate and score the following English text comprehensively.
            
            【Evaluation Criteria】
            1. Grammar accuracy (25 points)
            2. Vocabulary appropriateness (25 points)
            3. Text structure and logic (25 points)
            4. Expression naturalness (25 points)
            
            【Output Format】
            - Overall score: XX/100 points
            - Detailed evaluation for each criterion
            - Three good points
            - Three areas for improvement
            - Specific revision suggestions
            
            Text to evaluate:
            """
            }
            
        case .brushUp:
            if currentLanguage == "ja" {
                return """
            あなたはプロの文章校正者です。以下の文章をより洗練された表現にブラッシュアップしてください。
            
            【改善方針】
            - より自然で流暢な表現に変更
            - 冗長な部分の簡潔化
            - より適切な語彙の選択
            - 文章のリズムと読みやすさの向上
            
            【出力形式】
            1. 改善後の文章（全文）
            2. 主な変更点の説明
            3. 改善理由の詳細
            
            対象文章：
            """
            } else {
                return """
            You are a professional text editor. Please brush up the following text to make it more refined.
            
            【Improvement Guidelines】
            - Change to more natural and fluent expressions
            - Simplify redundant parts
            - Choose more appropriate vocabulary
            - Improve text rhythm and readability
            
            【Output Format】
            1. Improved text (complete version)
            2. Explanation of main changes
            3. Detailed reasons for improvements
            
            Target text:
            """
            }
            
        case .grammarCheck:
            if currentLanguage == "ja" {
                return """
            あなたは文法専門の校正者です。以下の文章の文法エラーを徹底的にチェックし、修正してください。
            
            【チェック項目】
            - 時制の一致
            - 主語と動詞の一致
            - 冠詞の使い方
            - 前置詞の選択
            - 語順の正確性
            - 句読点の使用
            
            【出力形式】
            1. 修正後の文章
            2. 発見されたエラーの一覧（元の表現 → 修正後）
            3. 各修正の文法的説明
            
            チェック対象文章：
            """
            } else {
                return """
            You are a grammar specialist proofreader. Please thoroughly check and correct grammar errors in the following text.
            
            【Check Items】
            - Tense consistency
            - Subject-verb agreement
            - Article usage
            - Preposition selection
            - Word order accuracy
            - Punctuation usage
            
            【Output Format】
            1. Corrected text
            2. List of found errors (original → corrected)
            3. Grammatical explanation for each correction
            
            Text to check:
            """
            }
            
        case .expressionImprovement:
            if currentLanguage == "ja" {
                return """
            あなたは表現力向上の専門家です。以下の文章の表現力を高める具体的な提案をしてください。
            
            【改善観点】
            - より豊かな語彙の使用
            - 感情や意図がより伝わる表現
            - 読み手を引きつける文章構成
            - 具体性と説得力の向上
            
            【出力形式】
            1. 表現力向上版の文章
            2. 使用した表現技法の説明
            3. さらなる改善のためのアドバイス
            
            対象文章：
            """
            } else {
                return """
            You are an expert in expression improvement. Please provide specific suggestions to enhance the expressiveness of the following text.
            
            【Improvement Perspectives】
            - Use of richer vocabulary
            - Expressions that better convey emotions and intentions
            - Text structure that attracts readers
            - Improvement of specificity and persuasiveness
            
            【Output Format】
            1. Expression-enhanced version of the text
            2. Explanation of expression techniques used
            3. Advice for further improvement
            
            Target text:
            """
            }
            
        case .nativeRewrite:
            if currentLanguage == "ja" {
                return """
            あなたはネイティブスピーカーの英語ライターです。以下の文章をネイティブが書いたような自然な英語に書き直してください。
            
            【リライト方針】
            - ネイティブが使う自然な表現への変更
            - 文化的なニュアンスの調整
            - より自然な語順と文構造
            - 適切なイディオムや慣用表現の使用
            
            【出力形式】
            1. ネイティブ風リライト版
            2. 主要な変更点の説明
            3. ネイティブらしさのポイント解説
            
            リライト対象文章：
            """
            } else {
                return """
            You are a native English speaker and writer. Please rewrite the following text to sound like it was written by a native English speaker.
            
            【Rewriting Guidelines】
            - Change to natural expressions used by native speakers
            - Adjust cultural nuances
            - Use more natural word order and sentence structure
            - Incorporate appropriate idioms and common expressions
            
            【Output Format】
            1. Native-style rewritten version
            2. Explanation of major changes
            3. Commentary on native-like characteristics
            
            Text to rewrite:
            """
            }
            
        case .testPrep:
            if currentLanguage == "ja" {
                return """
            あなたはTOEIC・IELTS対策の専門講師です。以下の文章を試験対策の観点から添削してください。
            
            【添削観点】
            - 試験で高得点を取るための表現
            - アカデミックライティングの要件
            - 論理的構成と一貫性
            - 適切な語彙レベルと多様性
            
            【出力形式】
            1. 試験対策版の改善文章
            2. 得点向上のポイント
            3. 試験で評価される表現技法
            4. さらなる学習アドバイス
            
            添削対象文章：
            """
            } else {
                return """
            You are a specialist instructor for TOEIC and IELTS preparation. Please review the following text from a test preparation perspective.
            
            【Review Perspectives】
            - Expressions for achieving high scores on tests
            - Academic writing requirements
            - Logical structure and consistency
            - Appropriate vocabulary level and variety
            
            【Output Format】
            1. Test-preparation improved version
            2. Points for score improvement
            3. Expression techniques evaluated in tests
            4. Further study advice
            
            Text to review:
            """
            }
            
        case .wordCount:
            if currentLanguage == "ja" {
                return """
            あなたは文章分析の専門家です。以下の文章を詳細に分析してください。
            
            【分析項目】
            - 文字数・単語数の詳細内訳
            - 文の長さの分布
            - 語彙の多様性（異なる単語の使用率）
            - 文章の複雑さレベル
            - 読解難易度の評価
            
            【出力形式】
            1. 基本統計情報
            2. 文章構造の分析
            3. 語彙使用の特徴
            4. 改善提案（必要に応じて）
            
            分析対象文章：
            """
            } else {
                return """
            You are a text analysis specialist. Please analyze the following text in detail.
            
            【Analysis Items】
            - Detailed breakdown of character and word counts
            - Distribution of sentence lengths
            - Vocabulary diversity (usage rate of different words)
            - Text complexity level
            - Reading difficulty assessment
            
            【Output Format】
            1. Basic statistical information
            2. Text structure analysis
            3. Vocabulary usage characteristics
            4. Improvement suggestions (if needed)
            
            Text to analyze:
            """
            }
            
        case .readability:
            if currentLanguage == "ja" {
                return """
            あなたは読みやすさ分析の専門家です。以下の文章の読みやすさを多角的に評価してください。
            
            【評価項目】
            - 文の長さと複雑さ
            - 語彙の難易度
            - 文章の流れと論理性
            - 読み手への配慮
            - 情報の整理と構成
            
            【出力形式】
            1. 読みやすさスコア（10点満点）
            2. 各評価項目の詳細分析
            3. 読みやすさを向上させる具体的提案
            4. 対象読者層の推定
            
            評価対象文章：
            """
            } else {
                return """
            You are a readability analysis specialist. Please evaluate the readability of the following text from multiple perspectives.
            
            【Evaluation Items】
            - Sentence length and complexity
            - Vocabulary difficulty level
            - Text flow and logic
            - Consideration for readers
            - Information organization and structure
            
            【Output Format】
            1. Readability score (out of 10 points)
            2. Detailed analysis of each evaluation item
            3. Specific suggestions to improve readability
            4. Estimated target audience
            
            Text to evaluate:
            """
            }
        }
    }
    
    
}

// MARK: - チャットメッセージ構造体
struct ChatMessage: Hashable {
    var content: String
    var role: MessageRole
    
    enum MessageRole: String {
        case system = "system"
        case user = "user"
        case assistant = "assistant"
    }
}

// MARK: - ViewModel プロトコル
protocol GeminiChatViewModelProtocol: ObservableObject {
    var messages: [ChatMessage] { get }
    var isProcessing: Bool { get }
    var showAlert: Bool { get set }
    var errorMessage: String { get }
    func sendMessage(text: String)
}

// MARK: - Gemini チャット ViewModel
@MainActor
final class GeminiChatViewModel: ObservableObject {
    @Published public var messages: [ChatMessage] = []
    @Published public var isProcessing: Bool = false
    @Published public var errorMessage: String = ""
    @Published public var showAlert = false
    
    private let geminiModel: GenerativeModel
    
    init() {
        // 暗号化されたCredentialsからAPI KEYを取得
        let apiKey = APIKey.default
        self.geminiModel = GenerativeModel(name: "gemini-1.5-flash", apiKey: apiKey)
        
        print("✅ GeminiChatViewModel が暗号化されたAPI KEYで初期化されました")
    }
    
    // MARK: - 基本メッセージ送信
    public func sendMessage(text: String) {
        guard !text.isEmpty else { return }
        isProcessing = true
        addMessage(text: text, role: .user)
        Task {
            await performGeminiRequest(text: text)
        }
    }
    
    // MARK: - 機能付きメッセージ送信
    public func sendMessageWithFunction(text: String, functionType: AIFunctionType = .scoring) async {
        guard !text.isEmpty else { return }
        isProcessing = true
        clearMessages()
        addMessage(text: text, role: .user)
        await performGeminiRequest(text: text, functionType: functionType)
    }
    
    // MARK: - メッセージクリア
    public func clearMessages() {
        messages = []
    }
    
    // MARK: - 成功時の処理
    private func handleSuccess(text: String) {
        addMessage(text: text, role: .assistant)
        isProcessing = false
    }
    
    // MARK: - エラー時の処理
    private func handleError(error: String) {
        errorMessage = error
        showAlert = true
        isProcessing = false
    }
    
    // MARK: - メッセージ追加
    private func addMessage(text: String, role: ChatMessage.MessageRole) {
        messages.append(.init(content: text, role: role))
    }
}

// MARK: - Gemini API通信処理
extension GeminiChatViewModel {
    private func performGeminiRequest(text: String, functionType: AIFunctionType = .scoring, retryCount: Int = 0) async {
        let fullPrompt = "\(functionType.prompt)\n\nユーザーの入力:\n\(text)"
        
        do {
            let response = try await geminiModel.generateContent(fullPrompt)
            if let responseText = response.text, !responseText.isEmpty {
                await MainActor.run {
                    handleSuccess(text: responseText)
                }
            } else {
                await MainActor.run {
                    handleError(error: "Geminiからの応答が空でした")
                }
            }
        } catch {
            // リトライ処理
            if retryCount < 2 {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                await performGeminiRequest(text: text, functionType: functionType, retryCount: retryCount + 1)
            } else {
                await MainActor.run {
                    handleError(error: "APIリクエストに失敗しました: \(error.localizedDescription)")
                }
            }
        }
    }
}
