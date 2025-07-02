using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class GameManager : MonoBehaviour
{
    [SerializeField] GameObject gameOverTextObj;
    [SerializeField] GameObject gameOverRetryButtonObj;
    [SerializeField] GameObject gameOverRankingPanelObj;

    ScoreManager sManager;
    public Text RankingScoreText;

    public void GameOver()
    {
        gameOverTextObj.SetActive(true);
        gameOverRetryButtonObj.SetActive(true);
        gameOverRankingPanelObj.SetActive(true);

        // ゲームスコアをランキングスコアに入力
        sManager = GameObject.Find("ScoreManager").GetComponent<ScoreManager>();
        RankingScoreText.text = sManager.GetScore().ToString();
    }

    public void StartButton()
    {
        //Debug.Log("START TAP");
        SceneManager.LoadScene("MainScene");
    }

}
