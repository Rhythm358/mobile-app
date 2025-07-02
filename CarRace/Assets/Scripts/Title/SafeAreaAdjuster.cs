using UnityEngine;

public class SafeAreaAdjuster : MonoBehaviour
{
    //セーフエリアに合わせたい箇所をtrueにする。
    [SerializeField] bool left;
    [SerializeField] bool right;
    [SerializeField] bool top;
    [SerializeField] bool bottom;

    private void RequestSafeArea()
    {

        var panel = GetComponent<RectTransform>();
        var area = Screen.safeArea;

        var anchorMin = area.position;
        var anchorMax = area.position + area.size;

        if (left) anchorMin.x /= Screen.width;
        else anchorMin.x = 0;

        if (right) anchorMax.x /= Screen.width;
        else anchorMax.x = 1;

        if (bottom) anchorMin.y /= Screen.height;
        else anchorMin.y = 0;

        if (top) anchorMax.y /= Screen.height;
        else anchorMax.y = 1;

        panel.anchorMin = anchorMin;
        panel.anchorMax = anchorMax;

    }
    private void Update()
    {
        if (Screen.width < Screen.height)
        {
            // 縦モード画面
            RequestSafeArea();//アダプティブバナーを表示する関数 呼び出し
        }
        else
        {
            // 横モード画面
            RequestSafeArea();//アダプティブバナーを表示する関数 呼び出し
        }
        //Debug.Log("WidthDisplay : " + !(Screen.width < Screen.height));
    }
}