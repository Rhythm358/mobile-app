using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class Otosu : MonoBehaviour
{
    public GameObject[] kudamono;
    [SerializeField] private Sprite[] changeImage;
    [SerializeField] GameObject gameOverTextObj;
    [SerializeField] GameObject rankingPanelObj;


    private int randomNum;
    private SpriteRenderer spriteRenderer;
    private bool canTap = true;
    private float tapCooldown = 0.5f; // タップのクールダウン時間（秒）

    // Start is called before the first frame update
    void Start()
    {
        randomNum = Random.Range(0, kudamono.Length);
        // SpriteRendererコンポーネントを取得します
        spriteRenderer = GetComponent<SpriteRenderer>();
        // スプライト画像を差し替える
        spriteRenderer.sprite = changeImage[randomNum];
    }

    // Update is called once per frame
    void Update()
    {
        //++++++++++++++++++++
        // タップされた位置を Raycast してヒットしたオブジェクトを取得
        //Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        //RaycastHit hit;

        //if (Physics.Raycast(ray, out hit))
        //{
        //    // ヒットしたオブジェクトが画像ならば処理をスキップ
        //    if (hit.transform.CompareTag("Image"))
        //    {
        //        Debug.Log("test");
        //        return;
        //    }
        //}
        //++++++++++++++++++++

        // ランキングパネルが表示されているときは、反応しない
        if (rankingPanelObj.activeSelf)
        {
            return;
        }

        // gameOverTextObj が非アクティブの場合にのみドラッグ処理を行う
        if (!gameOverTextObj.activeSelf)
        {
            // PC スマホ タップを離した時の処理
            if (Input.GetMouseButtonUp(0) && canTap)
            {
                //Debug.Log("Otosu");

                StartCoroutine(TapCooldown());

                Instantiate(kudamono[randomNum], this.transform.position, this.transform.rotation);
                randomNum = Random.Range(0, kudamono.Length);

                // スプライト画像を差し替える
                spriteRenderer.sprite = changeImage[randomNum];
            }
        }
    }

    IEnumerator TapCooldown()
    {
        canTap = false;
        yield return new WaitForSeconds(tapCooldown);
        canTap = true;
    }



}
