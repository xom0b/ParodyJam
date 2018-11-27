using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using Rewired;
using System;

public class LetterInputManager : MonoBehaviour
{
    public int playerId;
    public LetterEntry firstLetter;
    public LetterEntry secondLetter;
    public LetterEntry thirdLetter;
    public Text scoreText;

    public float timeToScroll;
    public float scrollSpeed;

    private static LetterInputManager instance;

    // thumbstick scrolling variables
    private Player player;
    private InputState currentInputState;
    [HideInInspector]
    private const float kMenuDeadZone = 0.2f;

    private enum InputState
    {
        firstLetter = 0,
        secondLetter = 1,
        thirdLetter = 2
    }

    public static bool TryGetInstance(out LetterInputManager manager)
    {
        manager = instance;
        return (manager != null);
    }

    private void Awake()
    {
        instance = this;
    }

    private void Start()
    {
        player = ReInput.players.GetPlayer(playerId);
        scoreText.gameObject.SetActive(false);
        firstLetter.gameObject.SetActive(false);
        secondLetter.gameObject.SetActive(false);
        thirdLetter.gameObject.SetActive(false);
        gameObject.SetActive(false);
    }

    private void Update()
    {
        if (player.GetButtonDown("DPadRight") || (player.GetAxis("Left Leg Horizontal") > kMenuDeadZone && player.GetAxisPrev("Left Leg Horizontal") <= kMenuDeadZone))
        { 
            MoveLetterInput(1);
        }
        else if (player.GetButtonDown("DPadLeft") || (player.GetAxis("Left Leg Horizontal") < -kMenuDeadZone && player.GetAxisPrev("Left Leg Horizontal") >= -kMenuDeadZone))
        {
            MoveLetterInput(-1);
        }
        else if (player.GetButtonDown("Start Game"))
        {
            if (currentInputState == InputState.thirdLetter)
            {
                IntegrityManager integrityManager;
                if (IntegrityManager.TryGetInstance(out integrityManager))
                {
                    scoreText.gameObject.SetActive(false);
                    firstLetter.gameObject.SetActive(false);
                    secondLetter.gameObject.SetActive(false);
                    thirdLetter.gameObject.SetActive(false);
                    integrityManager.EndGame();
                    GameManager gameManager;
                    if (GameManager.TryGetInstance(out gameManager))
                    {
                        gameManager.OnFinishedEnteringHighScore();
                    }
                    gameObject.SetActive(false);
                }
            }
            else
            {
                MoveLetterInput(1);
            }
        }
    }

    public float GetThumbstickScrollDeadzone()
    {
        return kMenuDeadZone;
    }

    public void ShowLetterInput(float score)
    {
        scoreText.gameObject.SetActive(true);
        scoreText.text = score.ToString();
        firstLetter.gameObject.SetActive(true);
        secondLetter.gameObject.SetActive(true);
        thirdLetter.gameObject.SetActive(true);
        currentInputState = InputState.firstLetter;
        MoveLetterInput(0);
    }

    // 1 is right
    // -1 is left
    public void MoveLetterInput(int change)
    {
        int newInputState = (int)currentInputState + change;

        if (newInputState > 2)
        {
            newInputState = 0;
        }
        else if (newInputState < 0)
        {
            newInputState = 2;
        }

        currentInputState = (InputState)newInputState;

        switch (currentInputState)
        {
            case InputState.firstLetter:
                firstLetter.SetArrowsActive(true);
                secondLetter.SetArrowsActive(false);
                thirdLetter.SetArrowsActive(false);
                break;
            case InputState.secondLetter:
                secondLetter.SetArrowsActive(true);
                firstLetter.SetArrowsActive(false);
                thirdLetter.SetArrowsActive(false);
                break;
            case InputState.thirdLetter:
                thirdLetter.SetArrowsActive(true);
                firstLetter.SetArrowsActive(false);
                secondLetter.SetArrowsActive(false);
                break;
        }
    }
}
