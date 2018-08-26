using System;
using UnityEngine;
using Prime31;

public class RecordController : MonoBehaviour
{
    public SpriteRenderer spriteRenderer;
    public RecordSpawner.RecordType recordType;
    public RecordSpawner.Costume recordFlavor;
    public float moveSpeed;
    public Vector2 moveDirection;
    public event Action<RecordController, Collider2D> onTriggerEnter;

    private Vector3 deltaMovement = new Vector3();

    void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.gameObject.tag == "RecordKiller")
        {
            onTriggerEnter(this, collision);
            Destroy(gameObject);
        }

        if (collision.gameObject.tag == "Foot")
        {
            onTriggerEnter(this, collision);
        }
    }

    // Update is called once per frame
    void Update()
    {
        deltaMovement = moveDirection * moveSpeed * Time.deltaTime;
    }

    private void LateUpdate()
    {
        transform.position += deltaMovement;
    }
}
