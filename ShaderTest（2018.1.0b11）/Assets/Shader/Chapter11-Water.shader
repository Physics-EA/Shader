// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "UnityShadersBook/Chapter11/Water"
{
		Properties
	{
		//河流纹理
		_MainTex("Main Tex", 2D) = "white" {}
		//控制整体颜色
		_Color("Color Tint", Color) = (1,1,1,1)
		//控制水流波动的幅度
		_Magnitude("Distortion Magnitude", Float) = 1
		//控制水流波动的频率
		_Frequency("Distortion Frequency", Float) = 1
		//控制波长的倒数，倒数越大，波长越小
		_InvWaveLength("Distortion Inverse Wave Length", Float) = 10
		//河流纹理的移动速度
		_Speed("Speed",Float) = 0.5
	}
	
	SubShader
	{
		//由于序列帧图像通常是透明背景，所以需要设置pass的相关状态，以渲染透明效果
		//半透明“标配”,DisableBatching指明是否对该SubShader使用批处理，批处理会合并所有相关模型，模型各自的模型空间就会丢失
		Tags{ "Queue" = "Transparent" "IgnoreProject" = "True" "RenderType" = "Transparent" "DisableBatching" = "True" }

		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }
			//为了让水流的每个面都能显示
			//关闭深度写入
			ZWrite off
			//开启并设置混合模式
			Blend SrcAlpha OneMinusSrcAlpha
			//关闭剔除功能
			Cull Off


			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
					// make fog work
			#pragma multi_compile_fog

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;
			float _Magnitude;
			float _Frequency;
			float _InvWaveLength;
			float _Speed;

			struct a2v
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};



			v2f vert(a2v v)
			{
				v2f o;
				float4 offset;
				offset.yzw = float3(0.0, 0.0, 0.0);
				//_Frequency*_Time.y控制正弦函数频率
				//加上模型空间下的分量乘以_InvWaveLength位置控制不同位置具有不同的位移
				//乘以_Magnitude控制波动幅度
				offset.x = sin(_Frequency * _Time.y + v.vertex.x * _InvWaveLength + v.vertex.y * _InvWaveLength + v.vertex.z * _InvWaveLength) * _Magnitude;
				//把位移量添加到顶点位置上
				o.pos = UnityObjectToClipPos(v.vertex + offset);
				//进行纹理动画，使用_Time.y和_Speed控制水平方向上的位移
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv += float2(0.0, _Time.y * _Speed);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				//对纹理进行简单采样
				fixed4 c = tex2D(_MainTex, i.uv);
				// 添加颜色控制
				c.rgb *= _Color.rgb;
				return c;
			}
			ENDCG
		}
	}
		Fallback"Transparent/VertexLit"
}

