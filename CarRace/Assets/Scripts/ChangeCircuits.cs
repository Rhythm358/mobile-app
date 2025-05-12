using System.Collections;
using System.Collections.Generic;
//using UnityEditor.Localization.Plugins.XLIFF.V12;
using UnityEngine;
using UnityStandardAssets.Utility;

public class ChangeCircuits : MonoBehaviour
{
    
    string[] circuitList = { "BlackWaypoints", "YellowWaypoints", "OrangeWaypoints", "BlueWaypoints", "RedWaypoints" };
    
    void OnTriggerEnter(Collider other)
    {
        int num= Random.Range(0, 5);    //0~4のランダム

        if (other.gameObject.tag == "CheckCircuit")// Circuitチェックポイントに触れた
        {
            //Debug.Log(circuitList[num]);
            //Debug.Log(GameObject.Find(circuitList[num]).name);

            // WaypointProgressTracker.csの
            // [SerializeField] private→publicに変更した WaypointCircuit circuit;

            this.GetComponent<WaypointProgressTracker>().circuit =
                 GameObject.Find(circuitList[num]).GetComponent<WaypointCircuit>();
        }
    }
}
