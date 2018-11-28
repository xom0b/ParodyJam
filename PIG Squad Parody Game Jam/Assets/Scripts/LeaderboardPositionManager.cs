using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LeaderboardPositionManager : MonoBehaviour
{
    public RectTransform rectTransform;
    public Vector3 showAllPosition;
    public Vector3 showInputPosition;
    public float leaderboardDamp;

    private Vector3 targetLeaderboardPosition;
    private Vector3 leaderboardVelocity;

    private static LeaderboardPositionManager instance;

    private void Awake()
    {
        instance = this;
    }

    private void Start()
    {
        SetLeaderboardPosition(showAllPosition);
    }

    public static bool TryGetInstance(out LeaderboardPositionManager manager)
    {
        manager = instance;
        return (manager != null);
    }

    public void SetTargetLeaderboardPosition(Vector3 newPosition)
    {
        targetLeaderboardPosition = newPosition;
    }

    public void SetLeaderboardPosition(Vector3 newPosition)
    {
        rectTransform.position = newPosition;
        targetLeaderboardPosition = newPosition;
        gameObject.SetActive(false);
        gameObject.SetActive(true);
    }    

    void Update()
    {
        if (rectTransform.position != targetLeaderboardPosition)
        {
            rectTransform.position = Vector3.SmoothDamp(rectTransform.position, targetLeaderboardPosition, ref leaderboardVelocity, leaderboardDamp);
            gameObject.SetActive(false);
            gameObject.SetActive(true);
        }
    }
}
