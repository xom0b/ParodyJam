using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class CubeDOTweenTest : MonoBehaviour
{   
    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            Sequence mySequence = DOTween.Sequence();
            // Add a movement tween at the beginning
            //mySequence.Append(transform.DOMoveX(45, 1));
            mySequence.Append(transform.DORotate(new Vector3(0, 0, 90), 1)).AppendInterval(1f);
            // Add a rotation tween as soon as the previous one is finished
            mySequence.Append(transform.DORotate(new Vector3(0, 0, 180), 1));
            // Delay the whole Sequence by 1 second
            //mySequence.PrependInterval(1);
            // Insert a scale tween for the whole duration of the Sequence
            //mySequence.Insert(0, transform.DOScale(new Vector3(3, 3, 3), mySequence.Duration()));
        }
    }
}
