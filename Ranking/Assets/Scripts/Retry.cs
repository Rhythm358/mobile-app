using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class retry : MonoBehaviour
{
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void Retry()
    {
        //Debug.Log("Retry Tapped");

        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }
}
