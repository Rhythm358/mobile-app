using System.Collections;
using System.Collections.Generic;
using UnityEngine;
/*
* EnemyのUIをCameraの方に向けたい
* 
*/

public class LookAtCamera : MonoBehaviour
{

    void Update()
    {
        transform.LookAt(Camera.main.transform);
    }
}