
Shader "UI/FlashLight" 
{
	Properties 
	{
		[NoScaleOffset] _MainTex ("Main Texture", 2D) = "white" {}

        _LightTex ("Light Texture", 2D) = "white" {}

        _FlashColor("Light Color",Color) = (1,1,1,1)

        _ScrollSpeed("ScrollValue",Range(-10, 10)) = 2

        _TimeInterval("TimeInterval(not second)", Range(1, 10)) = 5

        _Slope("Slope", Range(0, 5)) = 0.5
	}
	SubShader 
	{
		Tags
        {
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
        }

		Cull Off
        Lighting Off
        ZWrite Off
        Fog { Mode Off }
        Offset -1, -1
        Blend SrcAlpha OneMinusSrcAlpha 
        AlphaTest Greater 0.1

		Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float2 lightuv : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _LightTex ;
            float4  _LightTex_ST;

            half4 _FlashColor ;
            float _ScrollSpeed;
            float _TimeInterval;
            float _Slope;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 采样颜色
                fixed4 col = tex2D(_MainTex, i.uv);
                // 缓存贴图的透明度
				float a = col.a;
                // 计算流光的移动值
                fixed ScrollValue = _ScrollSpeed * _Time.y - 2;
                float2 scrolledUV = i.uv + fixed2(ScrollValue, 0.0f);
                // 根据需要的 斜率，流光间隔 调整移动值
				scrolledUV = float2(fmod(scrolledUV.x * _Slope, _TimeInterval), scrolledUV.y);
                // 采样流光贴图
                float4 lightCol = tex2D(_LightTex, scrolledUV);
                // 和主贴图颜色混合
                float3 finalColor = col.rgb + _FlashColor * lightCol;
                // 读取缓存的透明度
                fixed4 finalRGBA = fixed4(finalColor, a);
                
                return finalRGBA;
            }
			ENDCG
		}
	}
	FallBack "Diffuse"
}
