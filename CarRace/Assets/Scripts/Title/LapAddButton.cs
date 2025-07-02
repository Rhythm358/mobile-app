using System;
using UnityEngine;
using UnityEngine.UI;


public class LapAddButton : MonoBehaviour
{
    public GameObject LapNum_Text;
    private int maxLapNum = 10;

    public void OnClick()
    {
        //Debug.Log("LapAddButton_Clicked");

        Text LapNum = LapNum_Text.GetComponent<Text>();

        // stringをintに変換
        int num = Convert.ToInt32(LapNum.text);

        // 最大ラップ数10
        if(num< maxLapNum) num++;

        // IntをStringに変換
        LapNum.text = Convert.ToString(num);

    }
}
