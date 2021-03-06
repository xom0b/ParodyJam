﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;


public class AnimateHue : MonoBehaviour
{
    Text text;
    public float saturation;
    public float value;
    public float hueSpeed;
    public bool animateOnStart = false;

    private bool animatingHue = false;
    private Color colorBeforeAnimating;

    private void Start()
    {
        if (animateOnStart)
        {
            StartHueAnimation();
        }
    }

    public void StartHueAnimation()
    {
        if (text == null)
        {
            text = GetComponent<Text>();
        }

        colorBeforeAnimating = text.color;
        animatingHue = true;
    }

    public void ResetColor()
    {
        text.color = colorBeforeAnimating;
        animatingHue = false;
    }

    private void Update()
    {
        if (animatingHue)
        {
            float currentHue = GetHue(text.color);
            currentHue += hueSpeed * Time.deltaTime;
            currentHue = currentHue % 1;
            text.color = Color.HSVToRGB(currentHue, saturation, value);
        }
    }

    private float GetHue(Color color)
    {
        float H;
        float S;
        float V;
        Color.RGBToHSV(color, out H, out S, out V);
        return H;
    }
}
