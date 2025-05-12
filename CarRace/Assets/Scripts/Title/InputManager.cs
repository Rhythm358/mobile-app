using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class InputManager : MonoBehaviour
{
   
    public void ValueChange(string text)
    {
        //Debug.Log("InputManagerLog: "+text);

        // オブジェクト名をInputFieldに記載された名前に変更
        this.name = text;
    }
}
