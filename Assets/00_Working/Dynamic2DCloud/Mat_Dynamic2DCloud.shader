
Shader "MyShader_2D/Dynamic2DCloud"
{
    Properties
    {
        _Background ("Background", 2D) = "white" {}
        _NoiseTex("Noise", 2D) = "white" {}
        _Threshold("Threshold", Range(0.0, 1.0)) = 0.5
        _EdgeLength("Edge Length", Range(0.0, 1)) = 0.1
        _EdgeTex("Edge Tex", 2D) = "white" {}

        _TimeScale("Time Scale", Range(0.0, 1.0)) = 0.5

        _uvRange("SingleUV" , Vector) = (0,0,0,0) 
    }

    SubShader
    {
        LOD 200

        Tags
        {
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
        }
        
        Pass
        {
            Cull Off
            Lighting Off
            ZWrite Off
            Fog { Mode Off }
            Offset -1, -1
            Blend SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag            
            #include "UnityCG.cginc"

            sampler2D _Background;
            float4 _MainTex_ST;
            //half4 _MainTex_TexelSize;
            sampler2D _NoiseTex;
			float4 _NoiseTex_ST;
			float _Threshold;
			float _EdgeLength;
			sampler2D _EdgeTex;
			float4 _EdgeTex_ST;
			float4 _uvRange;
            float _TimeScale;

            struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uvMain : TEXCOORD0;
				float2 uvNoise : TEXCOORD1;
			};

			v2f vert(appdata_full v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uvMain = v.texcoord.xy;
                o.uvNoise = TRANSFORM_TEX(v.texcoord, _NoiseTex);
				return o;
			}

            fixed4 frag (v2f i) : SV_Target
            {
                float temp = _Threshold;

                fixed2 timeValue = _Time.xx * _TimeScale;

				fixed cutout = tex2D(_NoiseTex, i.uvMain + timeValue).r;

                clip(cutout - temp);

				float degree = saturate((cutout - temp) / _EdgeLength);

				fixed4 col = tex2D(_Background, i.uvMain);

                fixed finalAlpha = degree * col.a;

				return fixed4(col.rgb, finalAlpha);


                // float temp = _Threshold;
                // // 本来是把小图的uv映射到NoiseTex的uv上的，不过后来觉得这样就不够随机了。。。
                // //float2 singleUv = float2((i.uvMain.x - _uvRange.x) / (_uvRange.z - _uvRange.x), (i.uvMain.y - _uvRange.y) / (_uvRange.w - _uvRange.y));
                // //singleUv = clamp(singleUv, 0, 1);
                // fixed2 timeValue = _Time.xx * _TimeScale;
                // // 所以把原来的uv放大5倍，效果还可以
				// fixed cutout = tex2D(_NoiseTex, i.uvMain ).r;
				// // 在NoiseTex上的采样值大于temp？这个像素就丢了？显示透明还是？
                // // 感觉是消失的那部分，_Threshold
                // //clip(cutout - temp);
                // // 采样值分布在（0，1）之间，跟据EdgeLength放大
				// //float degree = saturate((cutout - temp) / _EdgeLength);

                // fixed para1 = tex2D(_NoiseTex, i.uvMain).r - _Threshold;

                // fixed para2 = tex2D(_NoiseTex, i.uvMain * 2).r;
                // //fixed4 edgeColor = 
				// // 跟据degree采样EdgeTex，uv中应该只有u是有用的，
                // //fixed4 edgeColor = tex2D(_EdgeTex, float2(degree, degree));
                // // 采样背景图
				// fixed4 col = tex2D(_Background, i.uvMain);

                // //col = fixed4(col.rgb, degree);
                // // 线性插值，返回 (1 - c) * a + c * b
				// //fixed4 finalColor = lerp(edgeColor, col, degree);
				// fixed finalAlpha = (1 - para1) * col.a;
                // // 使用原来的透明度
                // //return col;
				// return fixed4(col.rgb, finalAlpha);
            }
            ENDCG
        }
    }
}
