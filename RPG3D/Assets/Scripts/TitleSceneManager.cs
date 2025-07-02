using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

// ボタンを押したらBattleシーンに行きたい
public class TitleSceneManager : MonoBehaviour
{
    public void OnStartButton()
    {
        SceneManager.LoadScene("Battle");
    }
}