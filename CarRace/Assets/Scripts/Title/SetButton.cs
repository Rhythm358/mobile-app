using System;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;


public class SetButton : MonoBehaviour
{

    public static string[] items;
    public static int LapNum;
    public static GameObject SubTitle;

    private void Start()
    {
        // 縦画面固定
        //Screen.orientation = ScreenOrientation.Portrait;
    }

    public static string[] getItem()
    {
        return items;
    }

    public static int getLapNum()
    {
        return LapNum;
    }


    public void OnClickSetButton()
    {
        //Debug.Log("SetButton Clicked");

        // GameObject型の配列Itemsに、"Item"タグのついたオブジェクトをすべて格納
        GameObject[] ObjectItems = GameObject.FindGameObjectsWithTag("Item");

        // 配列itemsをリサイズ
        Array.Resize(ref items,ObjectItems.Length);

        int i = 0;
        foreach (GameObject ObjectItem in ObjectItems)
        {
            // ObjectItem名が空になることがあるので、空の時は"CPU"をセット
            if (ObjectItem.name == "") ObjectItem.name = "CPU";

            Debug.Log("SetItem: "+ ObjectItem.name);
            items[i] = ObjectItem.name;
            i++;
        }

        // ラップ数を設定
        GameObject lap = GameObject.Find("Lap/LapNumText");
        Text tmpLapNum = lap.GetComponent<Text>();
        int num = Convert.ToInt32(tmpLapNum.text);  // stringをintに変換
        LapNum = num;
        Debug.Log("SetLapNum "+ LapNum);

        // 音量を再生
        AudioListener.volume = 0.1f;

        // 画面固定解除
        //Screen.orientation = ScreenOrientation.AutoRotation;

        // SubTitleGameObjectを取得
        SubTitle = GameObject.Find("SubTitleGameObject");
        // CarRaceシーンを呼び出しているときにSubTitleGameObjectを非表示にする
        SubTitle.SetActive(false);

        // CarRaceシーンに移動 (現在のシーンを破棄して、新しくシーンをロードする)
        SceneManager.LoadScene("CarRace", LoadSceneMode.Single);

    }

}
