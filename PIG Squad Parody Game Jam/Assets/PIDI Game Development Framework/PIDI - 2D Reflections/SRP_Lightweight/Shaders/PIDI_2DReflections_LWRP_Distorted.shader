// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PIDI Shaders Collection/2D/Reflection Shaders/SRP/Lightweight/Distorted"
{
	Properties
	{
		[HideInInspector][PerRendererData]_Reflection2D("Reflection Texture", 2D) = "black" {}
		[NoScaleOffset]_DistortionNormalmap("Distortion Normalmap", 2D) = "white" {}
		_DistortionMapScale("Distortion Map Scale", Vector) = (1,1,0,0)
		_DistortionIntensity("Distortion Intensity", Range( 0 , 0.15)) = 0
		_DistortionPanningSpeed("Distortion Panning Speed", Vector) = (0,0,0,0)
		_ReflectionFade("Reflection Fade", Range( 0 , 1)) = 0
		[PerRendererData]_SurfaceLevel("Surface Level", Range( -4 , 4)) = 0
		[PerRendererData]_MainTex("Main Texture", 2D) = "white" {}
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
			uniform float _DistortionIntensity;
			uniform sampler2D _DistortionNormalmap;
			uniform float2 _DistortionPanningSpeed;
			uniform float2 _DistortionMapScale;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float _ReflectionFade;
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
			
			float2 CalculateReflection19( float surfaceLevel , float4 vertexPos )
			{
				float4 srfc = mul(UNITY_MATRIX_VP, mul(unity_ObjectToWorld, float4(0,surfaceLevel,0,1) ) );
				srfc = ComputeScreenPos(srfc);                
				srfc.xy /=srfc.w;
				float4 pos = vertexPos;
				pos.xy/=pos.w;
				float2 screenUV = pos.xy;
				screenUV.y =  srfc.y+abs(srfc.y-pos.y);
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
				float2 localCalculateReflection19 = CalculateReflection19( surfaceLevel19 , vertexPos19 );
				float4 ase_screenPosNorm = screenPos/screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 panner31 = ( _Time.y * _DistortionPanningSpeed + ( ase_screenPosNorm * float4( _DistortionMapScale, 0.0 , 0.0 ) ).xy);
				float2 uv_MainTex = IN.ase_texcoord8.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode26 = tex2D( _MainTex, uv_MainTex );
				float uvY47 = IN.ase_texcoord8.xy.y;
				float refFade47 = _ReflectionFade;
				float localFadeNode47 = FadeNode47( uvY47 , refFade47 );
				float4 temp_output_42_0 = ( ( _Color * _Color.a * tex2D( _Reflection2D, ( float3( localCalculateReflection19 ,  0.0 ) + ( _DistortionIntensity * UnpackNormal( tex2D( _DistortionNormalmap, panner31 ) ) ) ).xy ) * tex2DNode26.a * localFadeNode47 ) + ( tex2DNode26 * IN.ase_color * IN.ase_color.a * _AlphaBackground ) );
				
				
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
			uniform float _DistortionIntensity;
			uniform sampler2D _DistortionNormalmap;
			uniform float2 _DistortionPanningSpeed;
			uniform float2 _DistortionMapScale;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float _ReflectionFade;
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
			
			float2 CalculateReflection19( float surfaceLevel , float4 vertexPos )
			{
				float4 srfc = mul(UNITY_MATRIX_VP, mul(unity_ObjectToWorld, float4(0,surfaceLevel,0,1) ) );
				srfc = ComputeScreenPos(srfc);                
				srfc.xy /=srfc.w;
				float4 pos = vertexPos;
				pos.xy/=pos.w;
				float2 screenUV = pos.xy;
				screenUV.y =  srfc.y+abs(srfc.y-pos.y);
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
				float2 localCalculateReflection19 = CalculateReflection19( surfaceLevel19 , vertexPos19 );
				float4 ase_screenPosNorm = screenPos/screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 panner31 = ( _Time.y * _DistortionPanningSpeed + ( ase_screenPosNorm * float4( _DistortionMapScale, 0.0 , 0.0 ) ).xy);
				float2 uv_MainTex = IN.ase_texcoord8.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode26 = tex2D( _MainTex, uv_MainTex );
				float uvY47 = IN.ase_texcoord8.xy.y;
				float refFade47 = _ReflectionFade;
				float localFadeNode47 = FadeNode47( uvY47 , refFade47 );
				float4 temp_output_42_0 = ( ( _Color * _Color.a * tex2D( _Reflection2D, ( float3( localCalculateReflection19 ,  0.0 ) + ( _DistortionIntensity * UnpackNormal( tex2D( _DistortionNormalmap, panner31 ) ) ) ).xy ) * tex2DNode26.a * localFadeNode47 ) + ( tex2DNode26 * IN.ase_color * IN.ase_color.a * _AlphaBackground ) );
				

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
			uniform float _DistortionIntensity;
			uniform sampler2D _DistortionNormalmap;
			uniform float2 _DistortionPanningSpeed;
			uniform float2 _DistortionMapScale;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float _ReflectionFade;
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
			
			float2 CalculateReflection19( float surfaceLevel , float4 vertexPos )
			{
				float4 srfc = mul(UNITY_MATRIX_VP, mul(unity_ObjectToWorld, float4(0,surfaceLevel,0,1) ) );
				srfc = ComputeScreenPos(srfc);                
				srfc.xy /=srfc.w;
				float4 pos = vertexPos;
				pos.xy/=pos.w;
				float2 screenUV = pos.xy;
				screenUV.y =  srfc.y+abs(srfc.y-pos.y);
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
				float2 localCalculateReflection19 = CalculateReflection19( surfaceLevel19 , vertexPos19 );
				float4 ase_screenPosNorm = screenPos/screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 panner31 = ( _Time.y * _DistortionPanningSpeed + ( ase_screenPosNorm * float4( _DistortionMapScale, 0.0 , 0.0 ) ).xy);
				float2 uv_MainTex = IN.ase_texcoord8.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode26 = tex2D( _MainTex, uv_MainTex );
				float uvY47 = IN.ase_texcoord8.xy.y;
				float refFade47 = _ReflectionFade;
				float localFadeNode47 = FadeNode47( uvY47 , refFade47 );
				float4 temp_output_42_0 = ( ( _Color * _Color.a * tex2D( _Reflection2D, ( float3( localCalculateReflection19 ,  0.0 ) + ( _DistortionIntensity * UnpackNormal( tex2D( _DistortionNormalmap, panner31 ) ) ) ).xy ) * tex2DNode26.a * localFadeNode47 ) + ( tex2DNode26 * IN.ase_color * IN.ase_color.a * _AlphaBackground ) );
				

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
1373;29;1352;693;2020.437;381.5053;1.986982;True;True
Node;AmplifyShaderEditor.CommentaryNode;53;-2509.607,399.2543;Float;False;1284.374;809.6451;The normal based distortion effect to be applied to both the reflection and refraction passes;10;62;61;60;30;27;29;31;35;34;33;Distortion Effect;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;60;-2469.813,712.0214;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;61;-2471.01,884.5218;Float;False;Property;_DistortionMapScale;Distortion Map Scale;2;0;Create;True;0;0;False;0;1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;35;-2472.565,1007.064;Float;False;Property;_DistortionPanningSpeed;Distortion Panning Speed;4;0;Create;True;0;0;False;0;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;34;-2469.775,1132.777;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-2201.611,803.2217;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;54;-2517.879,-404.7281;Float;False;823.7852;585.952;Projects the reflection over the water and inverts it if neccessary;3;24;15;19;Reflection Projection;1,1,1,1;0;0
Node;AmplifyShaderEditor.PannerNode;31;-1928.215,808.1806;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;33;-2471.323,523.5621;Float;True;Property;_DistortionNormalmap;Distortion Normalmap;1;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;False;white;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SamplerNode;27;-1735.84,719.0677;Float;True;Property;_0;0;4;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GrabScreenPosition;24;-2457.716,-228.8311;Float;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;15;-2467.879,-354.7281;Float;False;Property;_SurfaceLevel;Surface Level;6;1;[PerRendererData];Create;True;0;0;False;0;0;0;-4;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-1719.038,592.1462;Float;False;Property;_DistortionIntensity;Distortion Intensity;3;0;Create;True;0;0;False;0;0;0;0;0.15;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;56;-1150.735,-856.0909;Float;False;611.1192;295.1029;Vertical fading effect;3;48;47;49;Reflection Fade;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-1383.521,565.1572;Float;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;58;-1118.445,443.7641;Float;False;828.3187;616.4724;Main sampling of the sprite texture;5;26;25;40;41;43;Albedo & Alpha Control;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;55;-2499.236,-951.8962;Float;False;302;280;;1;1;Reflection Texture;1,1,1,1;0;0
Node;AmplifyShaderEditor.CustomExpressionNode;19;-1947.094,-22.12039;Float;False;float4 srfc = mul(UNITY_MATRIX_VP, mul(unity_ObjectToWorld, float4(0,surfaceLevel,0,1) ) )@$srfc = ComputeScreenPos(srfc)@                $srfc.xy /=srfc.w@$float4 pos = vertexPos@$pos.xy/=pos.w@$float2 screenUV = pos.xy@$screenUV.y =  srfc.y+abs(srfc.y-pos.y)@$$return screenUV@;2;False;2;True;surfaceLevel;FLOAT;0;In;True;vertexPos;FLOAT4;0,0,0,0;In;Calculate Reflection;True;False;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-1420.081,-87.15255;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;1;-2449.236,-903.5057;Float;True;Property;_Reflection2D;Reflection Texture;0;2;[HideInInspector];[PerRendererData];Create;False;0;0;False;0;None;None;False;black;LockedToTexture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;25;-1045.816,511.6096;Float;True;Property;_MainTex;Main Texture;7;1;[PerRendererData];Create;False;0;0;False;0;None;None;False;white;LockedToTexture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;48;-1100.735,-806.0909;Float;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;49;-1095.409,-675.988;Float;False;Property;_ReflectionFade;Reflection Fade;5;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;57;-1163.217,-381.3491;Float;False;602.0371;455.3698;Reflection Pass;2;2;36;Reflection Pass;1,1,1,1;0;0
Node;AmplifyShaderEditor.CustomExpressionNode;47;-756.6155,-753.699;Float;False;return ( pow( uvY, 16*(1-refFade) ) )@;1;False;2;True;uvY;FLOAT;0;In;True;refFade;FLOAT;0;In;Fade Node;True;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;41;-1042.058,730.6448;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-1113.217,-155.9794;Float;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;36;-1110.97,-334.9613;Float;False;Property;_Color;Color;8;1;[PerRendererData];Create;True;0;0;False;0;1,1,1,1;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;40;-1056.288,945.2369;Float;False;Property;_AlphaBackground;Alpha Background;9;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;59;63.31193,-548.9833;Float;False;1101.885;513.0035;Pseudo Sprite rendering;5;9;37;42;39;46;Final Composition;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;26;-810.7595,511.1718;Float;True;Property;_TextureSample1;Texture Sample 1;4;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;113.3119,-375.5984;Float;False;5;5;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-459.1256,606.7025;Float;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;42;297.395,-303.2328;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;39;512.2475,-498.9836;Float;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;46;545.7217,-150.98;Float;False;Constant;_Float0;Float 0;10;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;11;-123.5,-101.4;Float;False;False;2;Float;ASEMaterialInspector;0;1;ASETemplateShaders/LightWeight;1976390536c6c564abb90fe41f6ee334;0;2;DepthOnly;0;False;False;True;Off;False;False;False;False;False;True;4;RenderPipeline=LightweightPipeline;RenderType=Transparent;Queue=Transparent;PreviewType=Plane;True;2;0;0;0;False;False;True;Back;True;False;False;False;False;False;True;1;False;False;True;1;LightMode=DepthOnly;False;0;0;0;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;9;885.1974,-371.1286;Float;False;True;2;Float;ASEMaterialInspector;0;1;PIDI Shaders Collection/2D/Reflection Shaders/SRP/Lightweight/Distorted;1976390536c6c564abb90fe41f6ee334;0;0;Base;9;False;False;True;Off;False;False;False;False;False;True;4;RenderPipeline=LightweightPipeline;RenderType=Transparent;Queue=Transparent;PreviewType=Plane;True;2;0;0;0;True;2;SrcAlpha;OneMinusSrcAlpha;2;SrcAlpha;OneMinusSrcAlpha;False;False;False;False;True;1;True;3;False;True;1;LightMode=LightweightForward;False;0;0;0;9;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;10;-123.5,-101.4;Float;False;False;2;Float;ASEMaterialInspector;0;1;ASETemplateShaders/LightWeight;1976390536c6c564abb90fe41f6ee334;0;1;ShadowCaster;0;False;False;True;Off;False;False;False;False;False;True;4;RenderPipeline=LightweightPipeline;RenderType=Transparent;Queue=Transparent;PreviewType=Plane;True;2;0;0;0;False;False;False;False;False;True;1;True;3;False;True;1;LightMode=ShadowCaster;False;0;0;0;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;0
WireConnection;62;0;60;0
WireConnection;62;1;61;0
WireConnection;31;0;62;0
WireConnection;31;2;35;0
WireConnection;31;1;34;0
WireConnection;27;0;33;0
WireConnection;27;1;31;0
WireConnection;30;0;29;0
WireConnection;30;1;27;0
WireConnection;19;0;15;0
WireConnection;19;1;24;0
WireConnection;28;0;19;0
WireConnection;28;1;30;0
WireConnection;47;0;48;2
WireConnection;47;1;49;0
WireConnection;2;0;1;0
WireConnection;2;1;28;0
WireConnection;26;0;25;0
WireConnection;37;0;36;0
WireConnection;37;1;36;4
WireConnection;37;2;2;0
WireConnection;37;3;26;4
WireConnection;37;4;47;0
WireConnection;43;0;26;0
WireConnection;43;1;41;0
WireConnection;43;2;41;4
WireConnection;43;3;40;0
WireConnection;42;0;37;0
WireConnection;42;1;43;0
WireConnection;39;0;42;0
WireConnection;9;0;46;0
WireConnection;9;2;42;0
WireConnection;9;5;46;0
WireConnection;9;6;39;3
ASEEND*/
//CHKSM=E3E0C8BEAE00F7D98EC791DE16392754E104AC0F