using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using Firebase.Firestore;
using Firebase.Extensions;

public class SendButton : MonoBehaviour
{
    public InputField inputField;
    private FirestoreScript firestoreScript;
    ScoreManager sManager;

    void Start()
    {
        // ScoreManagerスクリプトを取得
        sManager = GameObject.Find("ScoreManager").GetComponent<ScoreManager>();

        // FireStoreスクリプトを取得
        firestoreScript = GameObject.Find("FireStore").GetComponent<FirestoreScript>();
    }

    public void SendFunc()
    {
        // 名前が空でない場合のみ送信処理を行う
        if (!string.IsNullOrEmpty(inputField.GetComponent<InputField>().text))
        {
            //// ランキングに追加
            //FetchAndSetRanking();
            //// ランキング テキストフィールドを初期化
            //firestoreScript.ClearRankingUI();
            //// ランキングを表示
            //firestoreScript.FetchAndDisplayRanking();

            StartCoroutine(UpdateRankingAndDisplay());
        }
        else
        {
            Debug.Log("名前を入力してください。");
        }
    }

    private IEnumerator UpdateRankingAndDisplay()
    {
        // ランキングに追加
        FetchAndSetRanking();

        // 1秒待機する例
        yield return new WaitForSeconds(1.0f);

        // ランキング テキストフィールドを初期化
        firestoreScript.ClearRankingUI();

        // ランキングを表示
        firestoreScript.FetchAndDisplayRanking();
    }


    private async void FetchAndSetRanking()
    {
        var db = FirebaseFirestore.DefaultInstance;

        // ドキュメントを作成するためのコレクションをプラットフォームごとに分ける
        CollectionReference collectionRef;

        #if UNITY_ANDROID
            collectionRef = db.Collection("scores_android");
        #elif UNITY_IPHONE
            collectionRef = db.Collection("scores_ios");
        #else
            collectionRef = db.Collection("scores_unexpected_platform");
        #endif

        // スコアがランキング内に入っているかを確認
        bool isScoreInRanking = await firestoreScript.IsScoreInRanking(sManager.GetScore());

        if (isScoreInRanking)
        {
            // ドキュメントを作成
            DocumentReference docRef = collectionRef.Document();

            // 現在の日時を取得
            DateTime currentTime = DateTime.Now;

            // 保存するデータを作成
            Dictionary<string, object> scoreData = new Dictionary<string, object>
        {
            { "Name", inputField.GetComponent<InputField>().text }, // プレイヤーの名前
            { "Score", sManager.GetScore().ToString() },    // プレイヤーのスコア
            { "Time", currentTime.ToString("yyyy/MM/dd") }  // プレイヤーが達成した時間
        };

            // Firestoreにデータを書き込み、完了後にランキングを取得
            await docRef.SetAsync(scoreData);

            // プレイヤー名 / スコア を表示
            Debug.Log("Input Name: " + inputField.GetComponent<InputField>().text +
                      "　Ranking Score :" + sManager.GetScore().ToString());

            // Sendボタンを非表示にする
            gameObject.SetActive(false);
        }
        else
        {
            // スコアがランキング外の場合の処理をここに追加
            Debug.Log("スコアはランキング外です。スコアをFirestoreに書き込みません。");
        }
    }


}