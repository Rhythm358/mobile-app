using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class SlidePuzzleSceneDirector : MonoBehaviour
{
    // ピース
    [SerializeField] List<GameObject> pieces;
    // ゲームクリア時に表示されるボタン
    [SerializeField] GameObject buttonRetry;
    // シャッフル回数
    [SerializeField] int shuffleCount;

    // 初期位置
    List<Vector2> startPositions;

    public Text timerText; // タイマーを表示するUIテキスト
    private float startTime;
    private bool isRunning = false;

    // Start is called before the first frame update
    void Start()
    {
        // 初期位置を保存
        startPositions = new List<Vector2>();
        foreach (var item in pieces)
        {
            startPositions.Add(item.transform.position);
        }

        // 指定回数シャッフル
        for (int i = 0; i < shuffleCount; i++)
        {
            // 0番と隣接するピース
            List<GameObject> movablePieces = new List<GameObject>();

            // 0番と隣接するピースをリストに追加
            foreach (var item in pieces)
            {
                if (GetEmptyPiece(item) != null)
                {
                    movablePieces.Add(item);
                }
            }

            // 隣接するピースをランダムで入れかえる
            int rnd = Random.Range(0, movablePieces.Count);
            GameObject piece = movablePieces[rnd];
            SwapPiece(piece, pieces[0]);
        }

        // ボタン非表示
        buttonRetry.SetActive(false);
    }

    public void StartTimer()
    {
        startTime = Time.time;
        isRunning = true;
    }

    public void StopTimer()
    {
        isRunning = false;
    }

    // Update is called once per frame
    void Update()
    {
        // タッチ処理
        if(Input.GetMouseButtonUp(0))
        {
            // スクリーン座標からワールド座標に変換
            Vector2 worldPoint = Camera.main.ScreenToWorldPoint(Input.mousePosition);
            // レイを飛ばす
            RaycastHit2D hit2d = Physics2D.Raycast(worldPoint, Vector2.zero);

            // レイが飛ばされるワールド座標を確認
            //Debug.Log("Raycast point: " + worldPoint);

            // 当たり判定があった
            if(hit2d)
            {
                //Debug.Log("Hit detected on: " + hit2d.collider.gameObject.name);  // ヒットしたオブジェクトの名前を表示

                // ヒットしたゲームオブジェクト
                GameObject hitPiece = hit2d.collider.gameObject;

                // ゲーム開始時にタイマーをスタートする処理
                if (!isRunning && Input.GetMouseButtonUp(0))
                {
                    StartTimer(); // タイマーを開始
                }

                // 0番のピースと隣接していればデータが入る
                GameObject emptyPiece = GetEmptyPiece(hitPiece);
                // 選んだピースと0番のピースを入れかえる
                SwapPiece(hitPiece, emptyPiece);

                // クリア判定
                buttonRetry.SetActive(true);

                // 正解の位置と違うピースを探す
                for (int i = 0; i < pieces.Count; i++)
                {
                    // 現在のポジション
                    Vector2 position = pieces[i].transform.position;
                    // 初期位置と違ったらボタンを非表示
                    if(position != startPositions[i])
                    {
                        buttonRetry.SetActive(false);
                    }
                }

                // クリア状態
                if(buttonRetry.activeSelf)
                {
                    StopTimer(); // ゲームクリア時にタイマーを止める
                    //Debug.Log("クリア（StopTimer）！！");
                }
            }
        }

        if (isRunning)
        {
            float timeElapsed = Time.time - startTime;
            int minutes = (int)(timeElapsed / 60);
            int seconds = (int)(timeElapsed % 60);

            // レトロな表示にするために数字を揃える
            timerText.text = string.Format("{0:00}:{1:00}", minutes, seconds);
        }
        
    }

    // 引数のピースが0番のピースと隣接していたら0番のピースを返す
    GameObject GetEmptyPiece(GameObject piece)
    {
        // 2点間の距離を代入
        float dist =
            Vector2.Distance(piece.transform.position, pieces[0].transform.position);

        // 距離が1なら0番のピースを返す（2個以上離れていたり、斜めの場合は1より大きい距離になる）
        if (dist == 1)
        {
            return pieces[0];
        }

        return null;
    }

    // 2つのピースの位置を入れかえる
    void SwapPiece(GameObject pieceA, GameObject pieceB)
    {
        // どちらかがnullなら処理をしない
        if (pieceA == null || pieceB == null)
        {
            return;
        }

        // AとBのポジションを入れかえる
        Vector2 position = pieceA.transform.position;
        pieceA.transform.position = pieceB.transform.position;
        pieceB.transform.position = position;
    }

    // リトライボタン
    public void OnClickRetry()
    {
        //「SlidePuzzleScene」へ画面遷移
        //SceneManager.LoadScene("SlidePuzzleScene");

        // 現在のシーン名を取得し、それをリロードする
        string currentSceneName = SceneManager.GetActiveScene().name;
        SceneManager.LoadScene(currentSceneName);
    }
}
