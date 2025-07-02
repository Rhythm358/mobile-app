using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CanvasScaler : MonoBehaviour
{
    [SerializeField]
    private Canvas _canvas;
    private CanvasScaler _canvasScaler;
    private Vector2 referenceResolution;

    void Start()
    {
        _canvasScaler = _canvas.GetComponent<CanvasScaler>();
    }

    void Update()
    {
        if (Input.deviceOrientation == DeviceOrientation.LandscapeLeft || Input.deviceOrientation == DeviceOrientation.LandscapeRight)
        {
            //_canvasScaler.referenceResolution = new Vector2(1280, 720);
            _canvasScaler.referenceResolution = new Vector2(800, 600);

        }
        else
        {
            _canvasScaler.referenceResolution = new Vector2(720, 1280);
        }
    }
}
