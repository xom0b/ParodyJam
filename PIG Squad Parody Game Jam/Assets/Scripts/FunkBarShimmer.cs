using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FunkBarShimmer : MonoBehaviour
{
    public void TriggerDestroy()
    {
        IntegrityManager integrityManager;
        if (IntegrityManager.TryGetInstance(out integrityManager))
        {
            integrityManager.OnBarAnimationEnd();
        }

        Destroy(gameObject);
    }
}
