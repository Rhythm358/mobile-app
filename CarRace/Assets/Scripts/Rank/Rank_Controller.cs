using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;


public class Rank_Controller : MonoBehaviour
{
    public Text firstText;
    public Text secondText;
    public Text thirdText;
    public Text fourthText;
    public Text fifthText;
    public Text sixthText;
    public Text seventhText;
    public Text eightthText;
    public Text ninethText;
    public Text tenthText;

    private float dt = 0;
    private GameObject[] players;
    private List<GameObject> playerList = new List<GameObject>();
    private List<Text> TextList = new List<Text>();


    void Start()
    {
        // GameObject型の配列playersに、"Player"タグのついたオブジェクトをすべて格納
        players = GameObject.FindGameObjectsWithTag("Player");

        foreach (GameObject player in players)
        {
            playerList.Add(player);
            //Debug.Log("PlayerListSet "+player.name);
        }

        TextList.Add(firstText);
        TextList.Add(secondText);
        TextList.Add(thirdText);
        TextList.Add(fourthText);
        TextList.Add(fifthText);
        TextList.Add(sixthText);
        TextList.Add(seventhText);
        TextList.Add(eightthText);
        TextList.Add(ninethText);
        TextList.Add(tenthText);
    }


    void Update()
    {
        // 昇順にソート
        playerList.Sort((a, b) => a.GetComponent<RankScript>().Count - b.GetComponent<RankScript>().Count);
        // 反転
        playerList.Reverse();

        dt += Time.deltaTime;

        // 0.1秒毎に実行する
        if (dt > 0.1)
        {
            dt = 0.0f;

            int num = 1;
            foreach (var player in playerList)
            {
                //Debug.Log(num+"位 "+ player.name);
                //Debug.Log("Ranks["+num+"] " + RankScript.Ranks[num-1]);

                if (string.IsNullOrEmpty(RankScript.Ranks[num-1]))
                {
                    // Ranks配列が空のとき
                    if (num == 1)
                    {
                        TextList[num - 1].text = player.GetComponent<RankScript>().Lap_num + "/"
                            + SetButton.getLapNum() + " " + "1st: " + player.name;
                    }
                    else if(num == 2)
                    {
                        TextList[num - 1].text = player.GetComponent<RankScript>().Lap_num + "/"
                            + SetButton.getLapNum() + " " + "2nd: " + player.name;
                    }
                    else if (num == 3)
                    {
                        TextList[num - 1].text = player.GetComponent<RankScript>().Lap_num + "/"
                            + SetButton.getLapNum() + " " + "3rd: " + player.name;
                    }
                    else
                    {
                        TextList[num - 1].text = player.GetComponent<RankScript>().Lap_num + "/"
                            + SetButton.getLapNum() + " " + num + "th: " + player.name;
                    }
                    //Debug.Log("RankSetPlayerName " + player.name);
                }
                else
                {
                    //配列に要素が入っているとき
                    TextList[num - 1].text = RankScript.Ranks[num-1];
                    //Debug.Log("Rank配列Set " + RankScript.Ranks[num-1]);
                }
                num++;

            }
        }
    }
}
