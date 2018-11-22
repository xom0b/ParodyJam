using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class AnimationTriggerUtility : MonoBehaviour
{
    public UnityEvent methodToCall;
    public UnityEvent methodToCallTwo;
    
    public void TriggerMethod()
    {
        methodToCall.Invoke();
    }

    public void TriggerMethodTwo()
    {
        methodToCallTwo.Invoke();
    }
}
