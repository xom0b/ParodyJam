﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DestroyAnimationUtility : MonoBehaviour
{
    public void DestroyThis()
    {
        Destroy(this.gameObject);
    }
}
