using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class Hit : MonoBehaviour
{
    public GameObject evolve;
    ScoreManager sManager;

    void Start()
    {
        sManager = GameObject.Find("ScoreManager").GetComponent<ScoreManager>();   
    }

    void Update()
    {

    }

    private void OnCollisionEnter2D(Collision2D collision)
    {
        // 衝突したオブジェクトの名前が自分自身と同じである場合
        if (this.gameObject.name == collision.gameObject.name)
        {
            //　スコアをセット
            sManager.SetScore();

            Destroy(this.gameObject);

            // SE Sound
            SoundManager.Instance.PlaySE(SESoundData.SE.Hit);

            // 衝突したオブジェクトの Hit コンポーネントの evolve フィールドを null に設定
            Hit hitComponent = collision.gameObject.GetComponent<Hit>();
            if (hitComponent != null)
            {
                hitComponent.evolve = null;
            }

            // evolve フィールドが設定されている場合
            if (evolve != null)
            {
                //Instantiate(evolve, this.transform.position, this.transform.rotation);

                //+++++++++++
                GameObject newObject = Instantiate(evolve, this.transform.position, this.transform.rotation);
                // PolygonCollider2Dを追加
                PolygonCollider2D newCollider = newObject.AddComponent<PolygonCollider2D>();
                // Rigidbody2Dが存在するか確認し、存在しない場合は追加
                //Rigidbody2D newRigidbody = newObject.GetComponent<Rigidbody2D>();
                //+++++++++++
            }

        }
        
    }
}
