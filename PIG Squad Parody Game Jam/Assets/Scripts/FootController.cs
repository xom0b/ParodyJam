using System;
using UnityEngine;
using Prime31;

public class FootController : MonoBehaviour
{
    public PlayerController.Foot foot;
    public CharacterController2D characterController;
    public event Action<RaycastHit2D> onCollisionEvent;
    public event Action<PlayerController.Foot> onFootStompEnd;

    [HideInInspector]
    public FootMovementState footMovementState = FootMovementState.Idle;
    
    public enum FootMovementState
    {
        Idle,
        Moving,
        Stomping
    }

    private float currentStompSpeed = 0f;
    private const string floorTag = "Floor";

    #region MonoBehaviour
    private void Start()
    {
        characterController.onControllerCollidedEvent += OnCollision;
    }

    private void Update()
    {
        switch (footMovementState)
        {
            case FootMovementState.Idle:
                break;
            case FootMovementState.Moving:
                break;
            case FootMovementState.Stomping:
                StompHandler();
                break;
        }
    }
    #endregion

    #region Private Methods
    private void StompHandler()
    {
        Vector2 stompDirection = Vector2.down;
        characterController.move(stompDirection.normalized * currentStompSpeed);
    }

    private void OnStompEnd()
    {
        Debug.Log("On Stomp End!");
        footMovementState = FootMovementState.Idle;
        onFootStompEnd(foot);
    }

    private void OnCollision(RaycastHit2D raycastHit)
    {
        if (raycastHit.collider.tag == floorTag)
        {
            if (footMovementState == FootMovementState.Stomping || footMovementState == FootMovementState.Moving)
            {
                OnStompEnd();
            }
        }
    }
    #endregion

    #region Public Methods
    public void TriggerStomp(float stompSpeed)
    {
        if (footMovementState == FootMovementState.Moving)
        {
            footMovementState = FootMovementState.Stomping;
            currentStompSpeed = stompSpeed;
        }
    }

    public void Move(Vector2 deltaMovement)
    {
        switch (footMovementState)
        {
            case FootMovementState.Idle:
                footMovementState = FootMovementState.Moving;
                characterController.move(deltaMovement);
                break;
            case FootMovementState.Moving:
                characterController.move(deltaMovement);
                break;
            case FootMovementState.Stomping:
                break;
        }
    }
    #endregion
}
