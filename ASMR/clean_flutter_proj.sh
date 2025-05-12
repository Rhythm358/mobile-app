#!/bin/bash

# Flutterプロジェクトのクリーンアップスクリプト

echo "Flutterプロジェクトのクリーンアップを開始します..."

# flutter clean の実行
echo "flutter clean を実行中..."
flutter clean

# build フォルダの削除
echo "build フォルダを削除中..."
rm -rf build

# iOS関連の一時ファイルの削除
if [ -d "ios" ]; then
    echo "iOS関連の一時ファイルを削除中..."
    cd ios
    # Podfileをバックアップ
    if [ -f "Podfile" ]; then
        cp Podfile Podfile.bak
    fi
    rm -rf Podfile.lock Pods .symlinks
    # Podfileを復元
    if [ -f "Podfile.bak" ]; then
        mv Podfile.bak Podfile
    fi
    cd ..
else
    echo "iOSフォルダが見つかりません。スキップします。"
fi

# Android関連の一時ファイルの削除
if [ -d "android" ]; then
    echo "Android関連の一時ファイルを削除中..."
    cd android
    rm -rf .gradle build app/build
    cd ..
else
    echo "Androidフォルダが見つかりません。スキップします。"
fi

echo "クリーンアップが完了しました。"
