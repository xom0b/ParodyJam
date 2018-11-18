using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraFollow : MonoBehaviour
{
    public Transform cameraTransform;
    public bool ignoreXPosition;
    public bool ignoreYPosition;
    public bool ignoreZPosition;

    private bool followingEnabled = false;
    private Vector3 positionLastFrame;

    void LateUpdate()
    {
        if (followingEnabled)
        {
            FollowCamera();
        }
        else
        {
            positionLastFrame = cameraTransform.position;
        }
    }

    private void FollowCamera()
    {
        float deltaX = ignoreXPosition ? 0f : cameraTransform.position.x - positionLastFrame.x;
        float deltaY = ignoreXPosition ? 0f : cameraTransform.position.y - positionLastFrame.y;
        float deltaZ = ignoreXPosition ? 0f : cameraTransform.position.z - positionLastFrame.z;
        transform.position += new Vector3(deltaX, deltaY, deltaZ);
    }

    public void SetFollowingEnabled(bool enabled)
    {
        followingEnabled = enabled;
    }
}
