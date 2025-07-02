using UnityEngine;
using UnityEngine.SceneManagement;
using System;


public class ResetButton : MonoBehaviour
{
    public GameObject PauseText;


    public void OnClickResetButton()
    {
        // 一時停止解除
        Time.timeScale = 1;
        PauseText.SetActive(false);

        // 音量を再生
        AudioListener.volume = 0.1f;

        // Ranks配列を初期化
        Array.Clear(RankScript.Ranks,0,RankScript.Ranks.Length);
                
        // シーンをリロードする
        SceneManager.LoadScene(SceneManager.GetActiveScene().name);

    }
}
