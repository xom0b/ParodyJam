﻿using System;
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
    public event Action<Transform> onDestroy;

    private Vector3 deltaMovement = new Vector3();

    void OnTriggerEnter2D(Collider2D collision)
    {
        if (onTriggerEnter == null && collision.gameObject.tag != "Floor")
        {
            Debug.Log("why is this null " + gameObject, gameObject);
        }
        if (collision.gameObject.tag == "RecordKiller" && onTriggerEnter != null)
        {
            onTriggerEnter(this, collision);
            Destroy(gameObject);
        }

        if (collision.gameObject.tag == "Foot" && onTriggerEnter != null)
        {
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
        transform.position += deltaMovement;
    }

    private void OnDestroy()
    {
        if (onDestroy != null)
        {
            IntegrityManager integrityManager;
            if (IntegrityManager.TryGetInstance(out integrityManager))
            {
                integrityManager.KilledRecord(recordType);
            }

            onDestroy(transform);
        }
    }
}
