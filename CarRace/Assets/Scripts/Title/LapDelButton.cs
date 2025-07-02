using System;
using UnityEngine;
using UnityEngine.UI;


public class LapDelButton : MonoBehaviour
{
    public GameObject LapNum_Text;
    private int minLapNum = 1;

    public void OnClick()
    {
        //Debug.Log("LapDellButton_Clicked");

        Text LapNum = LapNum_Text.GetComponent<Text>();

        // stringをintに変換
        int num = Convert.ToInt32(LapNum.text);

        // 最低ラップ数1
        if(num> minLapNum) num--;

        // IntをStringに変換
        LapNum.text = Convert.ToString(num);
    }
}
