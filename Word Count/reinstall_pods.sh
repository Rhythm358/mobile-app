#!/bin/bash

# CocoaPods完全再インストールスクリプト
echo "🧹 CocoaPodsの完全クリーンアップを開始します..."

# Xcodeが開いている場合の警告
echo "⚠️  Xcodeを閉じてから実行してください"
read -p "Xcodeを閉じましたか？ (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Xcodeを閉じてから再実行してください"
    exit 1
fi

# 既存ファイルの削除
echo "🗑️  既存のPods関連ファイルを削除中..."
rm -rf Pods
rm -rf WordCount.xcworkspace
rm -f Podfile.lock

# 派生データのクリア（オプション）
echo "🧽 派生データをクリアしますか？"
read -p "(y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🧽 派生データをクリア中..."
    rm -rf ~/Library/Developer/Xcode/DerivedData/WordCount-*
fi

# CocoaPodsの再インストール
echo "📦 CocoaPodsを再インストール中..."
pod install

# 完了メッセージ
if [ $? -eq 0 ]; then
    echo "✅ CocoaPodsの再インストールが完了しました！"
    echo "📂 WordCount.xcworkspaceを開いてください"
else
    echo "❌ エラーが発生しました。Podfileを確認してください"
    exit 1
fi
