using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class ScoreManager : MonoBehaviour
{
    public Text textScore;
    int iScore = 0;

    // スコアを取得するメソッド
    public int GetScore()
    {
        return iScore;
    }

    //スコアを設定するメソッド
    public void SetScore()
    {
        iScore += 5;
        //textScore.text = "Score:" + iScore.ToString();
        textScore.text = iScore.ToString();
    }




}
