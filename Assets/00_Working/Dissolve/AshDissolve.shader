// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "MyShader_2D/AshDissolve-2"
{
	Properties
	{
		_MainTex ("MainTexture", 2D) = "white" {}
		[NoScaleOffset] _NoiseTex("Noise", 2D) = "white" {}
		[NoScaleOffset] _WhiteNoiseTex("White Noise", 2D) = "white" {}
		[NoScaleOffset] _RampTex("Border Ramp", 2D) = "white" {} //纹理要Clamp
		_EdgeWidth("Edge Width", Range(0.05, 0.2)) = 0.1
		_MinBorderY("Min Border Y", Float) = -0.5 //通常对应脚部Y坐标
		_MaxBorderY("Max Border Y", Float) = 0.5  //通常对应头部Y坐标
		_DistanceEffect("Distance Effect", Range(0.0, 1.0)) = 0.5

		_AshColor("Ash Color", Color) = (1,1,1,1)
		_AshWidth("[Ash Width", Range(0, 0.25)) = 0.1
		_FlyIntensity("Fly Intensity", Range(0,0.3)) = 0.1
		_AshDensity("Ash Density", Range(0, 1)) = 1
		_FlyDirection("Fly Direction", Vector) = (1,1,1,1) 

		_Threshold("Threshold", Range(0.0, 1.0)) = 0.5
	}
	SubShader
	{
		Tags { "Queue"="Geometry" "RenderType"="Opaque" }

		Pass
		{
			Cull Off 

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 uvMainTex : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NoiseTex;
			sampler2D _WhiteNoiseTex;
			fixed4 _AshColor;
			float _Threshold;
			float _EdgeWidth;
			sampler2D _RampTex;
			float _MinBorderY;
			float _MaxBorderY;
			float _DistanceEffect;
			float _AshWidth;
			float _FlyIntensity;
			float _AshDensity;
			float4 _FlyDirection;

			float GetNormalizedDist(float worldPosY)
			{
				float range = _MaxBorderY - _MinBorderY;
				float border = _MaxBorderY;

				float dist = abs(worldPosY - border);
				float normalizedDist = saturate(dist / range);
				return normalizedDist;
			}

			v2f vert (appdata v)
			{
				v2f o;
				o.uv = v.uv;
				o.uvMainTex = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				float cutout = GetNormalizedDist(o.worldPos.y);
				float3 localFlyDirection = normalize(mul(unity_WorldToObject, _FlyDirection.xyz));
				float flyDegree = (_Threshold - cutout)/_EdgeWidth;
				float val = max(0, flyDegree * _FlyIntensity);
				v.vertex.xyz += localFlyDirection * val;

				o.vertex = UnityObjectToClipPos(v.vertex);
				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 albedo = tex2D(_MainTex, i.uvMainTex);
				float commonNoise = tex2D(_NoiseTex, i.uv).r;
				float whiteNoise = tex2D(_WhiteNoiseTex, i.uv).r;

				float normalizedDist = GetNormalizedDist(i.worldPos.y);
				float cutout = commonNoise * (1 - _DistanceEffect) + normalizedDist * _DistanceEffect;

				float edgeCutout = cutout - _Threshold;
				clip(edgeCutout + _AshWidth); //延至灰烬宽度处才剔除掉
				
				float degree = saturate(edgeCutout / _EdgeWidth);
				fixed4 edgeColor = tex2D(_RampTex, float2(degree, degree));
				fixed4 finalColor = fixed4(lerp(edgeColor, albedo, degree).rgb, 1);
				if(degree < 0.001)
				{
					clip(whiteNoise * _AshDensity + normalizedDist * _DistanceEffect - _Threshold); //灰烬处用白噪声来进行碎片化
					finalColor = _AshColor;
				}

				return finalColor;
			}
			ENDCG
		}
	}
}




// Shader "MyShader_2D/AshDissolve"
// {
//     Properties
//     {
//         [NoScaleOffset] _Background ("Background", 2D) = "white" {}
//         [NoScaleOffset] _NoiseTex("Noise", 2D) = "white" {}
//         [NoScaleOffset] _WhiteNoiseTex("White Noise", 2D) = "white" {}
//         [NoScaleOffset] _EdgeTex("Edge Tex", 2D) = "white" {}

//         _Threshold("Threshold", Range(0.0, 1.0)) = 0.5
//         _EdgeLength("Edge Length", Range(0.0, 1)) = 0.1

//         _uvRange("SingleUV" , Vector) = (0,0,0,0) 
//         // 边界坐标
//         _MinBorderY("Min Border Y", Float) = -0.5 
// 		_MaxBorderY("Max Border Y", Float) = 0.5  
//         _DistanceEffect("Distance Effect", Range(0.0, 1.0)) = 0.5

//         _AshColor("Ash Color", Color) = (1,1,1,1)
// 		_AshWidth("Ash Width", Range(0, 0.25)) = 0.1
// 		_FlyIntensity("Fly Intensity", Range(0,0.3)) = 0.1
// 		_AshDensity("Ash Density", Range(0, 1)) = 1
// 		_FlyDirection("Fly Direction", Vector) = (1,1,1,1) 
//     }

//     SubShader
//     {
//         LOD 200

//         Tags
//         {
//             "Queue" = "Transparent"
//             "IgnoreProjector" = "True"
//             "RenderType" = "Transparent"
//         }
        
