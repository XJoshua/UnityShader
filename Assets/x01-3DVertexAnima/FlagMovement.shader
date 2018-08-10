// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "Custom/WaveFlag3D"
{
    Properties
    {
        _Color ("Main Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" { }
        _WaveY ("Wave y", Range(0, 1))  = 0.1
        _WindSpeed("Wind Speed", Range(50,200)) = 100
    }

    SubShader
    {
        Pass
        {
            CULL Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            float4 _Color;
            sampler2D _MainTex;
            fixed _WaveY;
            float _WindSpeed;

            struct a2v {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 pos : POSITION;
                float2 uv: TEXCOORD0;
            };

            v2f vert (a2v v) {
                v2f o;

                float angle = _Time * _WindSpeed;

                //if(v.vertex.z < 5)
                //v.vertex.y = v.vertex.y + sin(v.vertex.z + v.vertex.x + angle) * _WaveY;

                v.vertex.x = v.vertex.x * 100 + v.vertex.z * 100;

                o.pos = UnityObjectToClipPos( v.vertex );

                o.uv = v.texcoord;
                return o;
            }

            float4 frag (v2f i) : COLOR
            {
                half4 color = saturate(tex2D(_MainTex, i.uv.xy));
                return color;
            }

            ENDCG
        }
    }
    Fallback "VertexLit"
}