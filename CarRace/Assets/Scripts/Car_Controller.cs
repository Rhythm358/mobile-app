using UnityEngine;
using UnityEngine.UI;
using System;
using System.Collections.Generic;
using System.Linq;

public class Car_Controller : MonoBehaviour
{
    public GameObject[] players;

    void Start()
    {
        // 自動スリープを無効にする
        Screen.sleepTimeout = SleepTimeout.NeverSleep;

        // GameObject型の配列playersに、"Player"タグのついたオブジェクトをすべて格納
        //players = GameObject.FindGameObjectsWithTag("Player");
        // GameObject型の配列playersに、"Player"タグのついたオブジェクトをすべて格納 + 昇順ソート
        players = GameObject.FindGameObjectsWithTag("Player").OrderBy(go => go.name).ToArray();

        // players配列を初期化
        //foreach (GameObject player in players) player.name = "CPU";

        //□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□
        // Title SetButtonでセットされた値を取得
        string[] items = SetButton.getItem();

        // itemsの中身をShuffleする
        for (int j = 0; j < items.Length; j++)
        {
            string temp = items[j];
            int randomIndex = UnityEngine.Random.Range(0, items.Length);
            items[j] = items[randomIndex];
            items[randomIndex] = temp;
        }

        // (テスト用) Titleと連結する前のテスト用に値を代入
        //string[] items = { "black", "yellow", "orange", "blue", "red", "purple", "green" };
        //□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□

        //foreach (string item in items)            Debug.Log("ItemName: " + item);
        //foreach (GameObject player in players)    Debug.Log("PlayerName: " + player.name);

        int i = 0;
        foreach (GameObject player in players) 
        {
            //Debug.Log("predCarName " + player.name);

            // itemsにセットされた数以下のとき、各種設定
            if (i < items.Length)
            {
                // Car名を変更
                player.name = items[i];

                // Car上部に表示する名前を変更
                GameObject cd = player.transform.GetChild(6).gameObject;// 子(Canvas)を取得 GetChild(6:0から数えて6番目がCanvas)
                GameObject gcd = cd.GetComponent<Transform>().transform.GetChild(0).gameObject;// 孫(Text)を取得
                gcd.GetComponent<Text>().text = items[i];

                //Debug.Log(gcd.GetComponent<TextMeshProUGUI>().text);
                i++;
            }
            else
            {
                // itemsの数を超えた車を消す
                player.SetActive(false);
            }
        }

    }

}
