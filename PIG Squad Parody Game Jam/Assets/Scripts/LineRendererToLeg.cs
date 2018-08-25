using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LineRendererToLeg : MonoBehaviour
{
    public LineRenderer lineRenderer;
    public List<Transform> legJoints = new List<Transform>();

    private List<Vector3> legJointPositions = new List<Vector3>();

    void Start()
    {
        lineRenderer.positionCount = legJoints.Count;
        UpdateLineRendererPoints();
    }

    private void Update()
    {
        UpdateLineRendererPoints();
    }

    private void UpdateLineRendererPoints()
    {
        for (int i = 0; i < legJoints.Count; i++)
        {
            lineRenderer.SetPosition(i, legJoints[i].position);
        }
    }



    public void EditorSetLineRenderer()
    {
        Start();
    }
}
