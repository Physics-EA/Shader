// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "UnityShadersBook/Chapter10/GlassRefraction"
{

	Properties
	{
		_MainTex("Main Tex", 2D) = "white" {}
		_BumpMap("Normal Map", 2D) = "bump" {}
		_Cubemap("Environment Cubemap", Cube) = "_Skybox" {}
		_Distortion("Distortion", Range(0, 100)) = 10
		_RefractAmount("Refract Amount", Range(0.0, 1.0)) = 1.0
	}
	
		
	SubShader
	{
		// 1.队列设置成透明的可以保证渲染该物体的时候，其他所有不透明的物体都已经被渲染到屏幕上了
		//   这样GrabPass保存屏幕图像的时候才能完整
		// 2.渲染类型设置为不透明是为了使用着色器替换的时候，物体可以在被需要时正确的渲染
		Tags{ "Queue" = "Transparent" "RenderType" = "Opaque" }

		// 抓取屏幕图像并保存到纹理 _RefractionTex 中
		GrabPass{ "_RefractionTex" }

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			samplerCUBE _Cubemap;
			float _Distortion;
			fixed _RefractAmount;
			sampler2D _RefractionTex;
			// 可以得到系统保存的纹素的尺寸大小 1/256,1/512
			// 对屏幕图像坐标采样进行偏移的时候需要使用该变量
			float4 _RefractionTex_TexelSize;

			struct a2v 
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float2 texcoord: TEXCOORD0;
			};

			struct v2f 
			{
				float4 pos : SV_POSITION;
				float4 scrPos : TEXCOORD0;
				float4 uv : TEXCOORD1;
				float4 TtoW0 : TEXCOORD2;
				float4 TtoW1 : TEXCOORD3;
				float4 TtoW2 : TEXCOORD4;
			};

			v2f vert(a2v v) 
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				// 得到对应被抓取的屏幕图像的采样坐标
				o.scrPos = ComputeGrabScreenPos(o.pos);

				// 原图和法线贴图公用同一套UV坐标，进行纹理偏移缩放设置
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

				// 世界方向
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				// 法线世界方向
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);

				// 切线世界方向
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);

				// 世界副切线方向
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

				// 定义：切线空间到世界空间的变换矩阵
				// 所有的TBN都从切线空间转换到了世界空间
				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				// 世界空间
				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);

				// 世界空间下的观察方向
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));

				// 对法线贴图进行采样，并使用UnpackNormal解压*2-1，但实际上法线贴图在切线空间下
				// 所以需要将bump从切线空间转换到世界空间
				fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));

				// 对采样坐标进行偏移
				float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
				i.scrPos.xy = offset * i.scrPos.z + i.scrPos.xy;

				// 对屏幕纹理进行采样
				fixed3 refrCol = tex2D(_RefractionTex, i.scrPos.xy / i.scrPos.w).rgb;

				// 将bump从切线空间转换到世界空间
				// TtoW0的xyz：T的X，B的X，N的X
				// 用点积得到一个常量
				bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));

				// 用法线贴图求反射方向
				fixed3 reflDir = reflect(-worldViewDir, bump);

				// 主纹理采样
				fixed4 texColor = tex2D(_MainTex, i.uv.xy);

				// 对_Cubemap进行纹理采样，使用反射方向
				fixed3 reflCol = texCUBE(_Cubemap, reflDir).rgb * texColor.rgb;

				// 反射颜色+折射颜色
				fixed3 finalColor = reflCol * (1 - _RefractAmount) + refrCol * _RefractAmount;

				return fixed4(finalColor, 1);
			}

			ENDCG
		}
	}

		FallBack "Diffuse"
}

