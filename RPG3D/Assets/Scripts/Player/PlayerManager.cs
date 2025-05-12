using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/* Playerのコンボ攻撃
 * ・Attackの後、別の攻撃アニメーションを行う
 * ・
*/
public class PlayerManager : MonoBehaviour
{
    float x;
    float z;
    public float moveSpeed;
    public Collider weaponCollider;
    public PlayerUIManager playerUIManager;
    public GameObject gameOverText;
    public Transform target;
    public int maxHp = 10;
    int hp;
    public int maxStamina = 100;
    int stamina;

    bool isDie;


    Rigidbody rb;
    Animator animator;
    // Update関数の前に１度だけ実行される：設定
    void Start()
    {
        hp = maxHp;
        stamina = maxStamina;
        playerUIManager.Init(this);
        rb = GetComponent<Rigidbody>();
        animator = GetComponent<Animator>();
        HideColliderWeapon();
    }

    // 約0.02秒に一回実行される：更新
    void Update()
    {
        if (isDie)
        {
            return;
        }
        // キーボード入力で移動させたい
        x = Input.GetAxisRaw("Horizontal");
        z = Input.GetAxisRaw("Vertical");

        // 攻撃入力：Spaceボタンを押したら
        if (Input.GetKeyDown(KeyCode.Space))
        {
            Attack();
        }
        IncreaseStamina();
    }

    void IncreaseStamina()
    {
        stamina++;
        if (stamina >= maxStamina)
        {
            stamina = maxStamina;
        }
        playerUIManager.UpdateStamina(stamina);
    }

    void Attack()
    {
        if (stamina >= 40)
        {
            stamina -= 40;
            playerUIManager.UpdateStamina(stamina);
            LookAtTarget();
            animator.SetTrigger("Attack");
        }
    }

    void LookAtTarget()
    {
        float distance = Vector3.Distance(transform.position, target.position);
        if (distance <= 2f)
        {
            transform.LookAt(target);
        }
    }

    private void FixedUpdate()
    {
        if (isDie)
        {
            return;
        }

        Vector3 direction = transform.position + new Vector3(x, 0, z) * moveSpeed;
        transform.LookAt(direction);
        // 速度設定
        rb.velocity = new Vector3(x, 0, z) * moveSpeed;
        animator.SetFloat("Speed", rb.velocity.magnitude);
    }

    // 武器の判定を無効にしたり/有効にしたりする関数
    public void HideColliderWeapon()
    {
        weaponCollider.enabled = false;
    }
    public void ShowColliderWeapon()
    {
        weaponCollider.enabled = true;
    }

    void Damage(int damage)
    {
        hp -= damage;
        if (hp <= 0)
        {
            hp = 0;
            isDie = true;
            animator.SetTrigger("Die");
            gameOverText.SetActive(true);
            rb.velocity = Vector3.zero;
        }
        playerUIManager.UpdateHP(hp);
        Debug.Log("Player残りHP：" + hp);
    }
    private void OnTriggerEnter(Collider other)
    {
        if (isDie)
        {
            return;
        }

        Damager damager = other.GetComponent<Damager>();
        if (damager != null)
        {
            // ダメージを与えるものにぶつかったら
            animator.SetTrigger("Hurt");
            Damage(damager.damage);
        }
    }
}