// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "UnityShadersBook/Chapter11/Billboard"
{
	Properties
	{
		_MainTex("Main Tex", 2D) = "white" {}
		_Color("Color Tint", Color) = (1,1,1,1)
		//调整时是固定法线还是固定指向上的方向，即约束垂直方向的程度
		_VerticalBillboarding("Vertical Restraints", Range(0,1)) = 1
	}
		SubShader
	{
		//由于序列帧图像通常是透明背景，所以需要设置pass的相关状态，以渲染透明效果
		//半透明“标配”,DisableBatching指明是否对该SubShader使用批处理，批处理会合并所有相关模型，模型各自的模型空间就会丢失
		//广告牌技术需要使用物体的模型空间下的位置来作为锚点进行计算
		Tags{ "Queue" = "Transparent" "IgnoreProject" = "True" "RenderType" = "Transparent" "DisableBatching" = "True" }

		Pass
	{
		Tags{ "LightMode" = "ForwardBase" }
		//为了让广告牌的每个面都能显示
		//关闭深度写入
		ZWrite off
		//开启并设置混合模式
		Blend SrcAlpha OneMinusSrcAlpha
		//关闭剔除功能
		Cull Off

		CGPROGRAM
#pragma vertex vert
#pragma fragment frag

#include "UnityCG.cginc"

		sampler2D _MainTex;
	float4 _MainTex_ST;
	fixed4 _Color;
	float _VerticalBillboarding;

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
		//选择模型空间的原点作为广告牌的锚点
		float3 center = float3(0, 0, 0);
		//获取模型空间下的视角位置
		float3 viewer = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));

		//开始计算3个正交矢量
		//根据观察方向和锚点计算目标法线方向
		float3 normalDir = viewer - center;
		//根据_VerticalBillboarding属性控制垂直方向上的约束
		//当_VerticalBillboarding为1时，法线方向固定，为视角方向；
		//当_VerticalBillboarding为0时，向上方向固定，为(0,1,0)
		//获得的法线方向需要进行归一化操作得到单位矢量
		normalDir.y = normalDir.y * _VerticalBillboarding;
		normalDir = normalize(normalDir);
		//获得粗略的向上方向，为了方式法线方向和向上方向平行(如果平行，叉积会得到错误的结果)，对法线方向的y分量进行判断
		float3 upDir = abs(normalDir.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);
		//根据法线方向和粗略的向上方向得到向右方向，并归一化
		float3 rightDir = normalize(cross(upDir, normalDir));
		//根据法线方向和向右方向获得准确的向上方向
		upDir = normalize(cross(normalDir, rightDir));

		//根据原始的位置相对于锚点的偏移量以及3个正交基矢量，以计算得到新的顶点位置
		float3 centerOffs = v.vertex.xyz - center;
		float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;

		//把模型空间的顶点位置变换到裁剪空间
		o.pos = UnityObjectToClipPos(float4(localPos, 1));
		o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		//对纹理进行采样
		fixed4 c = tex2D(_MainTex,i.uv);
	//混合颜色
	c.rgb *= _Color.rgb;
	return c;
	}
		ENDCG
	}
	}
		Fallback"Transparent/VertexLit"
}

