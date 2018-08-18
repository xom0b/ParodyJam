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
            Handles.DrawWireDisc(playerController.leftFootCharacterController.gameObject.transform.position, Vector3.forward, playerController.maxDistanceBetweenFeet);
            Handles.DrawWireDisc(playerController.rightFootCharacterController.gameObject.transform.position, Vector3.forward, playerController.maxDistanceBetweenFeet);

            Handles.color = Color.grey;
            Handles.DrawWireDisc(playerController.leftFootCharacterController.gameObject.transform.position, Vector3.forward, playerController.distanceBetweenFeetToStartDampening);
            Handles.DrawWireDisc(playerController.rightFootCharacterController.gameObject.transform.position, Vector3.forward, playerController.distanceBetweenFeetToStartDampening);
        }
    }
}
#endif

