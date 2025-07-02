using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DontDestroy : MonoBehaviour
{
    void Start()
    {
        // シーン遷移後も保持
        DontDestroyOnLoad(this);
    }
}
