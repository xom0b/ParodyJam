// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PIDI Shaders Collection/2D/Reflection Shaders/SRP/Lightweight/Distorted Vertical"
{
	Properties
	{
		[Toggle]_InvertProjection("Invert Projection", Float) = 0
		[PerRendererData]_Reflection2D("Reflection Texture", 2D) = "black" {}
		[PerRendererData]_SurfaceLevel("Surface Level", Range( -4 , 4)) = 0
		[PerRendererData]_MainTex("Main Texture", 2D) = "white" {}
		[NoScaleOffset]_DistortionNormalmap("Distortion Normalmap", 2D) = "bump" {}
		_DistortionMapScale("Distortion Map Scale", Vector) = (1,1,0,0)
		_DistortionIntensity("Distortion Intensity", Range( 0 , 0.15)) = 0
		_DistortionPanningSpeed("Distortion Panning Speed", Vector) = (0,0,0,0)
		[PerRendererData]_Color("Color", Color) = (1,1,1,1)
		[PerRendererData]_AlphaBackground("Alpha Background", Float) = 0
		_ReflectionFade("Reflection Fade", Range( 0 , 1)) = 0
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
			uniform float _InvertProjection;
			uniform float _DistortionIntensity;
			uniform sampler2D _DistortionNormalmap;
			uniform float2 _DistortionPanningSpeed;
			uniform float2 _DistortionMapScale;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float _ReflectionFade;
			uniform float _AlphaBackground;
			float2 CalculateReflection19( float surfaceLevel , float4 vertexPos , float gameCam )
			{
				float4 srfc = mul(UNITY_MATRIX_VP, mul(unity_ObjectToWorld, float4(surfaceLevel,0,0,1) ) );
				float4 pos = vertexPos;
				float2 screenUV = pos.xy;
				screenUV.x = lerp(pos.x+surfaceLevel, 1-pos.x+srfc.x, 1-gameCam);
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
				float4 ase_texcoord9 : TEXCOORD9;
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
				o.ase_texcoord8 = screenPos;
				
				o.ase_texcoord7 = v.vertex;
				o.ase_texcoord9.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord9.zw = 0;
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
				float4 unityObjectToClipPos64 = TransformWorldToHClip(TransformObjectToWorld(IN.ase_texcoord7.xyz));
				float4 computeScreenPos62 = ComputeScreenPos( unityObjectToClipPos64 );
				float4 vertexPos19 = computeScreenPos62;
				float gameCam19 = _InvertProjection;
				float2 localCalculateReflection19 = CalculateReflection19( surfaceLevel19 , vertexPos19 , gameCam19 );
				float4 screenPos = IN.ase_texcoord8;
				float4 ase_screenPosNorm = screenPos/screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 panner31 = ( _Time.y * _DistortionPanningSpeed + ( ase_screenPosNorm * float4( _DistortionMapScale, 0.0 , 0.0 ) ).xy);
				float2 uv_MainTex = IN.ase_texcoord9.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode26 = tex2D( _MainTex, uv_MainTex );
				float uvY47 = IN.ase_texcoord9.xy.x;
				float refFade47 = _ReflectionFade;
				float localFadeNode47 = FadeNode47( uvY47 , refFade47 );
				float4 temp_output_42_0 = ( ( _Color * tex2D( _Reflection2D, ( float3( localCalculateReflection19 ,  0.0 ) + ( _DistortionIntensity * UnpackNormal( tex2D( _DistortionNormalmap, panner31 ) ) ) ).xy ) * _Color.a * tex2DNode26.a * localFadeNode47 ) + ( tex2DNode26 * IN.ase_color * IN.ase_color.a * _AlphaBackground ) );
				
				
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
			uniform float _InvertProjection;
			uniform float _DistortionIntensity;
			uniform sampler2D _DistortionNormalmap;
			uniform float2 _DistortionPanningSpeed;
			uniform float2 _DistortionMapScale;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float _ReflectionFade;
			uniform float _AlphaBackground;
			float2 CalculateReflection19( float surfaceLevel , float4 vertexPos , float gameCam )
			{
				float4 srfc = mul(UNITY_MATRIX_VP, mul(unity_ObjectToWorld, float4(surfaceLevel,0,0,1) ) );
				float4 pos = vertexPos;
				float2 screenUV = pos.xy;
				screenUV.x = lerp(pos.x+surfaceLevel, 1-pos.x+srfc.x, 1-gameCam);
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
				float4 ase_texcoord9 : TEXCOORD9;
				float4 ase_color : COLOR;
			};

			GraphVertexOutput vert (GraphVertexInput v)
			{
				GraphVertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float4 ase_clipPos = TransformObjectToHClip(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord8 = screenPos;
				
				o.ase_texcoord7 = v.vertex;
				o.ase_texcoord9.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord9.zw = 0;

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
				float4 unityObjectToClipPos64 = TransformWorldToHClip(TransformObjectToWorld(IN.ase_texcoord7.xyz));
				float4 computeScreenPos62 = ComputeScreenPos( unityObjectToClipPos64 );
				float4 vertexPos19 = computeScreenPos62;
				float gameCam19 = _InvertProjection;
				float2 localCalculateReflection19 = CalculateReflection19( surfaceLevel19 , vertexPos19 , gameCam19 );
				float4 screenPos = IN.ase_texcoord8;
				float4 ase_screenPosNorm = screenPos/screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 panner31 = ( _Time.y * _DistortionPanningSpeed + ( ase_screenPosNorm * float4( _DistortionMapScale, 0.0 , 0.0 ) ).xy);
				float2 uv_MainTex = IN.ase_texcoord9.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode26 = tex2D( _MainTex, uv_MainTex );
				float uvY47 = IN.ase_texcoord9.xy.x;
				float refFade47 = _ReflectionFade;
				float localFadeNode47 = FadeNode47( uvY47 , refFade47 );
				float4 temp_output_42_0 = ( ( _Color * tex2D( _Reflection2D, ( float3( localCalculateReflection19 ,  0.0 ) + ( _DistortionIntensity * UnpackNormal( tex2D( _DistortionNormalmap, panner31 ) ) ) ).xy ) * _Color.a * tex2DNode26.a * localFadeNode47 ) + ( tex2DNode26 * IN.ase_color * IN.ase_color.a * _AlphaBackground ) );
				

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
			uniform float _InvertProjection;
			uniform float _DistortionIntensity;
			uniform sampler2D _DistortionNormalmap;
			uniform float2 _DistortionPanningSpeed;
			uniform float2 _DistortionMapScale;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float _ReflectionFade;
			uniform float _AlphaBackground;
			float2 CalculateReflection19( float surfaceLevel , float4 vertexPos , float gameCam )
			{
				float4 srfc = mul(UNITY_MATRIX_VP, mul(unity_ObjectToWorld, float4(surfaceLevel,0,0,1) ) );
				float4 pos = vertexPos;
				float2 screenUV = pos.xy;
				screenUV.x = lerp(pos.x+surfaceLevel, 1-pos.x+srfc.x, 1-gameCam);
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
				float4 ase_texcoord9 : TEXCOORD9;
				float4 ase_color : COLOR;
			};

			GraphVertexOutput vert (GraphVertexInput v)
			{
				GraphVertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float4 ase_clipPos = TransformObjectToHClip(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord8 = screenPos;
				
				o.ase_texcoord7 = v.vertex;
				o.ase_texcoord9.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord9.zw = 0;

				v.vertex.xyz +=  float3(0,0,0) ;
				o.clipPos = TransformObjectToHClip(v.vertex.xyz);
				return o;
			}

			half4 frag (GraphVertexOutput IN ) : SV_Target
		    {
		    	UNITY_SETUP_INSTANCE_ID(IN);

				float surfaceLevel19 = _SurfaceLevel;
				float4 unityObjectToClipPos64 = TransformWorldToHClip(TransformObjectToWorld(IN.ase_texcoord7.xyz));
				float4 computeScreenPos62 = ComputeScreenPos( unityObjectToClipPos64 );
				float4 vertexPos19 = computeScreenPos62;
				float gameCam19 = _InvertProjection;
				float2 localCalculateReflection19 = CalculateReflection19( surfaceLevel19 , vertexPos19 , gameCam19 );
				float4 screenPos = IN.ase_texcoord8;
				float4 ase_screenPosNorm = screenPos/screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 panner31 = ( _Time.y * _DistortionPanningSpeed + ( ase_screenPosNorm * float4( _DistortionMapScale, 0.0 , 0.0 ) ).xy);
				float2 uv_MainTex = IN.ase_texcoord9.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode26 = tex2D( _MainTex, uv_MainTex );
				float uvY47 = IN.ase_texcoord9.xy.x;
				float refFade47 = _ReflectionFade;
				float localFadeNode47 = FadeNode47( uvY47 , refFade47 );
				float4 temp_output_42_0 = ( ( _Color * tex2D( _Reflection2D, ( float3( localCalculateReflection19 ,  0.0 ) + ( _DistortionIntensity * UnpackNormal( tex2D( _DistortionNormalmap, panner31 ) ) ) ).xy ) * _Color.a * tex2DNode26.a * localFadeNode47 ) + ( tex2DNode26 * IN.ase_color * IN.ase_color.a * _AlphaBackground ) );
				

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
1373;161;1352;589;2996.777;-818.1154;1.275675;True;True
Node;AmplifyShaderEditor.CommentaryNode;53;-2531.727,597.3746;Float;False;1316.976;805.6387;The normal based distortion effect to be applied to both the reflection and refraction passes;10;65;35;34;33;30;27;29;31;66;67;Distortion Effect;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;54;-2509.109,-238.4862;Float;False;823.785;585.952;The normal based distortion effect to be applied to both the reflection and refraction passes;6;50;15;19;62;64;63;Reflection Projection;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;65;-2473.75,857.5855;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;66;-2467.372,1045.186;Float;False;Property;_DistortionMapScale;Distortion Map Scale;5;0;Create;True;0;0;False;0;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-2202.032,926.5479;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PosVertexDataNode;63;-2460.641,-104.368;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;34;-2473.443,1327.553;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;35;-2472.797,1206.653;Float;False;Property;_DistortionPanningSpeed;Distortion Panning Speed;7;0;Create;True;0;0;False;0;0,0;0.2,0.3;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PannerNode;31;-1928.445,933.9918;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.UnityObjToClipPosHlpNode;64;-2460.641,33.63202;Float;False;1;0;FLOAT3;0,0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;33;-2472.414,665.472;Float;True;Property;_DistortionNormalmap;Distortion Normalmap;4;1;[NoScaleOffset];Create;True;0;0;False;0;None;ae86d0d0acd02ec4ab7f9f7c70b189e9;True;bump;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SamplerNode;27;-1736.07,844.879;Float;True;Property;_0;0;4;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;29;-1719.268,717.9582;Float;False;Property;_DistortionIntensity;Distortion Intensity;6;0;Create;True;0;0;False;0;0;0.054;0;0.15;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComputeScreenPosHlpNode;62;-2239.641,64.63202;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-2459.109,-188.4862;Float;False;Property;_SurfaceLevel;Surface Level;2;1;[PerRendererData];Create;True;0;0;False;0;0;-0.34;-4;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-2455.006,216.3123;Float;False;Property;_InvertProjection;Invert Projection;0;1;[Toggle];Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;58;-1021.422,442.1721;Float;False;838.3394;482.6584;Main sampling of the sprite texture;5;43;25;26;41;40;Albedo & Alpha Control;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;55;-1769.173,-1005.27;Float;False;302;280;;1;1;Reflection texture;1,1,1,1;0;0
Node;AmplifyShaderEditor.CustomExpressionNode;19;-1938.324,144.1214;Float;False;float4 srfc = mul(UNITY_MATRIX_VP, mul(unity_ObjectToWorld, float4(surfaceLevel,0,0,1) ) )@$float4 pos = vertexPos@$float2 screenUV = pos.xy@$screenUV.x = lerp(pos.x+surfaceLevel, 1-pos.x+srfc.x, 1-gameCam)@$$return screenUV@;2;False;3;True;surfaceLevel;FLOAT;0;In;True;vertexPos;FLOAT4;0,0,0,0;In;True;gameCam;FLOAT;0;In;Calculate Reflection;True;False;3;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-1383.752,690.9693;Float;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;56;-960.0797,-1000.859;Float;False;612.3094;298.3608;Vertical fading effect;3;49;48;47;Reflection Fade;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;48;-903.8895,-945.8591;Float;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;25;-971.4222,497.8898;Float;True;Property;_MainTex;Main Texture;3;1;[PerRendererData];Create;False;0;0;False;0;None;None;False;white;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-910.0797,-817.4984;Float;False;Property;_ReflectionFade;Reflection Fade;10;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-1312.024,-108.3297;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;1;-1719.173,-955.2698;Float;True;Property;_Reflection2D;Reflection Texture;1;1;[PerRendererData];Create;False;0;0;False;0;None;None;False;black;LockedToTexture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.CommentaryNode;57;-1120.251,-397.1537;Float;False;541.4277;504.2621;Reflection Pass;2;36;2;Reflection Pass;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;59;-231.9854,-347.3555;Float;False;876.9374;569.8557;Pseudo Sprite rendering;7;37;42;39;46;9;10;11;Final Composition;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-709.1091,760.6956;Float;False;Property;_AlphaBackground;Alpha Background;9;1;[PerRendererData];Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;47;-564.7704,-898.4673;Float;False;return ( pow( uvY, 16*(1-refFade) ) )@;1;False;2;True;uvY;FLOAT;0;In;True;refFade;FLOAT;0;In;Fade Node;True;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;26;-742.038,492.1721;Float;True;Property;_TextureSample1;Texture Sample 1;4;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;41;-968.67,722.8309;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-1070.251,-136.5256;Float;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;36;-1056.867,-336.9281;Float;False;Property;_Color;Color;8;1;[PerRendererData];Create;True;0;0;False;0;1,1,1,1;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-181.9854,-182.7139;Float;False;5;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-352.0826,580.4662;Float;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;42;57.5923,89.50022;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;46;285.2429,-297.3555;Float;False;Constant;_Float0;Float 0;10;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;39;-7.351067,-296.8367;Float;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;10;-123.5,-101.4;Float;False;False;2;Float;ASEMaterialInspector;0;1;ASETemplateShaders/LightWeight;1976390536c6c564abb90fe41f6ee334;0;1;ShadowCaster;0;False;False;True;Off;False;False;False;False;False;True;4;RenderPipeline=LightweightPipeline;RenderType=Transparent;Queue=Transparent;PreviewType=Plane;True;2;0;0;0;False;False;False;False;False;True;1;True;3;False;True;1;LightMode=ShadowCaster;False;0;0;0;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;11;-123.5,-101.4;Float;False;False;2;Float;ASEMaterialInspector;0;1;ASETemplateShaders/LightWeight;1976390536c6c564abb90fe41f6ee334;0;2;DepthOnly;0;False;False;True;Off;False;False;False;False;False;True;4;RenderPipeline=LightweightPipeline;RenderType=Transparent;Queue=Transparent;PreviewType=Plane;True;2;0;0;0;False;False;True;Back;True;False;False;False;False;False;True;1;False;False;True;1;LightMode=DepthOnly;False;0;0;0;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;9;364.952,-158.8649;Float;False;True;2;Float;ASEMaterialInspector;0;1;PIDI Shaders Collection/2D/Reflection Shaders/SRP/Lightweight/Distorted Vertical;1976390536c6c564abb90fe41f6ee334;0;0;Base;9;False;False;True;Off;False;False;False;False;False;True;4;RenderPipeline=LightweightPipeline;RenderType=Transparent;Queue=Transparent;PreviewType=Plane;True;2;0;0;0;True;2;SrcAlpha;OneMinusSrcAlpha;2;SrcAlpha;OneMinusSrcAlpha;False;False;False;False;True;1;True;3;False;True;1;LightMode=LightweightForward;False;0;0;0;9;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT3;0,0,0;False;0
WireConnection;67;0;65;0
WireConnection;67;1;66;0
WireConnection;31;0;67;0
WireConnection;31;2;35;0
WireConnection;31;1;34;0
WireConnection;64;0;63;0
WireConnection;27;0;33;0
WireConnection;27;1;31;0
WireConnection;62;0;64;0
WireConnection;19;0;15;0
WireConnection;19;1;62;0
WireConnection;19;2;50;0
WireConnection;30;0;29;0
WireConnection;30;1;27;0
WireConnection;28;0;19;0
WireConnection;28;1;30;0
WireConnection;47;0;48;1
WireConnection;47;1;49;0
WireConnection;26;0;25;0
WireConnection;2;0;1;0
WireConnection;2;1;28;0
WireConnection;37;0;36;0
WireConnection;37;1;2;0
WireConnection;37;2;36;4
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
//CHKSM=E65ECD555E6514D2DE98025831730D10E10085BF