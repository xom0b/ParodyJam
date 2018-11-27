// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PIDI Shaders Collection/2D/Reflection Shaders/SRP/Lightweight/Water - Lite"
{
	Properties
	{
		[HideInInspector]_GameCam("Game Cam", Float) = 0
		[Toggle]_InvertProjection("Invert Projection", Float) = 0
		[PerRendererData]_Reflection2D("Reflection Texture", 2D) = "black" {}
		[PerRendererData]_SurfaceLevel("Surface Level", Range( -4 , 4)) = 0
		[PerRendererData]_MainTex("Main Texture", 2D) = "white" {}
		[NoScaleOffset]_WavesNormalmap("Waves Normalmap", 2D) = "bump" {}
		_WavesScale("Waves Scale", Vector) = (1,1,0,0)
		_DistortionIntensity("Distortion Intensity", Range( 0 , 0.15)) = 0
		_WavesPanningSpeed("Waves Panning Speed", Vector) = (0,0,0,0)
		_ReflectionFade("Reflection Fade", Range( 0 , 1)) = 0
		_Reflectivity("Reflectivity", Range( 0 , 3)) = 2
		_Transparency("Transparency", Range( 0 , 3)) = 1
		[PerRendererData]_Color("Color", Color) = (1,1,1,1)
		_AlphaBackground("Alpha Background", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}
	SubShader
	{
		Tags { "RenderPipeline"="LightweightPipeline" "RenderType"="Transparent" "Queue"="Transparent" "PreviewType"="Plane" }
		Cull Off
		
		HLSLINCLUDE
		#pragma target 3.0
		ENDHLSL
		
		Pass
		{
			Tags { "LightMode"="LightweightForward" }
			Name "Base"
			Blend SrcAlpha OneMinusSrcAlpha , SrcAlpha OneMinusSrcAlpha
			ZTest LEqual
			ZWrite On
		
		
			HLSLPROGRAM
		    // Required to compile gles 2.0 with standard srp library
		    #pragma prefer_hlslcc gles
			
			// -------------------------------------
			// Lightweight Pipeline keywords
			#pragma multi_compile _ _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _VERTEX_LIGHTS
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
			#pragma multi_compile _ FOG_LINEAR FOG_EXP2
		
			// -------------------------------------
			// Unity defined keywords
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
		
			//--------------------------------------
			// GPU Instancing
			#pragma multi_compile_instancing
		
		    #pragma vertex vert
			#pragma fragment frag
		
			#include "LWRP/ShaderLibrary/Core.hlsl"
			#include "LWRP/ShaderLibrary/Lighting.hlsl"
			#include "CoreRP/ShaderLibrary/Color.hlsl"
			#include "CoreRP/ShaderLibrary/UnityInstancing.hlsl"
			#include "ShaderGraphLibrary/Functions.hlsl"
			
			uniform float4 _Color;
			uniform sampler2D _Reflection2D;
			uniform float _SurfaceLevel;
			uniform float _GameCam;
			uniform float _InvertProjection;
			uniform float _DistortionIntensity;
			uniform sampler2D _WavesNormalmap;
			uniform float2 _WavesPanningSpeed;
			uniform float2 _WavesScale;
			uniform float _Reflectivity;
			uniform float _ReflectionFade;
			uniform float _Transparency;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float _AlphaBackground;
			inline float4 ASE_ComputeGrabScreenPos( float4 pos )
			{
				#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
				#else
				float scale = 1.0;
				#endif
				float4 o = pos;
				o.y = pos.w * 0.5f;
				o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
				return o;
			}
			
			float2 CalculateReflection19( float surfaceLevel , float4 vertexPos , float gameCam )
			{
				float4 srfc = mul(UNITY_MATRIX_VP, mul(unity_ObjectToWorld, float4(0,surfaceLevel,0,1) ) );
				srfc = ComputeScreenPos(srfc);
				srfc.xy /=srfc.w;
				float4 pos = vertexPos;
				pos.xy/=pos.w;
				float2 screenUV = pos.xy;
				screenUV.y = srfc.y+abs(srfc.y-pos.y)*2;
				return screenUV;
			}
			
			float FadeNode47( float uvY , float refFade )
			{
				return ( pow( uvY, 16*(1-refFade) ) );
			}
			
					
			struct GraphVertexInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
			};

			struct GraphVertexOutput
			{
				float4 clipPos					: SV_POSITION;
				float4 lightmapUVOrVertexSH		: TEXCOORD0;
				half4 fogFactorAndVertexLight	: TEXCOORD1; 
				float4 shadowCoord				: TEXCOORD2;
				float4 tSpace0					: TEXCOORD3;
				float4 tSpace1					: TEXCOORD4;
				float4 tSpace2					: TEXCOORD5;
				float3 WorldSpaceViewDirection	: TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_texcoord8 : TEXCOORD8;
				float4 ase_color : COLOR;
			};

			GraphVertexOutput vert (GraphVertexInput v)
			{
		        GraphVertexOutput o = (GraphVertexOutput)0;
		
		        UNITY_SETUP_INSTANCE_ID(v);
		    	UNITY_TRANSFER_INSTANCE_ID(v, o);
		
				float3 lwWNormal = TransformObjectToWorldNormal(v.normal);
				float3 lwWorldPos = TransformObjectToWorld(v.vertex.xyz);
				float3 lwWTangent = mul((float3x3)UNITY_MATRIX_M,v.tangent.xyz);
				float3 lwWBinormal = normalize(cross(lwWNormal, lwWTangent) * v.tangent.w);
				o.tSpace0 = float4(lwWTangent.x, lwWBinormal.x, lwWNormal.x, lwWorldPos.x);
				o.tSpace1 = float4(lwWTangent.y, lwWBinormal.y, lwWNormal.y, lwWorldPos.y);
				o.tSpace2 = float4(lwWTangent.z, lwWBinormal.z, lwWNormal.z, lwWorldPos.z);
				float4 clipPos = TransformWorldToHClip(lwWorldPos);

				float4 ase_clipPos = TransformObjectToHClip(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord7 = screenPos;
				
				o.ase_texcoord8.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord8.zw = 0;
				v.vertex.xyz +=  float3(0,0,0) ;
				clipPos = TransformWorldToHClip(TransformObjectToWorld(v.vertex.xyz));
				OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH);
				OUTPUT_SH(lwWNormal, o.lightmapUVOrVertexSH);

				half3 vertexLight = VertexLighting(lwWorldPos, lwWNormal);
				half fogFactor = ComputeFogFactor(clipPos.z);
				o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
				o.clipPos = clipPos;

				o.shadowCoord = ComputeShadowCoord(o.clipPos);
				return o;
			}
		
			half4 frag (GraphVertexOutput IN ) : SV_Target
		    {
		    	UNITY_SETUP_INSTANCE_ID(IN);
		
				float3 WorldSpaceNormal = normalize(float3(IN.tSpace0.z,IN.tSpace1.z,IN.tSpace2.z));
				float3 WorldSpaceTangent = float3(IN.tSpace0.x,IN.tSpace1.x,IN.tSpace2.x);
				float3 WorldSpaceBiTangent = float3(IN.tSpace0.y,IN.tSpace1.y,IN.tSpace2.y);
				float3 WorldSpacePosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldSpaceViewDirection = SafeNormalize( _WorldSpaceCameraPos.xyz  - WorldSpacePosition );

				float3 temp_cast_0 = (0.0).xxx;
				
				float surfaceLevel19 = _SurfaceLevel;
				float4 screenPos = IN.ase_texcoord7;
				float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( screenPos );
				float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
				float4 vertexPos19 = ase_grabScreenPosNorm;
				float gameCam19 = max( _GameCam , _InvertProjection );
				float2 localCalculateReflection19 = CalculateReflection19( surfaceLevel19 , vertexPos19 , gameCam19 );
				float4 ase_screenPosNorm = screenPos/screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 panner31 = ( _Time.y * _WavesPanningSpeed + ( ase_screenPosNorm * float4( _WavesScale, 0.0 , 0.0 ) ).xy);
				float3 tex2DNode27 = UnpackNormal( tex2D( _WavesNormalmap, panner31 ) );
				float uvY47 = IN.ase_texcoord8.xy.y;
				float refFade47 = _ReflectionFade;
				float localFadeNode47 = FadeNode47( uvY47 , refFade47 );
				float2 uv_MainTex = IN.ase_texcoord8.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode26 = tex2D( _MainTex, uv_MainTex );
				float4 temp_output_42_0 = ( ( _Color * _Color.a * ( ( tex2D( _Reflection2D, ( float3( localCalculateReflection19 ,  0.0 ) + ( _DistortionIntensity * tex2DNode27 ) ).xy ) * _Reflectivity * localFadeNode47 ) + ( tex2D( _Reflection2D, ( ase_grabScreenPosNorm + float4( ( _DistortionIntensity * float3( 0.65,0,0 ) * tex2DNode27 ) , 0.0 ) ).xy ) * _Transparency * float4(0.1627358,0.558416,0.6509434,1) ) ) * tex2DNode26.a ) + ( tex2DNode26 * IN.ase_color * IN.ase_color.a * _AlphaBackground ) );
				
				
				float3 Specular = float3(0, 0, 0);
		        float3 Albedo = temp_cast_0;
				float3 Normal = float3(0, 0, 1);
				float3 Emission = temp_output_42_0.rgb;
				float Metallic = 1;
				float Smoothness = 0.5;
				float Occlusion = 0.0;
				float Alpha = temp_output_42_0.a;
				float AlphaClipThreshold = 0;
		
				InputData inputData;
				inputData.positionWS = WorldSpacePosition;

				#ifdef _NORMALMAP
					inputData.normalWS = TangentToWorldNormal(Normal, WorldSpaceTangent, WorldSpaceBiTangent, WorldSpaceNormal);
				#else
					inputData.normalWS = WorldSpaceNormal;
				#endif

				#ifdef SHADER_API_MOBILE
					// viewDirection should be normalized here, but we avoid doing it as it's close enough and we save some ALU.
					inputData.viewDirectionWS = WorldSpaceViewDirection;
				#else
					inputData.viewDirectionWS = WorldSpaceViewDirection;
				#endif

				inputData.shadowCoord = IN.shadowCoord;

				inputData.fogCoord = IN.fogFactorAndVertexLight.x;
				inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
				inputData.bakedGI = SAMPLE_GI(IN.lightmapUVOrVertexSH, IN.lightmapUVOrVertexSH, inputData.normalWS);

				half4 color = LightweightFragmentPBR(
					inputData, 
					Albedo, 
					Metallic, 
					Specular, 
					Smoothness, 
					Occlusion, 
					Emission, 
					Alpha);

				// Computes fog factor per-vertex
    			ApplyFog(color.rgb, IN.fogFactorAndVertexLight.x);

				#if _AlphaClip
					clip(Alpha - AlphaClipThreshold);
				#endif
				return color;
		    }
			ENDHLSL
		}

		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual

			HLSLPROGRAM
		    #pragma prefer_hlslcc gles
		
			#pragma multi_compile_instancing
		
		    #pragma vertex vert
			#pragma fragment frag
		
			#include "LWRP/ShaderLibrary/Core.hlsl"
			#include "LWRP/ShaderLibrary/Lighting.hlsl"
			
			uniform float4 _ShadowBias;
			uniform float3 _LightDirection;
			uniform float4 _Color;
			uniform sampler2D _Reflection2D;
			uniform float _SurfaceLevel;
			uniform float _GameCam;
			uniform float _InvertProjection;
			uniform float _DistortionIntensity;
			uniform sampler2D _WavesNormalmap;
			uniform float2 _WavesPanningSpeed;
			uniform float2 _WavesScale;
			uniform float _Reflectivity;
			uniform float _ReflectionFade;
			uniform float _Transparency;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float _AlphaBackground;
			inline float4 ASE_ComputeGrabScreenPos( float4 pos )
			{
				#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
				#else
				float scale = 1.0;
				#endif
				float4 o = pos;
				o.y = pos.w * 0.5f;
				o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
				return o;
			}
			
			float2 CalculateReflection19( float surfaceLevel , float4 vertexPos , float gameCam )
			{
				float4 srfc = mul(UNITY_MATRIX_VP, mul(unity_ObjectToWorld, float4(0,surfaceLevel,0,1) ) );
				srfc = ComputeScreenPos(srfc);
				srfc.xy /=srfc.w;
				float4 pos = vertexPos;
				pos.xy/=pos.w;
				float2 screenUV = pos.xy;
				screenUV.y = srfc.y+abs(srfc.y-pos.y)*2;
				return screenUV;
			}
			
			float FadeNode47( float uvY , float refFade )
			{
				return ( pow( uvY, 16*(1-refFade) ) );
			}
			
					
			struct GraphVertexInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
			};

			struct GraphVertexOutput
			{
				float4 clipPos					: SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_texcoord8 : TEXCOORD8;
				float4 ase_color : COLOR;
			};

			GraphVertexOutput vert (GraphVertexInput v)
			{
				GraphVertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float4 ase_clipPos = TransformObjectToHClip(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord7 = screenPos;
				
				o.ase_texcoord8.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord8.zw = 0;

				v.vertex.xyz +=  float3(0,0,0) ;

				float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
				float3 normalWS = TransformObjectToWorldDir(v.normal);

				float invNdotL = 1.0 - saturate(dot(_LightDirection, normalWS));
				float scale = invNdotL * _ShadowBias.y;

				positionWS = normalWS * scale.xxx + positionWS;
				float4 clipPos = TransformWorldToHClip(positionWS);

				clipPos.z += _ShadowBias.x;
				#if UNITY_REVERSED_Z
					clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#else
					clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#endif
				o.clipPos = clipPos;
				return o;
			}
		
			half4 frag (GraphVertexOutput IN ) : SV_Target
		    {
		    	UNITY_SETUP_INSTANCE_ID(IN);

				float surfaceLevel19 = _SurfaceLevel;
				float4 screenPos = IN.ase_texcoord7;
				float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( screenPos );
				float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
				float4 vertexPos19 = ase_grabScreenPosNorm;
				float gameCam19 = max( _GameCam , _InvertProjection );
				float2 localCalculateReflection19 = CalculateReflection19( surfaceLevel19 , vertexPos19 , gameCam19 );
				float4 ase_screenPosNorm = screenPos/screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 panner31 = ( _Time.y * _WavesPanningSpeed + ( ase_screenPosNorm * float4( _WavesScale, 0.0 , 0.0 ) ).xy);
				float3 tex2DNode27 = UnpackNormal( tex2D( _WavesNormalmap, panner31 ) );
				float uvY47 = IN.ase_texcoord8.xy.y;
				float refFade47 = _ReflectionFade;
				float localFadeNode47 = FadeNode47( uvY47 , refFade47 );
				float2 uv_MainTex = IN.ase_texcoord8.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode26 = tex2D( _MainTex, uv_MainTex );
				float4 temp_output_42_0 = ( ( _Color * _Color.a * ( ( tex2D( _Reflection2D, ( float3( localCalculateReflection19 ,  0.0 ) + ( _DistortionIntensity * tex2DNode27 ) ).xy ) * _Reflectivity * localFadeNode47 ) + ( tex2D( _Reflection2D, ( ase_grabScreenPosNorm + float4( ( _DistortionIntensity * float3( 0.65,0,0 ) * tex2DNode27 ) , 0.0 ) ).xy ) * _Transparency * float4(0.1627358,0.558416,0.6509434,1) ) ) * tex2DNode26.a ) + ( tex2DNode26 * IN.ase_color * IN.ase_color.a * _AlphaBackground ) );
				

				float Alpha = temp_output_42_0.a;
				float AlphaClipThreshold = AlphaClipThreshold;
				
				#if _AlphaClip
					clip(Alpha - AlphaClipThreshold);
				#endif
				return Alpha;
				return 0;
		    }
			ENDHLSL
		}
		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			Cull Back

			HLSLPROGRAM
			#pragma prefer_hlslcc gles
    
			#pragma multi_compile_instancing

			#pragma vertex vert
			#pragma fragment frag

			#include "LWRP/ShaderLibrary/Core.hlsl"
			#include "LWRP/ShaderLibrary/Lighting.hlsl"
			
			uniform float4 _Color;
			uniform sampler2D _Reflection2D;
			uniform float _SurfaceLevel;
			uniform float _GameCam;
			uniform float _InvertProjection;
			uniform float _DistortionIntensity;
			uniform sampler2D _WavesNormalmap;
			uniform float2 _WavesPanningSpeed;
			uniform float2 _WavesScale;
			uniform float _Reflectivity;
			uniform float _ReflectionFade;
			uniform float _Transparency;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float _AlphaBackground;
			inline float4 ASE_ComputeGrabScreenPos( float4 pos )
			{
				#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
				#else
				float scale = 1.0;
				#endif
				float4 o = pos;
				o.y = pos.w * 0.5f;
				o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
				return o;
			}
			
			float2 CalculateReflection19( float surfaceLevel , float4 vertexPos , float gameCam )
			{
				float4 srfc = mul(UNITY_MATRIX_VP, mul(unity_ObjectToWorld, float4(0,surfaceLevel,0,1) ) );
				srfc = ComputeScreenPos(srfc);
				srfc.xy /=srfc.w;
				float4 pos = vertexPos;
				pos.xy/=pos.w;
				float2 screenUV = pos.xy;
				screenUV.y = srfc.y+abs(srfc.y-pos.y)*2;
				return screenUV;
			}
			
			float FadeNode47( float uvY , float refFade )
			{
				return ( pow( uvY, 16*(1-refFade) ) );
			}
			

			struct GraphVertexInput
			{
				float4 vertex : POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
			};

			struct GraphVertexOutput
			{
				float4 clipPos					: SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_texcoord8 : TEXCOORD8;
				float4 ase_color : COLOR;
			};

			GraphVertexOutput vert (GraphVertexInput v)
			{
				GraphVertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float4 ase_clipPos = TransformObjectToHClip(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord7 = screenPos;
				
				o.ase_texcoord8.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord8.zw = 0;

				v.vertex.xyz +=  float3(0,0,0) ;
				o.clipPos = TransformObjectToHClip(v.vertex.xyz);
				return o;
			}

			half4 frag (GraphVertexOutput IN ) : SV_Target
		    {
		    	UNITY_SETUP_INSTANCE_ID(IN);

				float surfaceLevel19 = _SurfaceLevel;
				float4 screenPos = IN.ase_texcoord7;
				float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( screenPos );
				float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
				float4 vertexPos19 = ase_grabScreenPosNorm;
				float gameCam19 = max( _GameCam , _InvertProjection );
				float2 localCalculateReflection19 = CalculateReflection19( surfaceLevel19 , vertexPos19 , gameCam19 );
				float4 ase_screenPosNorm = screenPos/screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 panner31 = ( _Time.y * _WavesPanningSpeed + ( ase_screenPosNorm * float4( _WavesScale, 0.0 , 0.0 ) ).xy);
				float3 tex2DNode27 = UnpackNormal( tex2D( _WavesNormalmap, panner31 ) );
				float uvY47 = IN.ase_texcoord8.xy.y;
				float refFade47 = _ReflectionFade;
				float localFadeNode47 = FadeNode47( uvY47 , refFade47 );
				float2 uv_MainTex = IN.ase_texcoord8.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode26 = tex2D( _MainTex, uv_MainTex );
				float4 temp_output_42_0 = ( ( _Color * _Color.a * ( ( tex2D( _Reflection2D, ( float3( localCalculateReflection19 ,  0.0 ) + ( _DistortionIntensity * tex2DNode27 ) ).xy ) * _Reflectivity * localFadeNode47 ) + ( tex2D( _Reflection2D, ( ase_grabScreenPosNorm + float4( ( _DistortionIntensity * float3( 0.65,0,0 ) * tex2DNode27 ) , 0.0 ) ).xy ) * _Transparency * float4(0.1627358,0.558416,0.6509434,1) ) ) * tex2DNode26.a ) + ( tex2DNode26 * IN.ase_color * IN.ase_color.a * _AlphaBackground ) );
				

				float Alpha = temp_output_42_0.a;
				float AlphaClipThreshold = AlphaClipThreshold;
				
				#if _AlphaClip
					clip(Alpha - AlphaClipThreshold);
				#endif
				return Alpha;
				return 0;
		    }
			ENDHLSL
		}
		
		Pass
		{
			
			Name "Meta"
			Tags{"LightMode" = "Meta"}
		  
			Cull Off

				Cull Off

				HLSLPROGRAM
				// Required to compile gles 2.0 with standard srp library
				#pragma prefer_hlslcc gles

				#pragma vertex LightweightVertexMeta
				#pragma fragment LightweightFragmentMeta

				#pragma shader_feature _SPECULAR_SETUP
				#pragma shader_feature _EMISSION
				#pragma shader_feature _METALLICSPECGLOSSMAP
				#pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
				#pragma shader_feature EDITOR_VISUALIZATION

				#pragma shader_feature _SPECGLOSSMAP

				#include "LWRP/ShaderLibrary/InputSurfacePBR.hlsl"
				#include "LWRP/ShaderLibrary/LightweightPassMetaPBR.hlsl"
				ENDHLSL
		}
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15301
1373;161;1352;589;3477.674;850.916;3.05022;True;True
Node;AmplifyShaderEditor.CommentaryNode;64;-2769.09,68.22408;Float;False;1596.448;818.6332;The normal based distortion effect to be applied to both the reflection and refraction passes;7;33;34;35;72;73;74;31;Distortion Effect;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;73;-2696.863,516.1906;Float;False;Property;_WavesScale;Waves Scale;6;0;Create;True;0;0;False;0;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ScreenPosInputsNode;72;-2703.392,318.6565;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;35;-2702.254,671.2496;Float;False;Property;_WavesPanningSpeed;Waves Panning Speed;8;0;Create;True;0;0;False;0;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-2455.25,488.4378;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleTimeNode;34;-2703.097,802.2698;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;63;-2763.934,-798.1111;Float;False;1197.667;721.1912;Projects the reflection over the water and inverts it if neccessary;3;19;15;21;Reflection Projection;1,1,1,1;0;0
Node;AmplifyShaderEditor.PannerNode;31;-2136.679,573.7479;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;33;-2705.624,122.5519;Float;True;Property;_WavesNormalmap;Waves Normalmap;5;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;True;bump;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-2685.114,-360.6732;Float;False;Property;_GameCam;Game Cam;0;1;[HideInInspector];Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-2684.14,-272.5686;Float;False;Property;_InvertProjection;Invert Projection;1;1;[Toggle];Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;52;-2299.624,-341.7064;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;27;-1944.307,484.6348;Float;True;Property;_0;0;4;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;29;-1958.349,298.8492;Float;False;Property;_DistortionIntensity;Distortion Intensity;7;0;Create;True;0;0;False;0;0;0;0;0.15;0;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;24;-2694.499,-558.1448;Float;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;15;-2704.663,-684.0417;Float;False;Property;_SurfaceLevel;Surface Level;3;1;[PerRendererData];Create;True;0;0;False;0;0;0;-4;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-1606.079,361.7251;Float;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomExpressionNode;19;-2069.154,-502.2839;Float;False;float4 srfc = mul(UNITY_MATRIX_VP, mul(unity_ObjectToWorld, float4(0,surfaceLevel,0,1) ) )@$srfc = ComputeScreenPos(srfc)@$srfc.xy /=srfc.w@$$float4 pos = vertexPos@$pos.xy/=pos.w@$float2 screenUV = pos.xy@$$screenUV.y = srfc.y+abs(srfc.y-pos.y)*2@$$return screenUV@;2;False;3;True;surfaceLevel;FLOAT;0;In;True;vertexPos;FLOAT4;0,0,0,0;In;True;gameCam;FLOAT;0;In;Calculate Reflection;True;False;3;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;65;-1494.692,-818.0416;Float;False;325.1505;352.3237;GrabPass substitute;1;1;Reflection/Refraction Texture;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;68;-301.9855,-1330.803;Float;False;584.0675;402.2781;Vertical fading effect;1;49;Reflection/Refraction Fade;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;-1592.205,173.3474;Float;False;3;3;0;FLOAT;0;False;1;FLOAT3;0.65,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;54;-1338.514,-167.5175;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-1337.24,-298.8505;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;67;-998.8931,-429.0264;Float;False;621.423;626.9998;Refraction multiplied by a "water" color;1;61;Refraction Pass;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;1;-1433.979,-712.5936;Float;True;Property;_Reflection2D;Reflection Texture;2;1;[PerRendererData];Create;False;0;0;False;0;None;None;False;black;LockedToTexture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.CommentaryNode;66;-1066.172,-1485.355;Float;False;627.532;532.9744;Reflection pass;1;57;Reflection Pass;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-256.8435,-1097.449;Float;False;Property;_ReflectionFade;Reflection Fade;9;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;48;-250.9973,-1269.125;Float;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;55;-982.8186,-1377.982;Float;True;Property;_TextureSample2;Texture Sample 2;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;47;45.00957,-1130.096;Float;False;return ( pow( uvY, 16*(1-refFade) ) )@;1;False;2;True;uvY;FLOAT;0;In;True;refFade;FLOAT;0;In;Fade Node;True;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-922.5081,-319.9336;Float;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;61;-922.5338,-8.31765;Float;False;Constant;_Color0;Color 0;14;0;Create;True;0;0;False;0;0.1627358,0.558416,0.6509434,1;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;57;-979.2032,-1144.442;Float;False;Property;_Reflectivity;Reflectivity;10;0;Create;True;0;0;False;0;2;2;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-923.572,-115.8375;Float;False;Property;_Transparency;Transparency;11;0;Create;True;0;0;False;0;1;2;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-544.2793,-159.4901;Float;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;25;-1027.448,850.4365;Float;True;Property;_MainTex;Main Texture;4;1;[PerRendererData];Create;False;0;0;False;0;None;None;False;white;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.CommentaryNode;70;-188.2061,-375.7543;Float;False;773.2866;491.617;Color + Reflections + Refraction composition;1;36;Final composition;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-615.1374,-1269.019;Float;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;41;-606.1777,661.2405;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;36;-138.2061,-325.7541;Float;False;Property;_Color;Color;12;1;[PerRendererData];Create;True;0;0;False;0;1,1,1,1;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;26;-725.9562,848.4355;Float;True;Property;_TextureSample1;Texture Sample 1;4;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;40;-642.8071,1048.71;Float;False;Property;_AlphaBackground;Alpha Background;13;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;60;-131.1039,-126.0835;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-206.9276,713.0546;Float;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;245.5076,-313.075;Float;False;4;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;42;431.0805,-199.2128;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;39;876.9687,-103.9608;Float;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;46;909.6597,-301.4976;Float;False;Constant;_Float0;Float 0;10;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;9;1242.502,-272.5822;Float;False;True;2;Float;ASEMaterialInspector;0;1;PIDI Shaders Collection/2D/Reflection Shaders/SRP/Lightweight/Water - Lite;1976390536c6c564abb90fe41f6ee334;0;0;Base;9;False;False;True;Off;False;False;False;False;False;True;4;RenderPipeline=LightweightPipeline;RenderType=Transparent;Queue=Transparent;PreviewType=Plane;True;2;0;0;0;True;2;SrcAlpha;OneMinusSrcAlpha;2;SrcAlpha;OneMinusSrcAlpha;False;False;False;False;True;1;True;3;False;True;1;LightMode=LightweightForward;False;0;0;0;9;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;11;-123.5,-101.4;Float;False;False;2;Float;ASEMaterialInspector;0;1;ASETemplateShaders/LightWeight;1976390536c6c564abb90fe41f6ee334;0;2;DepthOnly;0;False;False;True;Off;False;False;False;False;False;True;4;RenderPipeline=LightweightPipeline;RenderType=Transparent;Queue=Transparent;PreviewType=Plane;True;2;0;0;0;False;False;True;Back;True;False;False;False;False;False;True;1;False;False;True;1;LightMode=DepthOnly;False;0;0;0;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;10;-123.5,-101.4;Float;False;False;2;Float;ASEMaterialInspector;0;1;ASETemplateShaders/LightWeight;1976390536c6c564abb90fe41f6ee334;0;1;ShadowCaster;0;False;False;True;Off;False;False;False;False;False;True;4;RenderPipeline=LightweightPipeline;RenderType=Transparent;Queue=Transparent;PreviewType=Plane;True;2;0;0;0;False;False;False;False;False;True;1;True;3;False;True;1;LightMode=ShadowCaster;False;0;0;0;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;71;747.765,-514.79;Float;False;974.7354;771.7696;All outputs go through the emission channel, occlusion and albedo are set to 1 to simulate an Unlit shader;0;Pseudo Sprite Lighting;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;69;-1064.273,568.7883;Float;False;1019.046;660.3366;Main sampling of the sprite texture;0;Albedo & Alpha control;1,1,1,1;0;0
WireConnection;74;0;72;0
WireConnection;74;1;73;0
WireConnection;31;0;74;0
WireConnection;31;2;35;0
WireConnection;31;1;34;0
WireConnection;52;0;21;0
WireConnection;52;1;50;0
WireConnection;27;0;33;0
WireConnection;27;1;31;0
WireConnection;30;0;29;0
WireConnection;30;1;27;0
WireConnection;19;0;15;0
WireConnection;19;1;24;0
WireConnection;19;2;52;0
WireConnection;53;0;29;0
WireConnection;53;2;27;0
WireConnection;54;0;24;0
WireConnection;54;1;53;0
WireConnection;28;0;19;0
WireConnection;28;1;30;0
WireConnection;55;0;1;0
WireConnection;55;1;28;0
WireConnection;47;0;48;2
WireConnection;47;1;49;0
WireConnection;2;0;1;0
WireConnection;2;1;54;0
WireConnection;58;0;2;0
WireConnection;58;1;59;0
WireConnection;58;2;61;0
WireConnection;56;0;55;0
WireConnection;56;1;57;0
WireConnection;56;2;47;0
WireConnection;26;0;25;0
WireConnection;60;0;56;0
WireConnection;60;1;58;0
WireConnection;43;0;26;0
WireConnection;43;1;41;0
WireConnection;43;2;41;4
WireConnection;43;3;40;0
WireConnection;37;0;36;0
WireConnection;37;1;36;4
WireConnection;37;2;60;0
WireConnection;37;3;26;4
WireConnection;42;0;37;0
WireConnection;42;1;43;0
WireConnection;39;0;42;0
WireConnection;9;0;46;0
WireConnection;9;2;42;0
WireConnection;9;5;46;0
WireConnection;9;6;39;3
ASEEND*/
//CHKSM=D550C15E3A03E47204AEE37573CC8270CCAAC4FC