using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class IntegrityManager : MonoBehaviour
{
    [Header("Integrity")]
    public int maxIntegrity;
    public int goodRecordIntegrity;
    public int badRecordIntegrity;
    public float maxTimeMinutes;

    [Header("End Game")]
    public float maxMinTimeBetweenRecords;
    public float maxMaxTimeBetweenRecords;
    public float maxMinSpawnSpeed;
    public float maxMaxSpawnSpeed;
    [Range(0f, 1f)]
    public float maxRecordSpawnRatio;

    [Header("UI")]
    public RectTransform integrityContainer;
    public RectTransform integrityIndicator;
    public float minOffset;
    public float maxOffset;
    public float integritySmooth;
    

    [HideInInspector]
    public int currentIntegrity;

    private static IntegrityManager instance = null;

    private float currentTime;
    private float targetOffset;
    private float currentOffset;
    private float integrityVelocity;
    private float maxTimeSeconds;


    private float startingMinTimeBetweenRecords;
    private float startingMaxTimeBetweenRecords;
    private float startingMinRecordSpawnSpeed;
    private float startingMaxRecordSpawnSpeed;
    private float startingRecordSpawnRatio;

    private RecordSpawner[] recordSpawners;

    private enum GameState
    {
        Intro,
        Playing,
        End
    }

    private GameState gameState = GameState.Playing;

    private void Awake()
    {
        if (instance != null)
        {
            Debug.LogWarning("There are two IntegrityManagers in the scene");
        }

        instance = this;
    }

    private void Start()
    {
        currentIntegrity = maxIntegrity / 2;
        recordSpawners = FindObjectsOfType<RecordSpawner>();
        maxTimeSeconds = maxTimeMinutes * 60f;

        startingMinTimeBetweenRecords = recordSpawners[0].minTimeBetweenRecordsSeconds;
        startingMaxTimeBetweenRecords = recordSpawners[0].maxTimeBetweenRecordsSeconds;
        startingMinRecordSpawnSpeed = recordSpawners[0].minRecordSpawnSpeed;
        startingMaxRecordSpawnSpeed = recordSpawners[0].maxRecordSpawnSpeed;
        startingRecordSpawnRatio = recordSpawners[0].recordSpawnRatio;
    }

    public static bool TryGetInstance(out IntegrityManager manager)
    {
        manager = instance;
        return (manager != null);
    }

    private void Update()
    {
        switch (gameState)
        {
            case GameState.Intro:
                break;
            case GameState.Playing:

                currentTime += Time.deltaTime;

                if (Input.GetKeyDown(KeyCode.UpArrow))
                {
                    //currentIntegrity += 50;
                    currentTime += 60f;
                }
                else if (Input.GetKeyDown(KeyCode.DownArrow))
                {
                    currentTime -= 30f;
                    // -= 4;
                }

                UpdateUI();
                UpdateSpawners();

                if (currentIntegrity >= maxIntegrity)
                {
                    EndGame();
                }

                break;
            case GameState.End:
                break;
        }

        Debug.Log(currentIntegrity);
        
    }

    private void UpdateSpawners()
    {
        foreach(RecordSpawner recordSpawner in recordSpawners)
        {
            recordSpawner.minTimeBetweenRecordsSeconds = Mathf.Lerp(startingMinTimeBetweenRecords, maxMinTimeBetweenRecords, currentTime / maxTimeSeconds);
            recordSpawner.maxTimeBetweenRecordsSeconds = Mathf.Lerp(startingMaxTimeBetweenRecords, maxMaxTimeBetweenRecords, currentTime / maxTimeSeconds);
            recordSpawner.minRecordSpawnSpeed = Mathf.Lerp(startingMinRecordSpawnSpeed, maxMinSpawnSpeed, currentTime / maxTimeSeconds);
            recordSpawner.maxRecordSpawnSpeed = Mathf.Lerp(startingMaxRecordSpawnSpeed, maxMaxSpawnSpeed, currentTime / maxTimeSeconds);
            recordSpawner.recordSpawnRatio = Mathf.Lerp(startingRecordSpawnRatio, maxRecordSpawnRatio, currentTime / maxTimeSeconds);
        }
    }

    private void ResetGame()
    {
        foreach (RecordSpawner recordSpawner in recordSpawners)
        {
            recordSpawner.minTimeBetweenRecordsSeconds = startingMinTimeBetweenRecords;
            recordSpawner.maxTimeBetweenRecordsSeconds = startingMaxTimeBetweenRecords;
            recordSpawner.minRecordSpawnSpeed = startingMinRecordSpawnSpeed;
            recordSpawner.maxRecordSpawnSpeed = startingMaxRecordSpawnSpeed;
            recordSpawner.recordSpawnRatio = startingRecordSpawnRatio;
        }
    }

    private void EndGame()
    {
        Debug.Log("Game Over!!");
    }

    private void UpdateUI()
    {
        currentIntegrity = Mathf.Clamp(currentIntegrity, 0, maxIntegrity);
        float currentFloatPercentage = (float)currentIntegrity / (float)maxIntegrity;
        float absoluteIndicatorDistance = Mathf.Abs(maxOffset) + Mathf.Abs(minOffset);
        float position = absoluteIndicatorDistance * currentFloatPercentage;
        targetOffset = minOffset + position;
        currentOffset = Mathf.SmoothDamp(currentOffset, targetOffset, ref integrityVelocity, integritySmooth);
        integrityIndicator.localPosition = new Vector3(currentOffset, integrityIndicator.localPosition.y);
    }

    public void KilledRecord(RecordSpawner.RecordType recordType)
    {
        switch(recordType)
        {
            case RecordSpawner.RecordType.Bad:
                currentIntegrity += badRecordIntegrity;
                break;
            case RecordSpawner.RecordType.Good:
                currentIntegrity += goodRecordIntegrity;
                break;
        }
    }
}
