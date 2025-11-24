Shader "Custom/UI_OutlineGlow"
{
    Properties
    {
        _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        _OutlineColor ("Outline Color", Color) = (1,1,0,1)
        _OutlineSize ("Outline Size", Float) = 1
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        Lighting Off Cull Off ZWrite Off Fog { Mode Off }
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _OutlineColor;
            float _OutlineSize;
            float4 _MainTex_ST;

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float alpha = tex2D(_MainTex, uv).a;

                // Outline Sampling
                float outline = 0.0;
                float2 offset = _OutlineSize / _ScreenParams.xy;
                outline += tex2D(_MainTex, uv + float2(offset.x, 0)).a;
                outline += tex2D(_MainTex, uv + float2(-offset.x, 0)).a;
                outline += tex2D(_MainTex, uv + float2(0, offset.y)).a;
                outline += tex2D(_MainTex, uv + float2(0, -offset.y)).a;
                outline = step(0.01, outline);

                fixed4 col = tex2D(_MainTex, uv) * _Color;

                // Outline with Alpha
                col.rgb = lerp(_OutlineColor.rgb, col.rgb, alpha);
                col.a = max(col.a, outline * _OutlineColor.a);

                return col;
            }
            ENDCG
        }
    }
}