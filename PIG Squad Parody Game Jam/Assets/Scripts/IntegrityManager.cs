using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Rewired;

public class IntegrityManager : MonoBehaviour
{
    [Header("Input")]
    public int playerId;

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
    public GameObject integrityBar;
    public GameObject mainMenu;
    public GameObject endGameMenu;
    public RectTransform integrityContainer;
    public RectTransform integrityIndicator;
    public float minOffset;
    public float maxOffset;
    public float integritySmooth;

    [Header("Game References")]
    public GameObject spawnerRight;
    public GameObject spawnerLeft;
    

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

    private Player player;

    private enum GameState
    {
        Intro,
        Playing,
        End
    }

    private GameState gameState = GameState.Intro;

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

        spawnerLeft.SetActive(false);
        spawnerRight.SetActive(false);

        player = ReInput.players.GetPlayer(playerId);
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

                if (player.GetButtonUp("Start Game"))
                {
                    StartGame();
                }
                break;
            case GameState.Playing:

                currentTime += Time.deltaTime;

                if (Input.GetKeyDown(KeyCode.UpArrow))
                {
                    currentTime += 60f;
                }
                else if (Input.GetKeyDown(KeyCode.DownArrow))
                {
                    currentTime -= 30f;
                }
                else if (Input.GetKeyDown(KeyCode.Space))
                {
                    currentIntegrity = 0;
                }

                UpdateUI();
                UpdateSpawners();

                if (currentIntegrity <= 0)
                {
                    EndGame();
                }

                break;
            case GameState.End:

                if (player.GetButtonUp("Start Game"))
                {
                    ResetToMainMenu();
                }

                break;
        }
    }

    private void ResetToMainMenu()
    {
        gameState = GameState.Intro;
        mainMenu.SetActive(true);
        endGameMenu.SetActive(false);
        integrityBar.SetActive(false);
    }

    private void StartGame()
    {
        gameState = GameState.Playing;
        mainMenu.SetActive(false);
        spawnerLeft.SetActive(true);
        spawnerRight.SetActive(true);
        integrityBar.SetActive(true);
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
        endGameMenu.SetActive(true);
        spawnerLeft.SetActive(false);
        spawnerRight.SetActive(false);
        DestroyAllRecords();
        gameState = GameState.End;
        ResetGame();
        currentTime = 0f;
        currentIntegrity = maxIntegrity / 2;
    }

    private void DestroyAllRecords()
    {
        RecordController[] records = FindObjectsOfType<RecordController>();

        for(int i = 0; i < records.Length; i++)
        {
            Destroy(records[i].gameObject);
        }
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
