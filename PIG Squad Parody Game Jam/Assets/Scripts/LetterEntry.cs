using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using Rewired;
using System;

public class LetterEntry : MonoBehaviour
{
    public int playerId;
    public Text character;
    public GameObject arrowTop;
    public GameObject arrowBot;

    [HideInInspector]
    private AlphabetCharacter currentLetter = AlphabetCharacter.a;
    private enum AlphabetCharacter
    {
        a = 0,
        b = 1,
        c = 2,
        d = 3,
        e = 4,
        f = 5,
        g = 6,
        h = 7,
        i = 8,
        j = 9,
        k = 10,
        l = 11,
        m = 12,
        n = 13,
        o = 14,
        p = 15,
        q = 16,
        r = 17,
        s = 18,
        t = 19,
        u = 20,
        v = 21,
        w = 22,
        x = 23,
        y = 24,
        z = 25
    }
    private Player player;
    private bool isActive = false;

    // thumbstick scrolling variables
    private AxisScrollState positiveScrollState = AxisScrollState.Idle;
    private AxisScrollState negativeScrollState = AxisScrollState.Idle;
    private enum AxisScrollState
    {
        Idle,
        SingleScroll,
        Scrolling
    }

    private float currentTimeToScroll = 0f;
    private float currentScrollTime = 0f;

    private void Start()
    {
        if (character == null)
        {
            Debug.Log("NULL: ", gameObject);
        }
        character.text = currentLetter.ToString();
        player = ReInput.players.GetPlayer(playerId);
    }

    // Update is called once per frame
    void Update()
    {
        if (isActive)
        {
            Debug.Log(positiveScrollState.ToString());
            LetterInputManager letterInputManager;
            if (LetterInputManager.TryGetInstance(out letterInputManager))
            {
                if (player.GetButtonDown("DPadUp") || ShouldThumbstickScroll(player.GetAxis("Left Leg Vertical"), letterInputManager.GetThumbstickScrollDeadzone(), GreaterThan, ref positiveScrollState))
                {
                    ModifyLetter(-1);
                }
                else if (player.GetButtonDown("DPadDown") || ShouldThumbstickScroll(player.GetAxis("Left Leg Vertical"), -letterInputManager.GetThumbstickScrollDeadzone(), LessThan, ref negativeScrollState))
                {
                    ModifyLetter(1);
                }
            }
        }
    }

    void ModifyLetter(int change)
    {
        int newLetter = ((int)currentLetter) + change;

        if (newLetter > 25)
        {
            newLetter = 0;
        }
        else if (newLetter < 0)
        {
            newLetter = 25;
        }

        currentLetter = (AlphabetCharacter)newLetter;
        character.text = currentLetter.ToString();
    }

    public void SetArrowsActive(bool active)
    {
        isActive = active;
        arrowBot.SetActive(active);
        arrowTop.SetActive(active);
    }

    private bool LessThan(float lhs, float rhs)
    {
        return lhs < rhs;
    }

    private bool GreaterThan(float lhs, float rhs)
    {
        return lhs > rhs;
    }

    private bool ShouldThumbstickScroll(float axisValue, float threshold, Func<float, float, bool> scrollFunc, ref AxisScrollState scrollState)
    {
        bool shouldScroll = false;
        LetterInputManager letterInputManager;
        if (LetterInputManager.TryGetInstance(out letterInputManager))
        {
            if (scrollState == positiveScrollState && scrollFunc(axisValue, threshold))
            {
                Debug.Log("test");
            }

            switch (scrollState)
            {
                case AxisScrollState.Idle:
                    if (scrollFunc(axisValue, threshold))
                    {
                        shouldScroll = true;
                        scrollState = AxisScrollState.SingleScroll;
                        currentTimeToScroll = 0f;
                    }
                    break;
                case AxisScrollState.SingleScroll:
                    if (scrollFunc(axisValue, threshold))
                    {
                        currentTimeToScroll += Time.deltaTime;
                        if (currentTimeToScroll > letterInputManager.timeToScroll)
                        {
                            shouldScroll = true;
                            currentScrollTime = 0f;
                            scrollState = AxisScrollState.Scrolling;
                        }
                    }
                    else
                    {
                        scrollState = AxisScrollState.Idle;
                    }
                    break;
                case AxisScrollState.Scrolling:
                    if (scrollFunc(axisValue, threshold))
                    {
                        currentScrollTime += Time.deltaTime;
                        if (currentScrollTime > letterInputManager.scrollSpeed)
                        {
                            currentScrollTime -= letterInputManager.scrollSpeed;
                            shouldScroll = true;
                        }
                    }
                    else
                    {
                        scrollState = AxisScrollState.Idle;
                        currentScrollTime = 0f;
                        currentTimeToScroll = 0f;
                    }
                    break;
            }
        }

        return shouldScroll;
    }
}
