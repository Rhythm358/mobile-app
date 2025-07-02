using UnityEngine;
using UnityEngine.SceneManagement;

public class ChangeTitle : MonoBehaviour
{
    
    void Update()
    {
        if (Input.GetMouseButton(0))
        {
            SceneManager.LoadScene("SubTitle");
           
        }
    }
}
