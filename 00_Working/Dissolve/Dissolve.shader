
Shader "MyShader_2D/Dissolve"
{
    Properties
    {
        _Background ("Background", 2D) = "white" {}
        _NoiseTex("Noise", 2D) = "white" {}
        _Threshold("Threshold", Range(0.0, 1.0)) = 0.5
        _EdgeLength("Edge Length", Range(0.0, 1)) = 0.1
        _EdgeTex("Edge Tex", 2D) = "white" {}

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
            // Cull Back
            // ZWrite On
            
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
                //float2 singleUv = float2((i.uvMain.x - _uvRange.x) / (_uvRange.z - _uvRange.x), (i.uvMain.y - _uvRange.y) / (_uvRange.w - _uvRange.y));
                //singleUv = clamp(singleUv, 0, 1);

				fixed cutout = tex2D(_NoiseTex, i.uvMain * 5 ).r;
				clip(cutout - temp);

				float degree = saturate((cutout - temp) / _EdgeLength * 0.7);
				fixed4 edgeColor = tex2D(_EdgeTex, float2(degree, degree));

				fixed4 col = tex2D(_Background, i.uvMain);
                col = fixed4(0, 0, 0, col.a*0.6);

				fixed4 finalColor = lerp(edgeColor, col, degree);
				return fixed4(finalColor.rgb, col.a);
            }
            ENDCG
        }
    }
}
