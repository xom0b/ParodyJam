using UnityEngine;
using System.Collections;

public class CameraShake : MonoBehaviour
{
    // Amplitude of the shake. A larger value shakes the camera harder.
    public float shakeAmount = 0.7f;
    public float decreaseFactor = 1.0f;

    [HideInInspector]
    public float shakeDuration = 0f;

    Vector3 originalPos;
    float originalShakeAmount;

    private void Start()
    {
        shakeDuration = 0f;
    }

    void OnEnable()
    {
        originalPos = transform.position;
        originalShakeAmount = shakeAmount;
    }

    void Update()
    {
        if (shakeDuration > 0)
        {
            Vector2 shakeMovement = Random.insideUnitCircle * shakeAmount;
            Debug.Log("Shaking camera: " + shakeMovement.ToString("F8"));
            transform.position = originalPos + new Vector3(shakeMovement.x, shakeMovement.y, 0f);
            shakeDuration -= Time.deltaTime * decreaseFactor;
            shakeAmount =  Mathf.Clamp(shakeAmount - Time.deltaTime * decreaseFactor, 0f, 1f);
        }
        else
        {
            shakeDuration = 0f;
            transform.position = originalPos;
            shakeAmount = originalShakeAmount;
        }
    }
}