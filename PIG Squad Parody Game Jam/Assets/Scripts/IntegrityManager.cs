﻿using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using Rewired;

public class IntegrityManager : MonoBehaviour
{
    [Header("Input")]
    public int playerId;

    [Header("Integrity")]
    public GameObject mudEffect;
    public GameObject shimmerEffect;
    public Animator integrityBarAnimator;
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
    public Animator pauseMenuButtonPromptAB;
    public Text timer;
    public GameObject integrityBar;
    public Animator allThatIsGoodIsNasty;
    public Transform integrityIndicator;
    public float minOffset;
    public float maxOffset;
    public float integritySmooth;
    public float endGamePause;
    public float allThatIsGoodIsNastyLoopTime;

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

    private bool waitingForInvoke = false;

    private RecordSpawner[] recordSpawners;

    private Player player;

    private int maxIntegrityBarOrderInLayer = 2;

    public enum GameState
    {
        Idle,
        Playing,
        End,
        EnteringHighScore,
        Paused
    }

    public GameState gameState = GameState.Idle;

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

        integrityBar.SetActive(false);
        timer.gameObject.SetActive(false);
        spawnerLeft.SetActive(false);
        spawnerRight.SetActive(false);

        //float absoluteIndicatorDistance = Mathf.Abs(minOffset) - Mathf.Abs(maxOffset);
        //float position = absoluteIndicatorDistance * 0.5f;
        currentOffset = minOffset;

        player = ReInput.players.GetPlayer(playerId);
    }

    public static bool TryGetInstance(out IntegrityManager manager)
    {
        manager = instance;
        return (manager != null);
    }

    private void Update()
    {
        if (!waitingForInvoke)
        {
            switch (gameState)
            {
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

                    if (player.GetButtonUp("Pause"))
                    {
                        PauseGame();
                    }

                    if (currentIntegrity <= 0)
                    {
                        DestroyAllRecords();
                        waitingForInvoke = true;
                        allThatIsGoodIsNasty.gameObject.SetActive(true);
                        timer.gameObject.SetActive(false);
                        spawnerLeft.SetActive(false);
                        spawnerRight.SetActive(false);
                        LeaderboardPositionManager leaderboardPositionManager;
                        if (LeaderboardPositionManager.TryGetInstance(out leaderboardPositionManager))
                        {
                            leaderboardPositionManager.SetLeaderboardPosition(leaderboardPositionManager.showInputPosition);
                        }
                        Invoke("SendAllThatIsGoodIsNasty", allThatIsGoodIsNastyLoopTime);
                        Invoke("EnterScore", endGamePause);
                    }

                    break;
                case GameState.End:
                    break;
                case GameState.Paused:
                    if (player.GetButtonUp("Restart"))
                    {
                        UnpauseGame();
                    }
                    else if (player.GetButtonUp("Resume"))
                    {
                        GameManager gameManager;
                        if (GameManager.TryGetInstance(out gameManager))
                        {
                            gameManager.TransitionFromPause();
                        }

                        pauseMenuButtonPromptAB.SetTrigger("outTrigger");
                        TurnOffTimerGameObjects();
                        EndGame();
                    }
                    break;
            }
        }
    }

    #region Private Methods
    private void SendAllThatIsGoodIsNasty()
    {
        allThatIsGoodIsNasty.SetTrigger("outTrigger");
    }

    private void PauseGame()
    {
        gameState = GameState.Paused;
        pauseMenuButtonPromptAB.gameObject.SetActive(true);
    }

    private void UnpauseGame()
    {
        pauseMenuButtonPromptAB.SetTrigger("outTrigger");
        gameState = GameState.Playing;
    }

    private void StartGame()
    {
        gameState = GameState.Playing;
        timer.gameObject.SetActive(true);
        spawnerLeft.SetActive(true);
        spawnerRight.SetActive(true);
        integrityBar.SetActive(true);
    }

    private void UpdateSpawners()
    {
        foreach (RecordSpawner recordSpawner in recordSpawners)
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

    private void EnterScore()
    {
        waitingForInvoke = false;
        LetterInputManager letterInputManager;
        if (LetterInputManager.TryGetInstance(out letterInputManager))
        {
            letterInputManager.gameObject.SetActive(true);
            letterInputManager.ShowLetterInput(currentTime);
        }

        GameManager gameManager;
        if (GameManager.TryGetInstance(out gameManager))
        {
            gameManager.OnEnterScore();
        }

        gameState = GameState.EnteringHighScore;
        ResetGame();
        currentTime = 0f;
        currentIntegrity = maxIntegrity / 2;
    }

    public void EndGame(bool setEndMenuActive = true)
    {
        timer.gameObject.SetActive(false);
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

        for (int i = 0; i < records.Length; i++)
        {
            Destroy(records[i].gameObject);
        }
    }

    private void UpdateUI()
    {
        currentIntegrity = Mathf.Clamp(currentIntegrity, 0, maxIntegrity);
        float currentFloatPercentage = (float)currentIntegrity / (float)maxIntegrity;
        float absoluteIndicatorDistance = Mathf.Abs(minOffset) - Mathf.Abs(maxOffset);
        float position = absoluteIndicatorDistance * currentFloatPercentage;
        targetOffset = minOffset + position;
        currentOffset = Mathf.SmoothDamp(currentOffset, targetOffset, ref integrityVelocity, integritySmooth);
        integrityIndicator.localPosition = new Vector3(currentOffset, integrityIndicator.localPosition.y);
        timer.text = currentTime.ToString("F1");
    }

    private void TriggerMudEffect()
    {
        maxIntegrityBarOrderInLayer++;
        GameObject newMudEffect = Instantiate(mudEffect, integrityBar.transform);
        newMudEffect.GetComponent<SpriteRenderer>().sortingOrder = maxIntegrityBarOrderInLayer;
        integrityBarAnimator.SetTrigger("TriggerMud");
    }

    private void TriggerShimmerEffect()
    {
        maxIntegrityBarOrderInLayer++;
        GameObject newShimmerEffect = Instantiate(shimmerEffect, integrityBar.transform);
        newShimmerEffect.GetComponent<SpriteRenderer>().sortingOrder = maxIntegrityBarOrderInLayer;
        integrityBarAnimator.SetTrigger("TriggerShimmer");
    }
    #endregion

    public void OnBarAnimationEnd()
    {
        maxIntegrityBarOrderInLayer--;
    }

    public void KilledRecord(RecordSpawner.RecordType recordType)
    {
        switch (recordType)
        {
            case RecordSpawner.RecordType.Bad:
                currentIntegrity += badRecordIntegrity;
                TriggerMudEffect();
                break;
            case RecordSpawner.RecordType.Good:
                currentIntegrity += goodRecordIntegrity;
                TriggerShimmerEffect();
                break;
        }
    }

    public void TurnOffTimerGameObjects()
    {
        integrityBar.SetActive(false);
        timer.gameObject.SetActive(false);
    }

    public void StartIntegrityManager()
    {
        StartGame();
    }
}
