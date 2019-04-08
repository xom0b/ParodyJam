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
            recordController.SetActiveAnimator(recordController.newRecordStank);
        }
        else
        {
            int range = Random.Range(0, 4);
            switch(range)
            {
                case 0:
                    recordController.SetActiveAnimator(recordController.newRecordGreen);
                    break;
                case 1:
                    recordController.SetActiveAnimator(recordController.newRecordPink);
                    break;
                case 2:
                    recordController.SetActiveAnimator(recordController.newRecordPurple);
                    break;
                case 3:
                    recordController.SetActiveAnimator(recordController.newRecordYellow);
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
    }
}
