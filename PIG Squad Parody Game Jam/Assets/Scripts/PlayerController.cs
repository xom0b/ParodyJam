using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Rewired;
using Prime31;
using System;

public class PlayerController : MonoBehaviour
{
    [Header("Reference Variables")]
    public int playerId = 0;

    public CharacterController2D leftFootCharacterController;
    public CharacterController2D rightFootCharacterController;

    [Header("Movement Variables")]
    public float footSpeed;
    public float maxDistanceBetweenFeet;
    public float distanceBetweenFeetToStartDampening;

    [Header("Debug")]
    public bool showDebugDistanceCircles;

    private Player player;
    private InputState inputThisFrame;

    private struct InputState
    {
        public float leftStickHorizontal;
        public float leftStickVertical;
        public float rightStickHorizontal;
        public float rightStickVertical;
    }

    void Awake()
    {
        player = ReInput.players.GetPlayer(playerId);
    }

    // Update is called once per frame
    void Update()
    {
        GetInput();
        MoveLegs();
    }

    private void MoveLegs()
    {
        float currentDistance = Vector3.Distance(leftFootCharacterController.gameObject.transform.position, rightFootCharacterController.gameObject.transform.position);
       
        Vector3 leftLegDeltaMovement = new Vector3(inputThisFrame.leftStickHorizontal, inputThisFrame.leftStickVertical) * footSpeed;
        Vector3 rightLegDeltaMovement = new Vector3(inputThisFrame.rightStickHorizontal, inputThisFrame.rightStickVertical) * footSpeed;

        
        float newDistance = Vector3.Distance(leftFootCharacterController.gameObject.transform.position + leftLegDeltaMovement, rightFootCharacterController.gameObject.transform.position + rightLegDeltaMovement);
        if (newDistance > maxDistanceBetweenFeet)
        {
            leftLegDeltaMovement *= 1 - (newDistance - maxDistanceBetweenFeet);
            rightLegDeltaMovement *= 1 - (newDistance - maxDistanceBetweenFeet);
        }

        /*
        // pushing away from other foot
        if (newDistance > currentDistance && newDistance > distanceBetweenFeetToStartDampening)
        {
            float newFootSpeed = footSpeed * Mathf.Clamp(1 - (newDistance - distanceBetweenFeetToStartDampening) / (maxDistanceBetweenFeet - distanceBetweenFeetToStartDampening), 0f, 1f);
            Debug.Log(newFootSpeed);
            leftLegDeltaMovement = new Vector3(inputThisFrame.leftStickHorizontal, inputThisFrame.leftStickVertical) * newFootSpeed;
            rightLegDeltaMovement = new Vector3(inputThisFrame.rightStickHorizontal, inputThisFrame.rightStickVertical) * newFootSpeed;
        }
        */

        leftFootCharacterController.move(leftLegDeltaMovement);
        rightFootCharacterController.move(rightLegDeltaMovement);
    }

    private void GetInput()
    {
        inputThisFrame.leftStickHorizontal = player.GetAxis("Left Leg Horizontal");
        inputThisFrame.leftStickVertical = player.GetAxis("Left Leg Vertical");
        inputThisFrame.rightStickHorizontal = player.GetAxis("Right Leg Horizontal");
        inputThisFrame.rightStickVertical = player.GetAxis("Right Leg Vertical");
    }
}
