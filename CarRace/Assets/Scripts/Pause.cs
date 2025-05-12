using UnityEngine;


public class Pause : MonoBehaviour
{
    public GameObject PauseText;


    void Start()
    {
        PauseText.SetActive(false);
    }

    public void OnclickPauseButton()
    {
      
        if (Time.timeScale == 1)
        {
            // 一時停止
            Time.timeScale = 0;
            PauseText.SetActive(true);

            // 音量停止
            AudioListener.volume = 0f;
        }
        else
        {
            // 一時停止解除
            Time.timeScale = 1;
            PauseText.SetActive(false);

            // 音量再生
            AudioListener.volume = 0.1f;
            
        }
    }
}
