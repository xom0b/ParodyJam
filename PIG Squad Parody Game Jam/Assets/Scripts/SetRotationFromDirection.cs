using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SetRotationFromDirection : MonoBehaviour
{
    public GameObject joint;

    // Update is called once per frame
    void Update()
    {
        Vector3 direction = transform.position - joint.transform.position;
        transform.rotation = Quaternion.LookRotation(direction, Vector3.forward) * Quaternion.LookRotation(Vector3.up);
        //transform.rotation = Quaternion.LookRotation(direction) * Quaternion.LookRotation(Vector3.right);
    }
}
