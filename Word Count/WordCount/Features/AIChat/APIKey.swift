import Foundation

enum APIKey {
    static var `default`: String {
        // 暗号化されたCredentialsから取得
        guard let apiKey = CREDENTIALS.shared.geminiAPIKey else {
            fatalError("❌ 暗号化されたAPI KEYの取得に失敗しました。Credentials.swiftの設定を確認してください。")
        }        
        return apiKey
    }
}
