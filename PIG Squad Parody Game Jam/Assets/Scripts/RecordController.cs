using System;
using UnityEngine;
using Prime31;

public class RecordController : MonoBehaviour
{
    public GameObject duragAnimation;
    public GameObject overallAnimation;
    public GameObject tophatAnimation;
    public GameObject stinkyAnimation;
    public GameObject deathAnimation;
    public RecordSpawner.RecordType recordType;
    public RecordSpawner.Costume recordFlavor;
    public float moveSpeed;
    public Vector2 moveDirection;
    public event Action<RecordController, Collider2D> onTriggerEnter;
    public event Action<Transform, bool> onDestroy;

    private Vector3 deltaMovement = new Vector3();

    private bool killedByBoot = false;

    void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.gameObject.tag == "RecordKiller" && onTriggerEnter != null)
        {
            killedByBoot = false;
            onTriggerEnter(this, collision);
            Destroy(gameObject);
        }

        if (collision.gameObject.tag == "Foot" && onTriggerEnter != null)
        {
            killedByBoot = true;
            onTriggerEnter(this, collision);   
        }
    }

    // Update is called once per frame
    void Update()
    {
        deltaMovement = moveDirection * moveSpeed * Time.deltaTime;
        if (transform.position.z != 0f)
        {
            Debug.Log("why is this not zero " + gameObject, gameObject);
        }
    }

    private void LateUpdate()
    {
        IntegrityManager integrityManager;
        if (IntegrityManager.TryGetInstance(out integrityManager))
        {
            if (integrityManager.gameState != IntegrityManager.GameState.Paused)
            {
                transform.position += deltaMovement;
            }
        }
    }

    private void OnDestroy()
    {
        if (onDestroy != null)
        {
            if (!killedByBoot)
            {
                IntegrityManager integrityManager;
                if (IntegrityManager.TryGetInstance(out integrityManager))
                {
                    integrityManager.KilledRecord(recordType);
                }

                onDestroy(transform, false);
            }
            else
            {
                onDestroy(transform, true);
            }
        }
    }
}
