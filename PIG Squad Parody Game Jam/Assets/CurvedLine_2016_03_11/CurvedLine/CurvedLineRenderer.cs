﻿using UnityEngine;
using System.Collections;
using System.Collections.Generic;

[RequireComponent( typeof(LineRenderer) )]
public class CurvedLineRenderer : MonoBehaviour 
{
    public List<CurvedLinePoint> curvedLinePoints = new List<CurvedLinePoint>();
    public bool reverseSegments = false;
	//PUBLIC
	public float lineSegmentSize = 0.15f;
	public float lineWidth = 0.1f;
	[Header("Gizmos")]
	public bool showGizmos = true;
	public float gizmoSize = 0.1f;
	public Color gizmoColor = new Color(1,0,0,0.5f);
	//PRIVATE
	private CurvedLinePoint[] linePoints = new CurvedLinePoint[0];
	private Vector3[] linePositions = new Vector3[0];
	private Vector3[] linePositionsOld = new Vector3[0];

	// Update is called once per frame
	public void Update () 
	{
		GetPoints();
		SetPointsToLine();
	}

	void GetPoints()
	{
		//find curved points in children
		linePoints = curvedLinePoints.ToArray();

		//add positions
		linePositions = new Vector3[linePoints.Length];
		for( int i = 0; i < linePoints.Length; i++ )
		{
			linePositions[i] = linePoints[i].transform.position;
		}
	}

	void SetPointsToLine()
	{
		//create old positions if they dont match
		if( linePositionsOld.Length != linePositions.Length )
		{
			linePositionsOld = new Vector3[linePositions.Length];
		}

		//check if line points have moved
		bool moved = false;
		for( int i = 0; i < linePositions.Length; i++ )
		{
			//compare
			if( linePositions[i] != linePositionsOld[i] )
			{
				moved = true;
			}
		}

		//update if moved
		if( moved == true )
		{
			LineRenderer line = this.GetComponent<LineRenderer>();

			//get smoothed values
			Vector3[] smoothedPoints = LineSmoother.SmoothLine( linePositions, lineSegmentSize , line.sharedMaterial);
			//set line settings
            if (reverseSegments)
            {
                System.Array.Reverse(smoothedPoints);
            }
			line.SetVertexCount( smoothedPoints.Length );
			line.SetPositions( smoothedPoints );
            //line.widthCurve()
			//line.SetWidth( lineWidth, lineWidth );
		}
	}

	void OnDrawGizmosSelected()
	{
		Update();
	}

	void OnDrawGizmos()
	{
		if( linePoints.Length == 0 )
		{
			GetPoints();
		}

		//settings for gizmos
		foreach( CurvedLinePoint linePoint in linePoints )
		{
			linePoint.showGizmo = showGizmos;
			linePoint.gizmoSize = gizmoSize;
			linePoint.gizmoColor = gizmoColor;
		}
	}
}
