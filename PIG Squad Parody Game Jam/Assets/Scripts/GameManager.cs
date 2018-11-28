using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Rewired;

public class GameManager : MonoBehaviour
{
    [Header("Reference Components")]
    public PlayerController playerController;
    public Transform cameraTransform;
    public Animator titleAnimator;
    public Animator buttonPromptAB;
    public Animator buttonPromptABXY;
    public Animator buttonPromptB;
    public Animator buttonPromptA;
    public Animator credits;
    public GameObject tutorialUI;

    [Header("Input")]
    public int playerId;

    [Header("Camera Variables")]
    public Vector3 titleCameraPosition;
    public Vector3 mainMenuCameraPosition;
    public Vector3 leaderboardCameraPosition;
    public Vector3 quitCameraPosition;
    public float menuCameraSmoothTime;
    public float timeToQuit;
    public float panUpWaitTime;
    public float transitionToMainMenuWaitTime;
    public float transitionToLeaderboardWaitTime;
    public float transitionToTitleWaitTime;

    [HideInInspector]
    public MenuState menuState = MenuState.Title;
    public enum MenuState
    {
        Title,
        MainMenu,
        Game,
        Leaderboard,
        Quitting
    }

    private static GameManager instance;

    private Player player;
    private Vector3 currentCameraPosition;
    private Vector3 targetCameraPosition;
    private Vector3 cameraVelocity;
    private float quitTimerDelta;
    private bool waitingForTransition;
    private bool hasEnteredHighScore;

    private void Awake()
    {
        currentCameraPosition = titleCameraPosition;
        targetCameraPosition = titleCameraPosition;
        cameraTransform.position = titleCameraPosition;
        instance = this;
    }

    public static bool TryGetInstance(out GameManager manager)
    {
        manager = instance;
        return (manager != null);
    }

    private void Start()
    {
        buttonPromptAB.gameObject.SetActive(false);
        buttonPromptABXY.gameObject.SetActive(false);
        buttonPromptB.gameObject.SetActive(false);
        player = ReInput.players.GetPlayer(playerId);   
    }

    // Update is called once per frame
    private void Update()
    {
        if (!waitingForTransition)
        {
            switch (menuState)
            {
                case MenuState.Title:
                    TitleHandler();
                    break;
                case MenuState.MainMenu:
                    MainMenuHandler();
                    break;
                case MenuState.Game:
                    GameHandler();
                    break;
                case MenuState.Leaderboard:
                    LeaderBoardHandler();
                    break;
                case MenuState.Quitting:
                    QuittingHandler();
                    break;
            }
        }

        if (currentCameraPosition != targetCameraPosition)
        {
            currentCameraPosition = Vector3.SmoothDamp(currentCameraPosition, targetCameraPosition, ref cameraVelocity, menuCameraSmoothTime);
        }
    }

    private void GameHandler()
    {

    }

    private void LateUpdate()
    {
        cameraTransform.position = currentCameraPosition;
    }

    private void TitleHandler()
    {
        // press A or start
        if (player.GetButtonDown("Start Game"))
        {
            waitingForTransition = true;
            titleAnimator.SetTrigger("titleOutTrigger");
            buttonPromptAB.SetTrigger("outTrigger");
            Invoke("WaitForPanUp", panUpWaitTime);            
        }
        // press B
        else if (player.GetButtonDown("Resume"))
        {
            titleAnimator.SetTrigger("titleOutTrigger");
            buttonPromptAB.SetTrigger("outTrigger");
            quitTimerDelta = 0f;
            targetCameraPosition = quitCameraPosition;
            SetMenuState(MenuState.Quitting);
        }
    }

    private void WaitForPanUp()
    {
        targetCameraPosition = mainMenuCameraPosition;
        Invoke("TransitionToMainMenu", transitionToMainMenuWaitTime);
    }

    private void TransitionToMainMenu()
    {
        tutorialUI.SetActive(true);
        waitingForTransition = false;
        buttonPromptABXY.gameObject.SetActive(true);
        SetMenuState(MenuState.MainMenu);
    }

