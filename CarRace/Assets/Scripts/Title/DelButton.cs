
using System;
using UnityEngine;

public class DelButton : MonoBehaviour
{
    AddButton AddButtonScript;


    public void OnClick()
    {
        //Debug.Log("Dell_Button_Clicked");

        // Add_ButtonのGameObjectを取得
        GameObject add_button = GameObject.Find("Add_Button");
        // オブジェクト内のAddButtonスクリプトを取得
        AddButtonScript = add_button.GetComponent<AddButton>();
        // ListItem数減算
        AddButtonScript.ListItemNum--;
        //Debug.Log("ListItemNum " + AddButtonScript.ListItemNum);

        // 選択されたオブジェクトを削除
        Destroy(this.gameObject);
    }
}
