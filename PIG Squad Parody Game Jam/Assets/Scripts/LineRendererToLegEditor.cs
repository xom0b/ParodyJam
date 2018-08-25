using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(LineRendererToLeg))]
public class LineRendererToLegEditor : Editor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        LineRendererToLeg lineRendererToLeg = (LineRendererToLeg)target;

        if (GUILayout.Button("Set Line Renderer"))
        {
            lineRendererToLeg.EditorSetLineRenderer();
        }
    }
    public void OnSceneGUI()
    {
        
    }

}
