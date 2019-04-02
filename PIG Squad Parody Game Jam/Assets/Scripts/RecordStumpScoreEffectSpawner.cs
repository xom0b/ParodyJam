using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RecordStumpScoreEffectSpawner : MonoBehaviour
{
    public GameObject goodRecordScoreEffect;
    public GameObject badRecordScoreEffect;
    public Vector3 spawnedRecordLocalPosition;
    public Vector3 spawnedRecordLocalScale;
    public Vector3 spawnedRecordLocalRotation;

    public void SpawnRecordKillEffect(RecordSpawner.RecordType recordType)
    {
        GameObject recordEffectToSpawn = null;
        switch (recordType)
        {
            case RecordSpawner.RecordType.Bad:
                recordEffectToSpawn = badRecordScoreEffect;
                break;
            case RecordSpawner.RecordType.Good:
                recordEffectToSpawn = goodRecordScoreEffect;
                break;
        }

        if (recordEffectToSpawn != null)
        {
            recordEffectToSpawn = Instantiate(recordEffectToSpawn, transform);
            SetEffectDefaultTransform(recordEffectToSpawn.transform);
        }
    }

    private void SetEffectDefaultTransform(Transform effectTransform)
    {
        effectTransform.localPosition = spawnedRecordLocalPosition;
        effectTransform.localScale = spawnedRecordLocalScale;
        effectTransform.localRotation = Quaternion.Euler(spawnedRecordLocalRotation);
    }

    private void OnTriggerEnter2D(Collider2D collision)
    {
        RecordController collidedController = collision.gameObject.GetComponent<RecordController>();
        if (collidedController != null)
        {
            SpawnRecordKillEffect(collidedController.recordType);
        }
    }
}
