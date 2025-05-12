using UnityEngine;


public class RankScript : MonoBehaviour
{
    public GameObject GoalText;
    public int Count=0;
    public int Lap_num=1;
    private int Max_lap = 1;

    //順位固定用の配列
    //public static string[] Ranks = { "Tokyo", "Osaka", "Nagoya", "Yamaguchi", "Hiroshima","Kanagawa","Fukuoka" };
    public static string[] Ranks = { "", "", "", "", "", "", "", "", "", "" };
    public static int Rank_index;

    void Start()
    {
        GoalText.SetActive(false);
        Rank_index = 0;
        Max_lap=SetButton.getLapNum();
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "CheckPoint")//チェックポイントに触れた
        {
            Count += 1;
            //Debug.Log("ChecPoint"+count)
        }

        if (other.gameObject.tag == "Line")// ゴールラインに触れた
        {
            // 最大ラップ数以上ならゴールテキストを表示
            if (Lap_num >= Max_lap)
            {
                GoalText.SetActive(true);
                
                Debug.Log(gameObject.name+" GOAL!");

                if (Rank_index < 10)
                {
                         if ((Rank_index + 1) == 1) Ranks[Rank_index] = "1st: " + gameObject.name;
                    else if ((Rank_index + 1) == 2) Ranks[Rank_index] = "2nd: " + gameObject.name;
                    else if ((Rank_index + 1) == 3) Ranks[Rank_index] = "3rd: " + gameObject.name;
                    else
                    {
                        // ゴールした順にRanks配列に値を代入(Rank_indexは配列のindexなので順位は＋1した値)
                        Ranks[Rank_index] = (Rank_index + 1) + "th: " + gameObject.name;
                    }
                    //Debug.Log("Rank_index= " + Rank_index);
                    //Debug.Log("Ranks["+Rank_index+"] " + Ranks[Rank_index]);
                    Rank_index++;
                }
            }
            //Debug.Log(gameObject.name +"LapNum"+ Lap_num);
            Lap_num++;
        }
    }


}