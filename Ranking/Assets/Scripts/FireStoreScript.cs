using System;
using System.Collections.Generic;
using Firebase.Firestore;
using Firebase.Extensions;
using UnityEngine;
using UnityEngine.UI;
using System.Linq;
using System.Threading.Tasks;

public class FirestoreScript : MonoBehaviour
{
    public Text rankingTextPrefab;  // UIテキストのプレハブ
    public Transform ScrollViewContent;  // ScrollViewのコンテンツ
    public int numberOfRankings = 10;  // 表示するランキングの数


    public void Start()
    {
        FetchAndDisplayRanking();
    }

    public void FetchAndDisplayRanking()
    {
        var db = FirebaseFirestore.DefaultInstance;

        CollectionReference scoresRef;

        #if UNITY_ANDROID
            scoresRef = db.Collection("scores_android");
        #elif UNITY_IPHONE
            scoresRef = db.Collection("scores_ios");
        #else
            scoresRef = db.Collection("scores_unexpected_platform");
        #endif

        scoresRef.OrderBy("Score").Limit(numberOfRankings).GetSnapshotAsync().ContinueWithOnMainThread(task =>
        {
            if (task.IsCanceled)
            {
                Debug.LogError("Task canceled");
            }
            else if (task.IsFaulted)
            {
                Debug.LogError("Task faulted: " + task.Exception);
            }
            else if (task.IsCompleted)
            {
                QuerySnapshot snapshot = task.Result;

                // ランキングを表示
                List<ScoreData> ranking = new List<ScoreData>();
                foreach (DocumentSnapshot document in snapshot.Documents)
                {
                    IDictionary<string, object> scoreData = document.ToDictionary();
                    ScoreData playerScore = new ScoreData
                    {
                        Name = scoreData["Name"].ToString(),
                        Score = Convert.ToInt32(scoreData["Score"]),
                        Time = scoreData["Time"].ToString()
                    };
                    ranking.Add(playerScore);
                }

                // ランキングを降順に並び替え
                ranking.Sort((a, b) => b.Score.CompareTo(a.Score));

                //++++++++++++++++++++++++++++++++++++++
                // ランキングを表示
                //++++++++++++++++++++++++++++++++++++++
                // UIテキストのインスタンスを生成してランキング情報を表示
                for (int i = 0; i < numberOfRankings; i++)
                {
                    if (i < ranking.Count)
                    {
                        // UIテキストのインスタンスを生成
                        Text newTextObject = Instantiate(rankingTextPrefab, ScrollViewContent);

                        // テキストを設定
                        newTextObject.text = $"{i + 1}. {ranking[i].Name} - Score: {ranking[i].Score}, {ranking[i].Time}";
                    }
                    else
                    {
                        // ランキングのデータが足りない場合、ダミーのUIテキストのインスタンスを生成
                        Text dummyTextObject = Instantiate(rankingTextPrefab, ScrollViewContent);
                        dummyTextObject.text = $"{i + 1}. -";
                    }
                }
                //++++++++++++++++++++++++++++++++++++++

            }


        });
    }

    // スコアデータのクラス
    private class ScoreData
    {
        public string Name { get; set; }
        public int Score { get; set; }
        public string Time { get; set; }
    }

    public void ClearRankingUI()
    {
        foreach(Transform child in ScrollViewContent)
        {
            Destroy(child.gameObject);
        }
    }


    // スコアがランキング内にあるかどうかを確認する関数
    public async Task<bool> IsScoreInRanking(int playerScore)
    {
        var db = FirebaseFirestore.DefaultInstance;
        CollectionReference scoresRef;

        #if UNITY_ANDROID
            scoresRef = db.Collection("scores_android");
        #elif UNITY_IPHONE
            scoresRef = db.Collection("scores_ios");
        #else
            scoresRef = db.Collection("scores_unexpected_platform");
        #endif

        try
        {
            // 現在のランキングを非同期で取得
            var snapshot = await scoresRef.OrderBy("Score").Limit(numberOfRankings).GetSnapshotAsync();

            // ランキングの処理
            List<ScoreData> ranking = new List<ScoreData>();
            int RankingNum = 0;
            foreach (DocumentSnapshot document in snapshot.Documents)
            {
                IDictionary<string, object> scoreData = document.ToDictionary();
                ScoreData playerScoreData = new ScoreData
                {
                    Name = scoreData["Name"].ToString(),
                    Score = Convert.ToInt32(scoreData["Score"]),
                    Time = scoreData["Time"].ToString()
                };
                ranking.Add(playerScoreData);
                RankingNum++;
            }

            //Debug.Log("RankingNum: " + RankingNum);

            // ランキング数がランキングの総数以下なら書き込みOK
            if (RankingNum<numberOfRankings) return true;

            // スコアがランキング内にあるかどうかを確認
            return ranking.Any(scoreData => playerScore > scoreData.Score);
        }
        catch (Exception e)
        {
            Debug.LogError("Error fetching rankings: " + e.Message);
            return false;
        }
    }


}

