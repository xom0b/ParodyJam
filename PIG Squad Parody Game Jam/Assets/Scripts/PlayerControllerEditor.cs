using System.Collections;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
[CustomEditor(typeof(PlayerController))]
public class PlayerControllerEditor : Editor
{
    void OnSceneGUI()
    {
        base.OnInspectorGUI();

        PlayerController playerController = (PlayerController)target;

        if (playerController.showDebugDistanceCircles)
        {
            Handles.color = Color.black;
            Handles.DrawWireDisc(playerController.leftFootController.gameObject.transform.position, Vector3.forward, playerController.maxFootDistance);
            Handles.DrawWireDisc(playerController.rightFootController.gameObject.transform.position, Vector3.forward, playerController.maxFootDistance);

            Handles.color = Color.grey;
            Handles.DrawWireDisc(playerController.leftFootController.gameObject.transform.position, Vector3.forward, playerController.minFootDistance);
            Handles.DrawWireDisc(playerController.rightFootController.gameObject.transform.position, Vector3.forward, playerController.minFootDistance);
        }
    }
}
#endif