//         Pass
//         {
//             Cull Off
//             Lighting Off
//             ZWrite Off
//             Fog { Mode Off }
//             Offset -1, -1
//             Blend SrcAlpha OneMinusSrcAlpha
            
//             CGPROGRAM
//             #pragma vertex vert
//             #pragma fragment frag            
//             #include "UnityCG.cginc"

//             sampler2D _Background;
//             float4 _Background_ST;
//             //half4 _MainTex_TexelSize;
//             sampler2D _NoiseTex;
//             sampler2D _WhiteNoiseTex;
// 			float4 _NoiseTex_ST;
// 			float _Threshold;
// 			float _EdgeLength;
// 			sampler2D _EdgeTex;
// 			float4 _EdgeTex_ST;
// 			float4 _uvRange;

//             float _MinBorderY;
// 			float _MaxBorderY;

//             float _DistanceEffect;
//             fixed4 _AshColor;
// 			float _AshWidth;
// 			float _FlyIntensity;
// 			float _AshDensity;
// 			float4 _FlyDirection;

//             struct v2f
// 			{
// 				float4 pos : SV_POSITION;
// 				float2 uv : TEXCOORD0;
// 				float2 uvMainTex : TEXCOORD1;
// 				float3 worldPos : TEXCOORD2;
// 			};

//             float GetNormalizedDist(float worldPosY)
//             {
//                 float range = _MaxBorderY - _MinBorderY;
// 				float dist = abs(worldPosY - _MaxBorderY);
// 				float normalizedDist = saturate(dist / range); // 取（0，1）的值
// 				return normalizedDist;
//             }

// 			v2f vert(appdata_full v)
// 			{
// 				v2f o;
				
// 				o.uv = v.texcoord.xy;
//                 o.worldPos = mul(unity_WorldToObject, v.vertex).xyz;
//                 o.uvMainTex = TRANSFORM_TEX(v.texcoord.xy, _Background);

//                 float cutout = GetNormalizedDist(o.worldPos.y);
//                 float3 localFlyDirection = normalize(mul(unity_WorldToObject, _FlyDirection.xyz));
//                 float flyDegree = (_Threshold - cutout)/_EdgeLength;
//                 float val = max(0, flyDegree * _FlyIntensity);
//                 v.vertex.xyz += localFlyDirection * val;

//                 o.pos = UnityObjectToClipPos(v.vertex);

// 				return o;
// 			}

//             fixed4 frag (v2f i) : SV_Target
//             {
//                 // 主纹理采样
//                 fixed4 albedo = tex2D(_Background, i.uvMainTex);
//                 // 边缘采样
// 				float commonNoise = tex2D(_NoiseTex, i.uv).r;
//                 // 白噪音采样
// 				float whiteNoise = tex2D(_WhiteNoiseTex, i.uv).r;

//                 // 
// 				float normalizedDist = GetNormalizedDist(i.worldPos.y);
// 				float cutout = commonNoise * (1 - _DistanceEffect) + normalizedDist * _DistanceEffect;

// 				float edgeCutout = cutout - _Threshold;
//                 // 延至灰烬宽度处才剔除掉
// 				clip(edgeCutout + _AshWidth); 
				
// 				float degree = saturate(edgeCutout / _EdgeLength);
// 				fixed4 edgeColor = tex2D(_EdgeTex, float2(degree, degree));
// 				fixed4 finalColor = fixed4(lerp(edgeColor, albedo, degree).rgb, 1);

// 				if(degree < 0.001)
// 				{
//                     // 灰烬处用白噪声来进行碎片化
// 					clip(whiteNoise * _AshDensity + normalizedDist * _DistanceEffect - _Threshold); 
// 					finalColor = _AshColor;
// 				}

// 				return finalColor;

//                 // float temp = _Threshold;
//                 // // 本来是把小图的uv映射到NoiseTex的uv上的，不过后来觉得这样就不够随机了。。。
//                 // //float2 singleUv = float2((i.uvMain.x - _uvRange.x) / (_uvRange.z - _uvRange.x), (i.uvMain.y - _uvRange.y) / (_uvRange.w - _uvRange.y));
//                 // //singleUv = clamp(singleUv, 0, 1);
//                 // // 所以把原来的uv放大5倍，效果还可以
// 				// fixed cutout = tex2D(_NoiseTex, i.uv * 5 ).r;
// 				// // 在NoiseTex上的采样值大于temp？这个像素就丢了？显示透明还是？
//                 // // 感觉是消失的那部分，_Threhold
//                 // clip(cutout - temp);
//                 // // 采样值分布在（0，1）之间，跟据EdgeLength放大
// 				// float degree = saturate((cutout - temp) / _EdgeLength * 0.7);
// 				// // 跟据degree采样EdgeTex，uv中应该只有u是有用的，
//                 // fixed4 edgeColor = tex2D(_EdgeTex, float2(degree, degree));
//                 // // 采样背景图
// 				// fixed4 col = tex2D(_Background, i.uv);
//                 // // 背景变成黑色透明
//                 // col = fixed4(0, 0, 0, col.a * 0.6);
//                 // // 线性插值，返回 (1 - c) * a + b * c
// 				// fixed4 finalColor = lerp(edgeColor, col, degree);
//                 // // 使用原来的透明度
// 				// return fixed4(finalColor.rgb, col.a);
//             }
//             ENDCG
//         }
//     }
// }

