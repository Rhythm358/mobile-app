//
//  ContentView.swift
//  MemoApp
//
//

import SwiftUI
import CoreData

// メインのビューを定義
struct ContentView: View {
    // CoreDataのコンテキストを取得（データベースへのアクセスを管理）
    @Environment(\.managedObjectContext) private var viewContext

    // メモを取得するためのリクエスト
    @FetchRequest(
        entity: Memo.entity(), // メモエンティティを指定
        sortDescriptors: [NSSortDescriptor(key: "updatedAt", ascending: false)], // 更新日時で並び替え（新しい順）
        animation: .default // デフォルトのアニメーションを適用
    ) var fetchedMemoList: FetchedResults<Memo> // 取得結果を保持

    // ソート順を切り替えるフラグ
    @State private var isAscending = false

    // @StateObject:Viewが表示されてから消えるまで(.onAppearから.onDisAppearまで)
    @StateObject var timerManager = TimerManager()

    @State private var isBannerLoaded = false


    var body: some View {
        // ナビゲーションビューを定義（画面の移動を管理）
        NavigationView {
            // リストを表示（メモの一覧）
            List {
                // 取得したメモをリスト表示
                ForEach(fetchedMemoList) { memo in
                    // メモをタップすると編集画面に遷移
                    NavigationLink(destination: EditMemoView(memo: memo)) {
                        VStack {
                            // メモのタイトルを表示
                            Text(memo.title ?? "")
                               .font(.title) // タイトルのフォントサイズ
                               .frame(maxWidth: .infinity,alignment: .leading) // 左寄せ
                               .lineLimit(1) // 一行に制限
                           HStack {
                               // 更新日時を表示
                               Text(memo.stringUpdatedAt)
                                   .font(.caption) // 小さいフォントサイズ
                                   .lineLimit(1) // 一行に制限
                               // メモの内容を表示
                               Text(memo.content ?? "")
                                   .font(.caption) // 小さいフォントサイズ
                                   .lineLimit(1) // 一行に制限
                               Spacer() // 余白を追加
                           }
                        }
                    }
                }
                // スワイプで削除できるようにする
                .onDelete(perform: deleteMemo)
            }
            // ナビゲーションバーのタイトルを設定
            .navigationTitle("Word Count")
            .navigationBarTitleDisplayMode(.automatic)
            // ツールバーに「新規作成」ボタンを追加
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // 「新規作成」ボタンをタップすると追加画面に遷移
                    Button(action: {
                        let newMemo = Memo(context: viewContext)
                        newMemo.updatedAt = Date()
                        newMemo.title = "" // タイトルを更新
                        newMemo.content = "" // 内容を更新
                        EditMemoView(memo: newMemo)
                    }) {
                        HStack {
                            Image(systemName: "doc.badge.plus")
                            Text("New")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink {
                        SettingView(timerManager: timerManager)
                    } label: {
                        Image(systemName: "gear")
                        Text("Setting")
                    }
                }
            }
        }
        // iPadでもiPhoneと同様に全画面表示させるためのスタイル設定
        .navigationViewStyle(StackNavigationViewStyle())
        //++++++++++++++++++++++++++++++++++++++++++++++++
        // バナー広告表示
        //BannerView().frame(height: 50)
        BannerView().frame(maxHeight: 60)
        //++++++++++++++++++++++++++++++++++++++++++++++++
    }// bodyここまで

    // メモを削除する関数
    private func deleteMemo(offsets: IndexSet) {
        offsets.forEach { index in
            // 指定されたインデックスのメモを削除
            viewContext.delete(fetchedMemoList[index])
        }
        // 削除を保存
        try? viewContext.save()
    }
}


// プレビュー用の構造体
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // プレビューに表示するビューを設定
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

