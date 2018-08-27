using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RecordSpawner : MonoBehaviour
{
    public GameObject record;
    public GameObject recordKillAnimation;
    public GameObject badRecordKillAnimation;

    public Vector3 recordSpawnOffset;
    public Vector2 moveDirection;
    public float minTimeBetweenRecordsSeconds;
    public float maxTimeBetweenRecordsSeconds;
    public float minRecordSpawnSpeed;
    public float maxRecordSpawnSpeed;

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
        IntegrityManager integrityManager;
        if (IntegrityManager.TryGetInstance(out integrityManager))
        {
            if (integrityManager.gameState != IntegrityManager.GameState.Paused)
            {
                CheckForRecordSpawn();
            }
        }
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

        if (recordType == RecordType.Bad)
        {
            recordController.stinkyAnimation.SetActive(true);
        }
        else
        {
            int range = Random.Range(0, 3);
            switch(range)
            {
                case 0:
                    recordController.duragAnimation.SetActive(true);
                    break;
                case 1:
                    recordController.overallAnimation.SetActive(true);
                    break;
                case 2:
                    recordController.tophatAnimation.SetActive(true);
                    break;
            }
        }

        recordController.moveDirection = moveDirection;

        if (moveDirection.x < 0)
        {
            recordController.transform.localScale = new Vector3(recordController.transform.localScale.x * -1f, recordController.transform.localScale.y, recordController.transform.localScale.z);
        }

        float recordMoveSpeed = Random.Range(minRecordSpawnSpeed, maxRecordSpawnSpeed);
        recordController.moveSpeed = recordMoveSpeed;
        recordController.onTriggerEnter += OnRecordCollision;
        recordController.onDestroy += SpawnRecordKillAnimation;
    }

    private void SpawnRecordKillAnimation(Transform transform, bool killedByFoot)
    {
        if (killedByFoot)
        {
            if (transform.GetComponent<RecordController>().recordType == RecordType.Bad)
            {
                GameObject newBadRecordKillAnimation = Instantiate(badRecordKillAnimation);
                newBadRecordKillAnimation.transform.position = transform.position + recordSpawnOffset;
            }

            GameObject spawnedRecordKillAnimation = Instantiate(recordKillAnimation);
            spawnedRecordKillAnimation.transform.position = transform.position + recordSpawnOffset;
        }
    }
}
