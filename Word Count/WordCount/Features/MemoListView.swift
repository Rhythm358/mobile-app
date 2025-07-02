

import SwiftUI
import CoreData

struct MemoListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: Memo.entity(),
        sortDescriptors: [NSSortDescriptor(key: "updatedAt", ascending: false)],
        animation: .default
    ) var fetchedMemoList: FetchedResults<Memo>

    @State private var isAscending = false
    @State private var searchText = ""
    @State private var showingNewMemo = false
    @State private var refreshID = UUID()
    @StateObject var timerManager = TimerManager()
    
    // 検索機能付きのフィルタリング
    var filteredMemos: [Memo] {
        if searchText.isEmpty {
            return Array(fetchedMemoList)
        } else {
            return fetchedMemoList.filter { memo in
                (memo.title?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (memo.content?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // メインコンテンツ
                if filteredMemos.isEmpty {
                    EmptyStateView()
                } else {
                    MemoListContent()
                }                
            }
            .id(refreshID) // IDを使った強制リフレッシュ
            .navigationTitle("Word Count")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search memos...")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ClockView()) {
                        Image(systemName: "clock")
                            .foregroundColor(.blue)
                    }
                    SortButton()
                    NewMemoButton()
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    SettingsButton()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showingNewMemo) {
            NewMemoSheet()
        }
        // リフレッシュ機能
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
            // Core Dataの保存通知を受信したときに強制リフレッシュ
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.refreshID = UUID()
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private func MemoListContent() -> some View {
        List {
            ForEach(filteredMemos, id: \.objectID) { memo in
                NavigationLink(destination: EditMemoView(memo: memo)) {
                    MemoRowView(memo: memo)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            .onDelete(perform: deleteMemo)
        }
        .listStyle(.plain)
        .refreshable {
            // Pull to refresh機能
            await refreshData()
        }
    }
    
    // リフレッシュ関数を追加
    private func refreshData() async {
        await MainActor.run {
            viewContext.refreshAllObjects()
            try? viewContext.save()
        }
    }

    @ViewBuilder
    private func EmptyStateView() -> some View {
        if #available(iOS 17.0, *) {
            ContentUnavailableView {
                Label("No Memos Yet", systemImage: "doc.text")
            } description: {
                Text("Create your first memo to get started")
            } actions: {
                Button("Create New Memo") {
                    createNewMemo()
                }
                .buttonStyle(.borderedProminent)
            }
        } else {
            // iOS 16以前用のフォールバック
            VStack(spacing: 20) {
                Image(systemName: "doc.text")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                
                Text("No Memos Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Create your first memo to get started")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button(action: createNewMemo) {
                    Label("Create New Memo", systemImage: "plus")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }


    @ViewBuilder
    private func SortButton() -> some View {
        Button(action: toggleSortOrder) {
            Image(systemName: isAscending ? "arrow.up" : "arrow.down")
                .foregroundColor(.blue)
        }
    }
    
    @ViewBuilder
    private func NewMemoButton() -> some View {
        Button(action: createNewMemo) {
            Image(systemName: "plus")
                .foregroundColor(.blue)
        }
    }
    
    @ViewBuilder
    private func SettingsButton() -> some View {
        NavigationLink(destination: SettingView(timerManager: timerManager)) {
            Image(systemName: "gear")
                .foregroundColor(.blue)
        }
    }
    
    @ViewBuilder
    private func NewMemoSheet() -> some View {
        NavigationView {
            EditMemoView(memo: createMemoObject())
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showingNewMemo = false
                        }
                    }
                }
        }
    }
    
    // MARK: - Actions
    
    // MemoListView.swiftで新規メモ作成時
    private func createNewMemo() {
        // 一時的なメモオブジェクトを作成（保存しない）
        let tempMemo = Memo(context: viewContext)
        tempMemo.updatedAt = Date()
        tempMemo.title = ""
        tempMemo.content = ""
        tempMemo.charsNum = 0
        tempMemo.wordsNum = 0
        tempMemo.timerFlag = false
        
        // EditMemoViewに遷移
        // 実際の保存はEditMemoViewの保存ボタンで行う
    }

    private func createMemoObject() -> Memo {
        let newMemo = Memo(context: viewContext)
        newMemo.updatedAt = Date()
        newMemo.createdAt = Date() // 作成日時も設定
        newMemo.title = ""
        newMemo.content = ""
        newMemo.charsNum = 0
        newMemo.wordsNum = 0
        newMemo.timerFlag = false
        
        // 新規メモは一時的に保存（編集画面で最終保存）
        do {
            try viewContext.save()
            print("✅ 新規メモが作成されました")
        } catch {
            print("❌ 新規メモの作成に失敗しました: \(error)")
        }
        
        return newMemo
    }

    
    private func toggleSortOrder() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isAscending.toggle()
            fetchedMemoList.nsSortDescriptors = [
                NSSortDescriptor(key: "updatedAt", ascending: isAscending)
            ]
        }
    }
    
    private func deleteMemo(offsets: IndexSet) {
        withAnimation(.easeInOut) {
            offsets.forEach { index in
                viewContext.delete(filteredMemos[index])
            }
            
            do {
                if viewContext.hasChanges {
                    try viewContext.save()
                    print("✅ メモが正常に削除されました")
                }
            } catch {
                print("❌ メモの削除に失敗しました: \(error)")
            }
        }
    }

}

// MARK: - MemoRowView

struct MemoRowView: View {
    let memo: Memo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // タイトル
            Text(memo.title?.isEmpty == false ? memo.title! : "Untitled")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            // 内容プレビュー
            if let content = memo.content, !content.isEmpty {
                Text(content)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // メタ情報
            HStack {
                // 更新日時
                Text(memo.stringUpdatedAt)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // 文字数・単語数
                if memo.charsNum > 0 || memo.wordsNum > 0 {
                    HStack(spacing: 12) {
                        Label("\(memo.charsNum)", systemImage: "character.cursor.ibeam")
                        Label("\(memo.wordsNum)", systemImage: "text.word.spacing")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

struct MemoListView_Previews: PreviewProvider {
    static var previews: some View {
        MemoListView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
