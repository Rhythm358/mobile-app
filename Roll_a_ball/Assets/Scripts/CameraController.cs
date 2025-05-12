using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class CameraController : MonoBehaviour 
{

    public GameObject player; //Player情報格納用
    private Vector3 offset;   //相対距離取得用

    void Start ()
    {
        //Playerのオブジェクト情報を格納
        this.player = GameObject.Find("Player");
        // ゲーム開始時点のカメラとターゲットの距離（オフセット）を取得
        offset = transform.position - player.transform.position;
    }

    /// <summary>
    /// プレイヤーが移動した後にカメラが移動するようにするためにLateUpdateにする。
    /// </summary>
    
    void LateUpdate ()
    {
        transform.position = player.transform.position + offset;
    }
}