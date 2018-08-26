using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RecordSpawner : MonoBehaviour
{
    public GameObject record;

    public Vector2 moveDirection;
    public float minTimeBetweenRecordsSeconds;
    public float maxTimeBetweenRecordsSeconds;
    public float minRecordSpawnSpeed;
    public float maxRecordSpawnSpeed;

    public Sprite goodRecordSprite;
    public Sprite badRecordSprite;

    [Tooltip("Left margin indicated bad record probability. Right margin indicates good recordProbaility")]
    [Range(0f, 1f)]
    public float recordSpawnRatio;

    private float recordSpawnTimer = 0f;
    private float timeToSpawnRecord = 0f;
    private RecordType nextRecordTypeToSpawn;

    public enum RecordType
    {
        Good,
        Bad
    }

    public enum Costume
    {
        Durag,
        Overall,
        TopHat,
        Stinky
    }

    private void Update()
    {
        CheckForRecordSpawn();
    }

    private void CheckForRecordSpawn()
    {
        recordSpawnTimer += Time.deltaTime;

        if (recordSpawnTimer > timeToSpawnRecord)
        {
            ResetSpawnTimer();
            SpawnRecord(nextRecordTypeToSpawn);
        }
    }

    private void OnRecordCollision(RecordController recordController, Collider2D collision)
    {
        if (collision.gameObject.tag == "Foot")
        {
            GameObject leftFoot = GameObject.Find("LeftFoot");
            GameObject rightFoot = GameObject.Find("RightFoot");

            if (collision.gameObject == leftFoot)
            {
                if (leftFoot.GetComponent<FootController>().footMovementState == FootController.FootMovementState.Stomping)
                {
                    Destroy(recordController.gameObject);
                }
            }
            else if (collision.gameObject == rightFoot)
            {
                if (rightFoot.GetComponent<FootController>().footMovementState == FootController.FootMovementState.Stomping)
                {
                    Destroy(recordController.gameObject);
                }
            }
        }
    }

    private void ResetSpawnTimer()
    {
        float goodOrBadDecider = Random.value;
        nextRecordTypeToSpawn = goodOrBadDecider >= recordSpawnRatio ? RecordType.Good : RecordType.Bad;
        timeToSpawnRecord = Random.Range(minTimeBetweenRecordsSeconds, maxTimeBetweenRecordsSeconds);
        recordSpawnTimer = 0;
    }

    private void SpawnRecord(RecordType recordType)
    {
        GameObject recordSpawned = Instantiate(record);
        RecordController recordController = recordSpawned.GetComponent<RecordController>();
        recordController.transform.position = transform.position;
        recordController.recordType = recordType;

        if (recordController.recordType == RecordType.Good)
        {
            recordController.spriteRenderer.sprite = goodRecordSprite;
        }
        else
        {
            recordController.spriteRenderer.sprite = badRecordSprite;
        }
        

        recordController.moveDirection = moveDirection;
        float recordMoveSpeed = Random.Range(minRecordSpawnSpeed, maxRecordSpawnSpeed);
        recordController.moveSpeed = recordMoveSpeed;
        recordController.onTriggerEnter += OnRecordCollision;
    }


}
