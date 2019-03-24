using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DestroyAnimationUtility : MonoBehaviour
{
    public void DestroyThis()
    {
        StartCoroutine(DestroyNextFrame());
    }

    public IEnumerator DestroyNextFrame()
    {
        yield return new WaitForEndOfFrame();

#if UNITY_EDITOR
        DestroyImmediate(this.gameObject);
#else
        Destroy(this.gameObject);
#endif
    }
}
