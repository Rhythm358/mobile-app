using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class UI_Select : MonoBehaviour
{
 
    void Start()
    {

    }

    public void SwitchPicturePuzzleScene(){
        SceneManager.LoadScene("PicturePuzzleScene",LoadSceneMode.Single);
    }

    public void SwitchSlidePuzzleScene(){
        SceneManager.LoadScene("SlidePuzzleScene",LoadSceneMode.Single);
    }

     public void GoToHomeScene()
    {
        SceneManager.LoadScene("HomeScene"); // ホームシーンの名前に置き換えてください
    }

}
