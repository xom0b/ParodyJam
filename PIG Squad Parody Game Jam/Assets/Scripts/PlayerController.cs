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

    public FootController leftFootController;
    public FootController rightFootController;
    public Transform bodyTransform;
    public float dampTime = 1f;

    [Header("Movement Variables")]
    public float footSpeed;
    public float footSmoothSpeed;
    public float stompSpeed;
    public float maxFootDistance;
    public float minFootDistance;

    [Header("Debug")]
    public bool showDebugDistanceCircles;

    private float oscillator = 0f;
    private Player player;
    private InputState inputThisFrame;

    private Vector3 movingTowards = new Vector3();
    private Vector3 smoothDampVelocty = Vector3.zero;

    private Foot currentFoot = Foot.None;

    public enum Foot
    {
        None,
        Left,
        Right
    }

    private struct InputState
    {
        public float leftStickHorizontal;
        public float leftStickVertical;
        public Vector2 leftStickVector;
        public float rightStickHorizontal;
        public float rightStickVertical;
        public Vector2 rightStickVector;
        public bool stomp;
        public bool onStompDown;
        public bool onStompUp;
    }

    private void Awake()
    {
        player = ReInput.players.GetPlayer(playerId);
    }

    private void Start()
    {
        leftFootController.onCollisionEvent += OnFootCollision;
        rightFootController.onCollisionEvent += OnFootCollision;
        leftFootController.onFootStompEnd += OnFootStompEnd;
        rightFootController.onFootStompEnd += OnFootStompEnd;
        movingTowards = transform.position;
    }

    // Update is called once per frame
    private void Update()
    {
        GetInput();
        HandleFeet();
    }

    private bool oscillatorMovingUp = true;

    private void OnFootCollision(RaycastHit2D raycastHit)
    {
        if (raycastHit.collider.gameObject == leftFootController.gameObject)
        {
            Debug.Log("Collided Left Foot!");
        }
        else if (raycastHit.collider.gameObject == rightFootController.gameObject)
        {
            Debug.Log("Collided Right Foot!");
        }
    }

    private void OnFootStompEnd(Foot leg)
    {
        currentFoot = Foot.None;
    }

    private void HandleFeet()
    {
        switch (currentFoot)
        {
            case Foot.None:
                break;
            case Foot.Left:
                if (inputThisFrame.onStompDown)
                {
                    leftFootController.TriggerStomp(stompSpeed);
                }
                else
                {
                    MoveRubberBand(leftFootController);
                }

                break;
            case Foot.Right:
                if (inputThisFrame.onStompDown)
                {
                    rightFootController.TriggerStomp(stompSpeed);
                }
                else
                {
                    MoveRubberBand(rightFootController);
                }

                break;
        }
    }

    private void MoveRubberBand(FootController foot)
    {
        Vector3 stickDirection = (foot.foot == Foot.Right) ? inputThisFrame.rightStickVector.normalized : inputThisFrame.leftStickVector.normalized;
        Vector3 newDirection = Vector3.MoveTowards(movingTowards, stickDirection, footSmoothSpeed * Time.deltaTime);
        foot.Move(newDirection * Time.deltaTime * footSpeed);
        movingTowards = newDirection;
    }

    private void GetInput()
    {
        inputThisFrame.leftStickHorizontal = player.GetAxis("Left Leg Horizontal");
        inputThisFrame.leftStickVertical = player.GetAxis("Left Leg Vertical");
        inputThisFrame.leftStickVector = new Vector2(inputThisFrame.leftStickHorizontal, inputThisFrame.leftStickVertical);
        inputThisFrame.rightStickHorizontal = player.GetAxis("Right Leg Horizontal");
        inputThisFrame.rightStickVertical = player.GetAxis("Right Leg Vertical");
        inputThisFrame.rightStickVector = new Vector2(inputThisFrame.rightStickHorizontal, inputThisFrame.rightStickVertical);
        inputThisFrame.stomp = player.GetButton("Stomp");
        inputThisFrame.onStompDown = player.GetButtonDown("Stomp");
        inputThisFrame.onStompUp = player.GetButtonUp("Stomp");

        if (currentFoot == Foot.None)
        {
            if (inputThisFrame.leftStickVector.magnitude > inputThisFrame.rightStickVector.magnitude && inputThisFrame.leftStickVector.magnitude > 0f)
            {
                currentFoot = Foot.Left;
                movingTowards = inputThisFrame.leftStickVector;
            }
            else if (inputThisFrame.rightStickVector.magnitude > inputThisFrame.leftStickVector.magnitude && inputThisFrame.rightStickVector.magnitude > 0f)
            {
                currentFoot = Foot.Right;
                movingTowards = inputThisFrame.rightStickVector;
            }
        }
    }
}
