using System;
using UnityEngine;
using Prime31;
using System.Collections;

public class FootController : MonoBehaviour
{
    public PlayerController.Foot foot;
    public CharacterController2D characterController;
    public Animator animator;
    public event Action<RaycastHit2D> onCollisionEvent;
    public event Action<PlayerController.Foot> onFootStompEnd;
    public SpriteRenderer footSprite;
    public LineRenderer legRenderer;
    public LineRenderer legBackgroundRenderer;

    [HideInInspector]
    public FootMovementState footMovementState = FootMovementState.Idle;
    
    public enum FootMovementState
    {
        Idle,
        Moving,
        Stomping
    }

    private bool waitingForStomp;
    private const float kWaitForStompTime = 0.05f;
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

    IEnumerator WaitForStateChange()
    {
        waitingForStomp = true;
        yield return new WaitForSeconds(kWaitForStompTime);
        waitingForStomp = false;
    }

    private void OnCollision(RaycastHit2D raycastHit)
    {
        if (raycastHit.collider.tag == floorTag)
        {
            if (footMovementState == FootMovementState.Stomping)
            {
                footMovementState = FootMovementState.Idle;
                onFootStompEnd(foot);
                StartCoroutine(WaitForStateChange());
            }
        }
    }
    #endregion

    #region Public Methods
    public void SetFootAndLegOrder(int footOrder, int legOrder, int legBackgroundOrder)
    {
        footSprite.sortingOrder = footOrder;
        legRenderer.sortingOrder = legOrder;
        legBackgroundRenderer.sortingOrder = legBackgroundOrder;
    }

    public void TriggerStomp(float stompSpeed)
    {
        if (footMovementState == FootMovementState.Moving)
        {
            animator.SetTrigger("StompBoot");
            footMovementState = FootMovementState.Stomping;
            currentStompSpeed = stompSpeed;
        }
    }

    public void Move(Vector2 deltaMovement)
    {
        switch (footMovementState)
        {
            case FootMovementState.Idle:
                animator.SetTrigger("LiftBoot");
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

    public bool WasOrIsStomping()
    {
        return footMovementState == FootMovementState.Stomping || waitingForStomp;
    }
    #endregion
}
