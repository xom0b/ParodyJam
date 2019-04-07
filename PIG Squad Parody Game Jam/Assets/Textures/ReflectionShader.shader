Shader "Unlit/ReflectionShader"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		[Header(Reflection Properties)]
		[Space(12)]
		_Color("Reflection Color (RGB) Opacity(A)",Color) = (1,1,1,1)
		_ReflectionFade("Reflection Fade", Range(0,1)) = 1
		_Normalmap("Normalmap", 2D) = "bump"{}
		_DistortionSpeed("DistortionSpeed", Vector) = (0,0,0,0)
		_SurfaceLevel("Surface Level",Range(-5,5)) = 0
		_SurfaceDistortion("Surface Distortion", Range(0,0.1)) = 0.05
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100
		Cull Off
		Lighting Off
		ZWrite Off
		Blend One OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _Normalmap;
			float4 _Normalmap_ST;
			float _SurfaceLevel;
			float _ReflectionFade;
			float _SurfaceDistortion;
			float4 _DistortionSpeed;
			half4 _Color;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				//// sample the texture
				//fixed4 col = tex2D(_MainTex, i.uv);
				//return col;

				float2 mov = _DistortionSpeed.xy*_Time;
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed3 norms = UnpackNormal(tex2D(_Normalmap, i.uv*_Normalmap_ST.xy + mov));
				fixed4 bgcolor = tex2D(_MainTex, i.uv + norms * _SurfaceDistortion)*_Color*_Color.a*col.a;
				//return bgcolor;
				//return col;
				return lerp(bgcolor*i.color.a, col*col.a*i.color*i.color.a, 1 - (pow(i.uv.y, 16 * (1 - _ReflectionFade))));
			}
			ENDCG
		}
	}
}
