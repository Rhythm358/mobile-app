//
//  Persistence.swift
//  MemoApp
//
//

import CoreData

// CoreDataのデータ管理を行う構造体
struct PersistenceController {
    // シングルトンとして共有されるインスタンス
    static let shared = PersistenceController()

    // プレビュー用のデータを作成する静的プロパティ
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true) // メモリ内にデータを保存（テスト用）
        let viewContext = result.container.viewContext
        // テスト用のメモデータを10件作成
        for index in 0..<10 {
            let newItem = Memo(context: viewContext)
            newItem.title = "メモタイトル\(index + 1)"
            newItem.content = "メモ\(index + 1)の内容が記載されています"
        }
        do {
            // 作成したデータを保存
            try viewContext.save()
        } catch {
            // エラー処理（通常のアプリでは適切に処理する必要があります）
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    // CoreDataのコンテナ
    let container: NSPersistentContainer

    // イニシャライザ
    init(inMemory: Bool = false) {
        // "MemoApp" という名前のコンテナを作成
        container = NSPersistentContainer(name: "MemoApp")
        if inMemory {
            // テスト用にメモリ内に保存する設定
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        // 永続ストアを読み込む
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // エラーが発生した場合の処理（通常のアプリでは適切に処理する必要があります）
                /*
                ここでの典型的なエラーの原因には次のようなものがあります:
                * 親ディレクトリが存在しない、作成できない、または書き込みを許可しない。
                * パーミッションの問題やデバイスがロックされているなどで永続ストアにアクセスできない。
                * デバイスの空き容量が不足している。
                * ストアが現在のモデルバージョンに移行できなかった。
                エラーメッセージを確認して、実際の問題を特定してください。
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
