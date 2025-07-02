using System;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.SceneManagement;

public class PredButton : MonoBehaviour
{
    public GameObject PauseText;


    //メイン画面に戻るボタン押されたときの処理
    public void PredSceneButton()
    {
        // 一時停止解除
        Time.timeScale = 1;
        PauseText.SetActive(false);

        // 音量を再生
        //AudioListener.volume = 0.1f;
        // 音量停止
        //AudioListener.volume = 0f;

        // Ranks配列を初期化
        Array.Clear(RankScript.Ranks, 0, RankScript.Ranks.Length);

        // CarRaceシーンに移動
        //SceneManager.LoadScene("SubTitle", LoadSceneMode.Single);

        // 縦画面固定
        //Screen.orientation = ScreenOrientation.Portrait;

        // CarRaceGameObjectを取得
        GameObject CarRace = GameObject.Find("CarRaceGameObject");
        //GameObject CarRace = transform.parent.parent.gameObject;
        // CarRaceシーンを削除
        Destroy(CarRace);

        // SubTitleGameObjectを表示にする
        SetButton.SubTitle.SetActive(true);
    }

}
