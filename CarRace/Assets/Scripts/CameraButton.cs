using UnityEngine;


public class CameraButton : MonoBehaviour
{
    public GameObject[] objects;
    public GameObject   PauseText;

    private GameObject[] players;
    private int          m_CurrentActiveObject=0;

    private void Start()
    {
        // GameObject型の配列playersに、"Player"タグのついたオブジェクトをすべて格納
        players = GameObject.FindGameObjectsWithTag("Player");
    }

    public void OnClickCameraSwitchButton()
    {
        //Debug.Log("CameraButton_Clicked");

        // アクティブな車の数をカウント
        int ItemNum = 0;
        foreach (GameObject player in players)
        {
            if (player.activeSelf == true)
            {
                //Debug.Log("ActiveCar: " + player.name);
                ItemNum++;
            }
        }
        
        // 一時停止解除
        Time.timeScale = 1;
        PauseText.SetActive(false);

        // 音量を再生
        AudioListener.volume = 0.1f;

        // カメラを切り替える
        //int nextActiveObject = m_CurrentActiveObject + 1 >= objects.Length ? 0 : m_CurrentActiveObject + 1;
        //for (int i = 0; i < objects.Length; i++)
        //{
        //    objects[i].SetActive(i == nextActiveObject);
        //}

        // Itemにセットされた数だけカメラを切り替える
        int nextActiveObject = m_CurrentActiveObject + 1 >= ItemNum ? 0 : m_CurrentActiveObject + 1;

        for (int i = 0; i < ItemNum; i++)
        {
            objects[i].SetActive(i == nextActiveObject);

            //if (i == nextActiveObject)
            //{
            //    Debug.Log("CameraMove " + objects[i].name);
            //}
        }

        m_CurrentActiveObject = nextActiveObject;

    }
}
