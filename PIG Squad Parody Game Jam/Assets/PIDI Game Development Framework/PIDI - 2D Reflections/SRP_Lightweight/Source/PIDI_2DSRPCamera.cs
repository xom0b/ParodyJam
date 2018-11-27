/*

Copyright© 2018, Jorge Pinal Negrete. All Rights Reserved.
PIDI 2D reflections, version 1.2
*/

using UnityEngine;

[ExecuteInEditMode]
public class PIDI_2DSRPCamera:MonoBehaviour{

    private bool affectAllReflections = true;
    private PIDI_2DReflection[] reflections = new  PIDI_2DReflection[0];
    private Camera m_Camera;

    public void Start(){
        if ( affectAllReflections ){
            reflections = GameObject.FindObjectsOfType<PIDI_2DReflection>() as PIDI_2DReflection[];
        }

        if ( m_Camera ){
            DestroyImmediate(m_Camera.gameObject);
        }

        m_Camera = (Camera)Instantiate(GetComponent<Camera>());
        
        m_Camera.gameObject.hideFlags = HideFlags.HideAndDontSave;

        var c = m_Camera.GetComponents<Component>();
        for ( int i = 0; i < c.Length; i++ ){
            if ( c[i] != m_Camera && c[i] != m_Camera.transform ){
                DestroyImmediate(c[i]);
            }
        }


        UnityEngine.Experimental.Rendering.RenderPipeline.beginCameraRendering += SRPRender;


        m_Camera.transform.parent = transform;
        m_Camera.transform.localPosition = new Vector3(0,0,0);
        m_Camera.transform.LookAt(transform.TransformPoint(0,0,10));
      
        
    }


    void SRPRender(Camera cam) {

        if ( cam != m_Camera )
            return;

        

        m_Camera.depth = GetComponent<Camera>().depth-1;
        m_Camera.cullingMask = 0;
        m_Camera.rect = GetComponent<Camera>().rect;
        m_Camera.depthTextureMode = DepthTextureMode.None;
        m_Camera.backgroundColor = GetComponent<Camera>().backgroundColor;
        m_Camera.orthographic = GetComponent<Camera>().orthographic;
        m_Camera.orthographicSize = GetComponent<Camera>().orthographicSize;
        m_Camera.fieldOfView = GetComponent<Camera>().fieldOfView;
        m_Camera.enabled = true;        
        //m_Camera.ResetProjectionMatrix();
        #if UNITY_5_4_OR_NEWER
        var tempMatrix = m_Camera.nonJitteredProjectionMatrix;
        m_Camera.nonJitteredProjectionMatrix = m_Camera.projectionMatrix;
        #endif

        for ( int i = 0; i < reflections.Length; i++ ){
            reflections[i].SRPUpdate(m_Camera);
        }

        #if UNITY_5_4_OR_NEWER
        m_Camera.nonJitteredProjectionMatrix = tempMatrix;
        #endif
        GetComponent<Camera>().Render();

    }


    private void OnDisable(){
        UnityEngine.Experimental.Rendering.RenderPipeline.beginCameraRendering -= SRPRender;
        if ( m_Camera )
            DestroyImmediate(m_Camera.gameObject);
    }
}