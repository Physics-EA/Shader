// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/SimpleVertexFragmentShader"
{

	//针对显卡A的SubShader
	SubShader
	{
		//设置渲染状态和标签
		Pass
		{
			//开始CG代码片段
			CGPROGRAM
			//该段代码的编译指令
			#pragma vertex vert
			#pragma fragment frag

			float4 vert(float4 v:POSITION) :SV_POSITION
			{
				return UnityObjectToClipPos(v);
			}

			fixed4 frag() : SV_Target
			{
				return fixed4(0.4,0.5,1.0,0.0);
			}
			//CG代码结束标志。
			ENDCG
		}
		//其他Pass
	}

		FallBack "Diffuse"
}
