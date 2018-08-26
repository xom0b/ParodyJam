using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OnTriggerEnterTest : MonoBehaviour
{

    private void OnTriggerEnter2D(Collider2D collision)
    {
        Debug.Log(gameObject + " colliding with: " + collision.gameObject);
    }

    private void OnCollisionEnter2D(Collision2D collision)
    {
        Debug.Log(gameObject + " Collided with: " + collision.gameObject);
    }
}
