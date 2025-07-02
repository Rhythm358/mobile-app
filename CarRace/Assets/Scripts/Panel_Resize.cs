using UnityEngine;
using UnityEngine.UI;


public class Panel_Resize : MonoBehaviour
{
    public GameObject[] texts;

    private RectTransform panel;

    void Update()
    {
        int textnum=0;

        panel = gameObject.GetComponent<RectTransform>();

        // 文字列が入っているText数を取得
        foreach (GameObject Itemtext in texts)
        {
            Text RankText = Itemtext.GetComponent<Text>();
            // RankTextが空ではないとき
            if (!string.IsNullOrEmpty(RankText.text)) textnum++;
        }

        // パネルサイズをリサイズ  RankText[0].sizeY × textnum + 追加余白
        panel.sizeDelta =
            new Vector2(panel.sizeDelta.x, texts[0].GetComponent<RectTransform>().sizeDelta.y * textnum + 5);

    }
}
