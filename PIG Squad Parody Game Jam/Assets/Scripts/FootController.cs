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

    IEnumerator WaitForFrameAndEndStomp()
    {
        yield return new WaitForEndOfFrame();
        footMovementState = FootMovementState.Idle;
        onFootStompEnd(foot);
    }

#if UNITY_EDITOR
    private void OnDrawGizmos()
    {
        //GizmosUtils.DrawText(GUI.skin, footMovementState.ToString(), transform.position);
    }
#endif

    private void OnCollision(RaycastHit2D raycastHit)
    {
        if (raycastHit.collider.tag == floorTag)
        {
            if (footMovementState == FootMovementState.Stomping)
            {

                StartCoroutine(WaitForFrameAndEndStomp());
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
    #endregion
}
