

Shader "MyShader_2D/WaveTest"
{
    Properties
    {
        _Background ("Background", 2D) = "white" {}
        _DistortionMap ("DistortionMap", 2D) = "white" {}
        _Strengthness("Strengthness",Range(0,2)) = 0.01
        _TimeScale("TimeScale",Range(0,1)) = 0.01

        _uvRange("UvRange", Vector) = (0,0,0,0)

        _Version("Version 0.35", Float) = 0.00
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
            //Cull Off
            //Lighting Off
            //ZWrite Off
            //Fog { Mode Off }
            //Offset -1, -1
            //Blend SrcAlpha OneMinusSrcAlpha
            Cull Back
            ZWrite On
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag            
            #include "UnityCG.cginc"

            sampler2D _Background;
            sampler2D _DistortionMap;
            float4 _MainTex_ST;
            float _Strengthness;
            float _TimeScale;
            float4 _uvRange;

            struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0; 
			};

			v2f vert(appdata_full  v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				//o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv = v.texcoord.xy;
				return o;
			}

            fixed4 frag (v2f i) : SV_Target
            {
                // _Time是预设的float4值，(t/20, t, t*2, t*3)
                // 采样DistortionMap，根据时间移动向上移动
                //i.uv.y -= _Time.xy * _TimeScale;
                //if(i.uv.y < 0) i.uv.y = 0;
                float4 disTex = tex2D(_DistortionMap, i.uv - _Time.xy * _TimeScale);
                // rgb值空间（0，1）转成UV值空间（-1，1）
                float2 offsetUV = ( - _Strengthness * (disTex - 0.5));
                
                float2 uv = i.uv + offsetUV;

                uv.x = clamp(uv.x, _uvRange.x, _uvRange.z);
                uv.y = clamp(uv.y, _uvRange.y, _uvRange.w);
                  
                return tex2D(_Background, uv);
            }
            ENDCG
        }
    }

    SubShader
    {
        LOD 100

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
            ColorMask RGB
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMaterial AmbientAndDiffuse
            
            SetTexture [_MainTex]
            {
                Combine Texture * Primary
            }
        }
    }
}
