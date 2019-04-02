﻿using UnityEngine;
using UnityEngine.UI;

public class LeaderboardEntry : MonoBehaviour
{
    public Text nameText;
    public Text scoreText;

    private void Awake()
    {
        nameText = transform.Find("Name").GetComponent<Text>();
        scoreText = transform.Find("Score").GetComponent<Text>();
    }

    public void SetLeaderboardEntry(string nameText, string scoreText)
    {
        this.nameText.text = nameText;
        this.scoreText.text = scoreText;
    }

    public void InitializeHueAnimator(float S, float V, float speed)
    {
        AnimateHue nameAnimator = nameText.GetComponent<AnimateHue>();
        if (nameAnimator != null)
        {
            nameAnimator.saturation = S;
            nameAnimator.value = V;
            nameAnimator.hueSpeed = speed;
            nameAnimator.StartHueAnimation();
        }

        AnimateHue scoreAnimator = scoreText.GetComponent<AnimateHue>();
        if (scoreAnimator != null)
        {
            scoreAnimator.saturation = S;
            scoreAnimator.value = V;
            scoreAnimator.hueSpeed = speed;
            scoreAnimator.StartHueAnimation();
        }
    }

    public void RemoveHueAnimator()
    {
        AnimateHue nameHueAnimator = nameText.gameObject.GetComponent<AnimateHue>();
        AnimateHue scoreHueAnimator = scoreText.gameObject.GetComponent<AnimateHue>();

        nameHueAnimator.ResetColor();
        scoreHueAnimator.ResetColor();
    }
}
