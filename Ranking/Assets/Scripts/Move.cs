using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Move : MonoBehaviour
{
    //float speed = 1.0f;
    float minX = -3.0f; // 左端の制限
    float maxX = 3.0f;  // 右端の制限

    //bool isDragging = false;
    Vector2 touchStartPosition;
    [SerializeField] GameObject gameOverTextObj;
    [SerializeField] GameObject rankingPanelObj;

    void Update()
    {
        // ランキングパネルが表示されているときは、反応しない
        if (rankingPanelObj.activeSelf)
        {
            return;
        }

        // gameOverTextObj が非アクティブの場合にのみドラッグ処理を行う
        if (!gameOverTextObj.activeSelf)
        {
            //クリックしたときの処理
            if (Input.GetMouseButtonDown(0))
            {
                // クリックした位置をワールド座標に変換
                Vector2 targetPosition = Camera.main.ScreenToWorldPoint(Input.mousePosition);
                // y 座標はオブジェクトの y 座標を保持
                targetPosition.y = transform.position.y;
                // x 座標に制限を適用
                targetPosition.x = Mathf.Clamp(targetPosition.x, minX, maxX);
                // オブジェクトをタップした位置に移動
                transform.position = targetPosition;
            }

        }
    }
}