    private void MainMenuHandler()
    {
        // press Y
        if (player.GetButtonDown("Y"))
        {
            waitingForTransition = true;
            targetCameraPosition = leaderboardCameraPosition;
            buttonPromptABXY.SetTrigger("outTrigger");
            Invoke("TransitionToLeaderboard", transitionToLeaderboardWaitTime);
        }
        // press A or start - START GAME
        else if (player.GetButtonDown("Start Game"))
        {
            IntegrityManager integrityManager;
            if (IntegrityManager.TryGetInstance(out integrityManager))
            {
                tutorialUI.SetActive(false);

                if (credits.gameObject.activeInHierarchy)
                {
                    credits.SetTrigger("outTrigger");
                }

                if (buttonPromptABXY.gameObject.activeInHierarchy)
                {
                    buttonPromptABXY.SetTrigger("outTrigger");
                }

                integrityManager.StartIntegrityManager();
                SetMenuState(MenuState.Game);
            }
        }
        // press B
        else if (player.GetButtonDown("Resume"))
        {
            buttonPromptABXY.SetTrigger("outTrigger");
            targetCameraPosition = titleCameraPosition;
            Invoke("TransitionToTitle", transitionToTitleWaitTime);
        }
        else if (player.GetButtonDown("X"))
        {
            if (credits.gameObject.activeInHierarchy)
            {
                credits.SetTrigger("outTrigger");
            }
            else
            {
                credits.gameObject.SetActive(true);
                credits.SetTrigger("inTrigger");
            }
        }
    }

    private void TransitionToLeaderboard()
    {
        waitingForTransition = false;
        buttonPromptB.gameObject.SetActive(true);
        SetMenuState(MenuState.Leaderboard);
    }

    private void TransitionToTitle()
    {
        waitingForTransition = false;
        buttonPromptAB.gameObject.SetActive(true);
        titleAnimator.gameObject.SetActive(true);
        SetMenuState(MenuState.Title);
    }

    private void LeaderBoardHandler()
    {
        // press B
        if (player.GetButton("Resume"))
        {
            buttonPromptB.SetTrigger("outTrigger");
            targetCameraPosition = mainMenuCameraPosition;
            Invoke("TransitionToMainMenu", transitionToMainMenuWaitTime);
        }
    }

    private void QuittingHandler()
    {
        if (quitTimerDelta < timeToQuit)
        {
            quitTimerDelta += Time.deltaTime;
        }
        else
        {
#if UNITY_EDITOR
            UnityEditor.EditorApplication.isPlaying = false;
#else
            Application.Quit();
#endif
        }
    }

    public void TransitionFromPause()
    {
        Invoke("TempTransitionFromPause", 0.5f);
    }

    private void TempTransitionFromPause()
    {
        SetMenuState(MenuState.MainMenu);
        buttonPromptABXY.gameObject.SetActive(true);
    }

    public void OnEnterScore()
    {
        Invoke("TriggerButtonAPrompt", transitionToLeaderboardWaitTime);
        playerController.SetPlayerActive(false);
        targetCameraPosition = leaderboardCameraPosition;
        hasEnteredHighScore = false;
    }

    private void TriggerButtonAPrompt()
    {
        buttonPromptA.gameObject.SetActive(true);
        IntegrityManager integrityManager;
        if (IntegrityManager.TryGetInstance(out integrityManager))
        {
            integrityManager.TurnOffTimerGameObjects();
        }
    }

    public void OnFinishedEnteringHighScore()
    {
        Invoke("TransitionToLeaderboard", transitionToLeaderboardWaitTime);
        buttonPromptA.SetTrigger("outTrigger");
        hasEnteredHighScore = true;
    }

    public void SetMenuState(MenuState nextState)
    {
        switch (nextState)
        {
            case MenuState.MainMenu:
                playerController.SetPlayerActive(true);
                break;
            case MenuState.Leaderboard:
                playerController.SetPlayerActive(false);
                break;
            case MenuState.Title:
                playerController.SetPlayerActive(false);
                break;
            case MenuState.Game:
                break;
        }

        menuState = nextState;
    }

    public void TurnOffGameObject(GameObject gO)
    {
        gO.SetActive(false);
    }

    public void OnStartAnimationCompleteCallback()
    {
        buttonPromptAB.gameObject.SetActive(true);
    }
}
