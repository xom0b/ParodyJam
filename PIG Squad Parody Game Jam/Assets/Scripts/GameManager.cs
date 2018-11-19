using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Rewired;

public class GameManager : MonoBehaviour
{
    [Header("Reference Components")]
    public Transform cameraTransform;

    [Header("Input")]
    public int playerId;

    [Header("Camera Variables")]
    public Vector3 titleCameraPosition;
    public Vector3 mainMenuCameraPosition;
    public Vector3 leaderboardCameraPosition;
    public Vector3 quitCameraPosition;
    public float menuCameraSmoothTime;
    public float timeToQuit;

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

    private Player player;
    private Vector3 currentCameraPosition;
    private Vector3 targetCameraPosition;
    private Vector3 cameraVelocity;

    private float quitTimerDelta;

    private void Awake()
    {
        currentCameraPosition = titleCameraPosition;
        targetCameraPosition = titleCameraPosition;
        cameraTransform.position = titleCameraPosition;
    }

    private void Start()
    {
        player = ReInput.players.GetPlayer(playerId);   
    }

    // Update is called once per frame
    private void Update()
    {
        switch(menuState)
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

        if (currentCameraPosition != targetCameraPosition)
        {
            currentCameraPosition = Vector3.SmoothDamp(currentCameraPosition, targetCameraPosition, ref cameraVelocity, menuCameraSmoothTime);
        }
    }

    private void LateUpdate()
    {
        if (menuState != MenuState.Game)
        {
            cameraTransform.position = currentCameraPosition;
        }
    }

    private void TitleHandler()
    {
        // press A or start
        if (player.GetButtonDown("Start Game"))
        {
            targetCameraPosition = mainMenuCameraPosition;
            menuState = MenuState.MainMenu;
        }
        // press B
        else if (player.GetButtonDown("Resume"))
        {
            quitTimerDelta = 0f;
            targetCameraPosition = quitCameraPosition;
            menuState = MenuState.Quitting;
        }
    }

    private void MainMenuHandler()
    {
        // press Y
        if (player.GetButtonDown("Y"))
        {
            targetCameraPosition = leaderboardCameraPosition;
            menuState = MenuState.Leaderboard;
        }
        // press A or start
        else if (player.GetButtonDown("Start Game"))
        {
            // TODO: START GAME
        }
        // press B
        else if (player.GetButtonDown("Resume"))
        {
            targetCameraPosition = titleCameraPosition;
            menuState = MenuState.Title;
        }
    }

    private void LeaderBoardHandler()
    {
        // press B
        if (player.GetButton("Resume"))
        {
            targetCameraPosition = mainMenuCameraPosition;
            menuState = MenuState.MainMenu;
        }
    }

    private void GameHandler()
    {

    }

    private void QuittingHandler()
    {
        if (quitTimerDelta < timeToQuit)
        {
            quitTimerDelta += Time.deltaTime;
        }
        else
        {
            Application.Quit();
        }
    }

}
