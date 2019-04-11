
Shader "Custom/ShaderLabProperties"
{
	Properties
	{
		_Int("Int",Int) = 2
		_Float("Float",Float) = 1.5
		_Range("Range",Range(0.0,5.0)) = 3.0

		_Color("Color",Color) = (1,1,1,1)
		_Vector("Vector",Vector) = (2,3,6,1)

		_2D("2D",2D) = ""{}
		_Cube("Cube",Cube) = "White"{}
		_3D("3D",3D) = "black"{}
	}


		SubShader
	{
		Tags {"Queue" = "Transparent" }
		//[RenderSetup]

		Pass
		{
			//[Name]
			//[Tags]
			//[RenderSetup]
		}
	}

		FallBack "Diffuse"

}
