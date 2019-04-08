using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RecordStumpScoreEffectSpawner : MonoBehaviour
{
    public Animator trunkAnimator;

    public void SpawnRecordKillEffect(RecordController recordController)
    {
        if (recordController.recordType == RecordSpawner.RecordType.Bad)
        {
            trunkAnimator.SetTrigger("BlastMud");
        }
        else if (recordController.activeAnimator != null)
        {
            if (recordController.activeAnimator == recordController.newRecordGreen)
            {
                trunkAnimator.SetTrigger("BlastGreen");
            }
            else if (recordController.activeAnimator == recordController.newRecordPink)
            {
                trunkAnimator.SetTrigger("BlastPink");
            }
            else if (recordController.activeAnimator == recordController.newRecordPurple)
            {
                trunkAnimator.SetTrigger("BlastPurple");
            }
            else if (recordController.activeAnimator == recordController.newRecordYellow)
            {
                trunkAnimator.SetTrigger("BlastYellow");
            }
        }
    }

    private void OnTriggerEnter2D(Collider2D collision)
    {
        RecordController collidedController = collision.gameObject.GetComponent<RecordController>();
        if (collidedController != null)
        {
            SpawnRecordKillEffect(collidedController);
        }
    }
}
