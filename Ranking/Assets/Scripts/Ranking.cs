using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.SocialPlatforms;
using UnityEngine.UI;


public class Ranking : MonoBehaviour
{
    public Text RankingScoreText;
    ScoreManager sManager;

    [SerializeField] GameObject RankingPanelObj;
    [SerializeField] GameObject RankingCloseObj;
    [SerializeField] GameObject RankingInputFieldObj;
    [SerializeField] GameObject RankingSendObj;
    [SerializeField] GameObject RankingLabelScoreObj;
    [SerializeField] GameObject RankingScoreObj;

    void Start()
    {
        sManager = GameObject.Find("ScoreManager").GetComponent<ScoreManager>();
    }

    public void RankingFunc()
    {
        //Debug.Log("Ranking Tapped");

        // スコアを表示
        Debug.Log("Ranking Score :" + sManager.GetScore().ToString());
        RankingScoreText.text = sManager.GetScore().ToString();
    }

    public void ShowRanking()
    {
        //Debug.Log("Ranking Tapped");

        // 画像 表示
        RankingPanelObj.SetActive(true);
        RankingCloseObj.SetActive(true);
        // 画像 非表示
        RankingInputFieldObj.SetActive(false);
        RankingSendObj.SetActive(false);
        RankingLabelScoreObj.SetActive(false);
        RankingScoreObj.SetActive(false);

        // 画面 一時停止
        Time.timeScale = 0.0f;
    }

    public void CloseRanking()
    {
        //Debug.Log("Ranking Tapped");

        // 画像 表示
        RankingInputFieldObj.SetActive(true);
        RankingSendObj.SetActive(true);
        RankingLabelScoreObj.SetActive(true);
        RankingScoreObj.SetActive(true);
        // 画像 非表示
        RankingPanelObj.SetActive(false);
        RankingCloseObj.SetActive(false);

        // 画面 再開
        Time.timeScale = 1.0f;
    }

}
