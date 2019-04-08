using System;
using UnityEngine;
using Prime31;

public class RecordController : MonoBehaviour
{
    public GameObject duragAnimation;
    public GameObject overallAnimation;
    public GameObject tophatAnimation;
    public GameObject stinkyAnimation;
    public GameObject newRecordGreen;
    public GameObject newRecordPink;
    public GameObject newRecordPurple;
    public GameObject newRecordStank;
    public GameObject newRecordYellow;
    public GameObject badRecordKillAnimation; //integriyBlast02
    public Vector3 badRecordKillAnimationOffset = new Vector3(0f, 0.254829f, 0f);
    public RecordSpawner.RecordType recordType;
    public float moveSpeed;
    public Vector2 moveDirection;

    private GameObject activeAnimator = null;
    private Vector3 deltaMovement = new Vector3();
    private bool ignoringCollisions = false;

    void OnTriggerEnter2D(Collider2D collision)
    {
        if (!ignoringCollisions)
        {
            if (collision.gameObject.tag == "RecordKiller")
            {
                IntegrityManager integrityManager;
                if (IntegrityManager.TryGetInstance(out integrityManager))
                {
                    integrityManager.KilledRecord(recordType);
                }

                Destroy(gameObject);
            }
            else if (CollidedWithBooth(collision) && activeAnimator != null)
            {
                moveSpeed = 0f;
                ignoringCollisions = true;
                activeAnimator.GetComponent<Animator>().SetTrigger("OnBreak");

                if (recordType == RecordSpawner.RecordType.Bad)
                {
                    GameObject newBadRecordKillAnimation = Instantiate(badRecordKillAnimation);
                    newBadRecordKillAnimation.transform.position = transform.position + badRecordKillAnimationOffset;
                }
            }
        }
    }

    private bool CollidedWithBooth(Collider2D collision)
    {
        bool collidedWithBoot = false;

        if (collision.gameObject.tag == "Foot")
        {
            GameObject leftFoot = GameObject.Find("LeftFoot");
            GameObject rightFoot = GameObject.Find("RightFoot");

            if (collision.gameObject == leftFoot)
            {
                if (leftFoot.GetComponent<FootController>().footMovementState == FootController.FootMovementState.Stomping)
                {
                    collidedWithBoot = true;
                }
            }
            else if (collision.gameObject == rightFoot)
            {
                if (rightFoot.GetComponent<FootController>().footMovementState == FootController.FootMovementState.Stomping)
                {
                    collidedWithBoot = true;
                }
            }
        }

        return collidedWithBoot;
    }

    // Update is called once per frame
    void Update()
    {
        deltaMovement = moveDirection * moveSpeed * Time.deltaTime;
    }

    private void LateUpdate()
    {
        IntegrityManager integrityManager;
        if (IntegrityManager.TryGetInstance(out integrityManager))
        {
            if (integrityManager.gameState != IntegrityManager.GameState.Paused)
            {
                transform.position += deltaMovement;
            }
        }
    }

    public void DestroyRecord()
    {
        Destroy(this);
    }

    public void SetActiveAnimator(GameObject recordAnimator)
    {
        activeAnimator = recordAnimator;
        recordAnimator.SetActive(true);
    }
}
