// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Edu/ForwardRendering"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Gloss("Gloss",Range(8,256)) = 40
	}
		SubShader
		{
			Tags{ "RenderType" = "Opaque" "Queue" = "Geometry" "IgnoreProjector" = "ture" }

			//在第一个Pass中处理最重要的平行光
			//如果场景中没有任何平行光，那么base pass将会被当做全黑处理

				Pass
				{
					Tags{ "LightMode" = "ForwardBase" }

					CGPROGRAM
					#pragma multi_compile_fwdbase
					#pragma vertex vert
					#pragma fragment frag
					#include "UnityCG.cginc"
					#include "Lighting.cginc"

					fixed4 _Color;
					sampler2D _MainTex;
					float4 _MainTex_ST;
					float _Gloss;

					struct a2v
					{
						float4 vertex:POSITION;
						float4 texcoord:TEXCOORD0;
						float3 normal:NORMAL;
					};

					struct v2f
					{
						float4 pos:SV_POSITION;
						float3 worldNormal:TEXCOORD0;
						float2 uv:TEXCOORD1;
						float3 worldPos:TEXCOORD2;
					};

					v2f vert(a2v v)
					{
						v2f o;
						o.pos = UnityObjectToClipPos(v.vertex);
						o.worldNormal = UnityObjectToWorldNormal(v.normal);
						o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
						o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);

						return o;
					}

					fixed4 frag(v2f i) :SV_Target
					{
						float3 worldNormal = normalize(i.worldNormal);

						float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

						float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

						fixed3 albedo = tex2D(_MainTex,i.uv).rgb;

						fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;

						fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal,worldLightDir));

						fixed3 halfDir = normalize(worldLightDir + worldViewDir);

						fixed3 specular = _LightColor0.rgb * pow(saturate(dot(worldNormal,halfDir)),_Gloss);

						fixed atten = 1.0;
	
						return fixed4(ambient + (diffuse + specular)*atten ,1.0);
					}

					ENDCG
				}

				Pass
				{
					Tags{ "LightMode" = "ForwardAdd" }

					Blend One One

					CGPROGRAM
					#pragma multi_compile_fwdadd
					#pragma vertex vert
					#pragma fragment frag
					#include "UnityCG.cginc"
					#include "Lighting.cginc"
					#include "AutoLight.cginc"

					fixed4 _Color;
					sampler2D _MainTex;
					float4 _MainTex_ST;
					float _Gloss;

					struct a2v
					{
						float4 vertex:POSITION;
						float4 texcoord:TEXCOORD0;
						float3 normal:NORMAL;
					};

					struct v2f
					{
						float4 pos:SV_POSITION;
						float3 worldNormal:TEXCOORD0;
						float2 uv:TEXCOORD1;
						float3 worldPos:TEXCOORD2;
					};

					v2f vert(a2v v)
					{
						v2f o;
						o.pos = UnityObjectToClipPos(v.vertex);
						o.worldNormal = UnityObjectToWorldNormal(v.normal);
						o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
						o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
						return o;
					}

					fixed4 frag(v2f i) :SV_Target
					{
						float3 worldNormal = normalize(i.worldNormal);

						float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

						#ifdef USING_DIRECTIONAL_LIGHT
						fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
						#else
						fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
						#endif

						fixed3 albedo = tex2D(_MainTex,i.uv).rgb;

						fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;

						fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal,worldLightDir));

						fixed3 halfDir = normalize(worldLightDir + worldViewDir);

						fixed3 specular = _LightColor0.rgb * pow(saturate(dot(worldNormal,halfDir)),_Gloss);


						#ifdef USING_DIRECTIONAL_LIGHT
						fixed atten = 1.0;
						#else
						float3 lightCoord = mul(unity_WorldToLight,float4(i.worldPos,1)).xyz;
						fixed atten = tex2D(_LightTexture0,dot(lightCoord,lightCoord).rr).UNITY_ATTEN_CHANNEL;
						#endif

						return fixed4(ambient + (diffuse + specular)*atten ,1.0);
					}
					ENDCG
				}
		}
			FallBack "Diffuse"
}
