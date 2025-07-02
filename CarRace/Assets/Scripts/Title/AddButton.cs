using UnityEngine;


public class AddButton : MonoBehaviour
{
    public GameObject parentobject;
    public int ListItemNum;

    private GameObject Prefab;
    private int MaxListNum = 10;

    void Start()
    {
        // RecourcesフォルダからCPUプレハブを読み込む
        Prefab = (GameObject)Resources.Load("CPU");

        // 親にContentを設定
        parentobject = GameObject.Find("Content");

        // ListItemNumの初期値を設定
        ListItemNum = 1;
    }


    public void OnClick()
    {
        // 最大ListItem数 10
        if (ListItemNum < MaxListNum)
        {
            // ListItem数加算
            ListItemNum++;
            //Debug.Log("ListItemNum " + ListItemNum);

            // 新しいインスタンスを生成する
            var obj = Instantiate(Prefab);

            // リネーム
            obj.name = "CPU";

            // 生成したインスタンスをparentobjectの子として登録します
            obj.transform.SetParent(parentobject.transform, false);
        }
    }
}
