using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameOver : MonoBehaviour
{
    private bool isColliding;        // 衝突中かどうかのフラグ
    private float collisionStartTime; // 衝突が始まった時間
    [SerializeField] GameManager gameManager;


    void Update()
    {
        // 衝突中かつ2秒間衝突し続けた場合
        if (isColliding)
        {
            //Debug.Log("isColliding : " + gameObject.name);
            float elapsedTime = Time.time - collisionStartTime;
            if (elapsedTime >= 2f)
            {
                // ゲームオーバー画面の表示処理をここに追加
                GameOverView();
            }
        }
    }

    private void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.gameObject.tag == "Untagged")
        {
            isColliding = true;
            collisionStartTime = Time.time;
        }
    }

    private void OnTriggerExit2D(Collider2D collision)
    {
        if (collision.gameObject.tag == "Untagged")
        {
            isColliding = false;
        }
    }

    private void GameOverView()
    {
        //Debug.Log("Game Over");

        // ゲームオーバー画面の表示やゲームのリセットなどの処理をここに追加
        gameManager.GameOver();
    }


}
