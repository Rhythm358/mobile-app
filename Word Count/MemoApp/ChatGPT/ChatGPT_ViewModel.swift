//
//  ViewModel.swift
//  ChatGPTAPISample
//


import Foundation
import SwiftUI
import Alamofire //HTTPネットワーキングライブラリ

struct Message: Hashable {
    var content: String
    var role: Role
    
    enum Role: String {
        case system = "system"
        case user = "user"
        case assistant = "assistant"
    }
}

protocol ViewModelProtocol:ObservableObject {
    var messages: [Message] { get }
    var isAsking: Bool { get }
    var showAlert: Bool { get set }
    var errorText: String { get }
    func askChatGPT(text: String)
}


final class ViewModel: ViewModelProtocol {
    @Published public var messages: [Message] = []
    @Published public var isAsking: Bool = false
    @Published public var errorText: String = ""
    @Published public var showAlert = false

    private let token = ""
    private let setting: Message? = {
        // Localizable.stringsファイルからプロンプトメッセージを取得
        let messageContent = Bundle.main.localizedString(forKey: "MessageContentKey", value: nil, table: nil)
        if !messageContent.isEmpty {
            return Message(content: messageContent, role: .system)
        } else {
            return nil
        }
    }()

    public func askChatGPT(text: String) {
        if text.isEmpty { return }
        isAsking = true
        add(text: text, role: .user)
    }

    public func askChatGPT2(text: String) async {
        if text.isEmpty { return }
        isAsking = true
        resetMessages() // メッセージを初期化
        add(text: text, role: .user)
        await send(text: text)
    }

    public func resetMessages() {
        DispatchQueue.main.async {
            self.messages = []
        }
    }

    private func responseSuccess(data: ChatGPTResponse) {
        guard let message = data.choices.first?.message else { return }
        DispatchQueue.main.async {
            self.add(text: message.content, role: .assistant)
            self.isAsking = false
        }
    }

    private func responseFailure(error: String) {
        DispatchQueue.main.async {
            self.errorText = error
            self.showAlert = true
            self.isAsking = false
        }
    }

    private func add(text: String, role: Message.Role) {
        DispatchQueue.main.async {
            self.messages.append(.init(content: text, role: role))
        }
    }
}

extension ViewModel {

    private func send(text: String) async {
        guard let apiKey = CREDENTIALS.shared["MY_API_KEY"] as? String else {
            return
        }
        let token = "\(apiKey)"

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(token)"
        ]

        var messages = convertToMessages(text: text)
        if self.setting != nil {
            messages.insert(["content": self.setting!.content, "role": self.setting!.role.rawValue], at: 0)
        }
        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages,
            "max_tokens": 600
        ]

        // Alamofire 5のAF.requestの使用
        AF.request(
            "https://api.openai.com/v1/chat/completions",
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        ).responseData { response in
            switch response.result {
            case .success(let data):
                guard let res = try? JSONDecoder().decode(ChatGPTResponse.self, from: data) else {
                    self.responseFailure(error: "Decode error")
                    return
                }
                print("ChatGPT send Source TEXT: " + text)
                // レスポンスの内容を出力
                print("ChatGPT response: \(res.choices.first?.message.content ?? "No response")")

                self.responseSuccess(data: res)
                print("ChatGPT send func SUCCESS")

            case .failure(let error):
                self.responseFailure(error: error.localizedDescription)
            }
        }
    }

    private func convertToMessages(text: String) -> [[String: String]] {
        return [["content": text, "role": Message.Role.user.rawValue]]
    }

}
