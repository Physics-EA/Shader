Shader "UnityShadersBook/Chapter10/Mirror"
{
	Properties
	{
		_MainTex("Main Tex",2D) = "white"{}
	}
		SubShader
	{
		Tags{ "RenderType" = "Opaque" "Queue" = "Geometry" }

		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag


			//包含引用的内置文件  
			#include "Lighting.cginc"  

			//声明properties中定义的属性  
			sampler2D _MainTex;
	
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
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				//在水平方向上反转纹理
				o.uv.x = 1 - o.uv.x;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				//对渲染纹理进行采样和输出
				return tex2D(_MainTex,i.uv);

			}
			ENDCG
		}
	}
		Fallback"Reflective/VertexLit"
}