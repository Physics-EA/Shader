// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "UnityShadersBook/Chapter11/ScrollingBackground"
{
	Properties
	{
		//第一层（较远）背景纹理
		_MainTex("Base Layer(RGB)", 2D) = "white" {}
		//第二层背景（较近）纹理
		_DetailTex("2nd Layer(RGB)", 2D) = "white"{}
		//第一层滚动速度
		_ScrollX("Base layer Scroll Speed", Float) = 1.0
		//第二层滚动速度
		_Scroll2X("2nd layer Scrool Speed", Float) = 1.0
		//控制纹理的整体亮度
		_Multiplier("Layer Multiplier", Float) = 1


	}
	
	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _DetailTex;
			float4 _DetailTex_ST;
			float _ScrollX;
			float _Scroll2X;
			float _Multiplier;

			struct a2v
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				float4 pos : SV_POSITION;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				//先用TRANSFORM_TEX获得初始的纹理坐标，在使用_Time.y变量在水平方向上对纹理坐标进行偏移
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex) + frac(float2(_ScrollX, 0.0) * _Time.y);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _DetailTex) + frac(float2(_Scroll2X, 0.0) * _Time.y);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				//对两张纹理进行采样
				fixed4 firstLayer = tex2D(_MainTex, i.uv.xy);
				fixed4 secondLayer = tex2D(_DetailTex, i.uv.zw);
				//使用第二层纹理的透明通道来混合两张纹理，使用CG的lerp函数
				fixed4 c = lerp(firstLayer, secondLayer, secondLayer.a);
				//使用_Multiplier参数和输出颜色相乘，调整背景亮度
				c.rgb *= _Multiplier;
				return c;
			}
			ENDCG
		}
	}
		Fallback "VertexLit"
}

