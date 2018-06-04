

Shader "MyShader_2D/Silhouette"
{
    Properties
    {
        _Background ("Background", 2D) = "white" {}
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

            struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert(appdata_full v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord.xy;
				return o;
			}

            fixed4 frag (v2f i) : COLOR
            {
                fixed4 col;
                col = tex2D(_Background, i.uv);
                //col.rgb = dot(col.rgb, fixed3(0.222, 0.707 ,0.071));
                col.rgb = fixed3(0,0,0);
                col.a *= 0.6;
                return col;
            }
            ENDCG
        }
    }
}
