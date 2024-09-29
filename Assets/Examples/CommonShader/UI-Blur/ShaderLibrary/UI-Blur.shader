Shader "Unlit/UI-Blur"
{
    Properties
    {
        [Header(UI)]
        _Color ("Tint", Color) = (1,1,1,1)

        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
        
        [Header(Grainy Blur)]
        [Toggle]_EnableGrainy("enable",float) = 0
        _BlurRadius("BlurRadius", Range(0,0.02)) = 0.001
        _Iteration("Iteration", int) = 8
        
        [Header(Gaussian Blur)]
        [Toggle]_EnableGaussian("enable",float) = 0
        _Samples("Samples", float) = 32
        _Scale("Scale",Range(0,0.01)) = 0.001
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]
        
        Pass
        {
            Tags
            {
                "LightMode" = "UIBlur"
            }
            
            HLSLPROGRAM
            #pragma vertex VS
            #pragma fragment PS
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct VertexIn
            {
                float4 PosL : POSITION;
                float4 color : COLOR;
            };
            
            struct VertexOut
            {
                float4 PosH : SV_POSITION;
                float2 ScreenUV : TEXCOORD0;
                float4 color : TEXCOORD1;
            };

            TEXTURE2D(_CameraScreenTexture);
            SAMPLER(sampler_CameraScreenTexture); 
            uniform float4 _CameraScreenTexture_ST;
            uniform float4 _CameraScreenTexture_TexelSize;
            uniform float _BlurRadius;
            uniform int _Iteration;
            uniform float _Scale;
            uniform float _Samples;
            uniform float _EnableGrainy;
            uniform float _EnableGaussian;
            
            VertexOut VS(VertexIn vin)
            {
                VertexOut vout = (VertexOut)0;
                vout.PosH = TransformObjectToHClip(vin.PosL);
                float4 PosSS = ComputeScreenPos(vout.PosH);
                vout.ScreenUV = PosSS.xy / PosSS.w;
                vout.color = vin.color;
                return vout;
            }
            
            float gaussian(half2 i, half sigma) {
                return exp( - 0.5 * dot(i /= sigma, i) ) / ( 6.28 * sigma * sigma );
            }

            half4 blur(half2 U) {
                half4 O = half4(0,0,0,1);  
                int s = _Samples;
                half sigma = _Samples * 0.25;
                
                for ( int i = 0; i < s*s; i++ ) {
                    half2 d = half2(i%s, i/s) - float(_Samples)/2.0;
                    O += gaussian(d,sigma) * SAMPLE_TEXTURE2D(_CameraScreenTexture, sampler_CameraScreenTexture, U + _Scale * d);
                }
                
                return O;
            }

            
            float Rand(float2 n)
            {
	            return sin(dot(n, half2(1233.224, 1743.335)));
            }
            
            half4 GrainyBlur(VertexOut pin)
            {
	            half2 randomOffset = float2(0.0, 0.0);
	            half4 finalColor = half4(0.0, 0.0, 0.0, 0.0);
	            float random = Rand(pin.ScreenUV);
	            
	            for (int k = 0; k < int(_Iteration); k ++)
	            {
		            random = frac(43758.5453 * random + 0.61432);;
		            randomOffset.x = (random - 0.5) * 2.0;
		            random = frac(43758.5453 * random + 0.61432);
		            randomOffset.y = (random - 0.5) * 2.0;
		            
		            finalColor += SAMPLE_TEXTURE2D(_CameraScreenTexture, sampler_CameraScreenTexture, half2(pin.ScreenUV + randomOffset * _BlurRadius));
	            }
	            return finalColor / _Iteration;
            }
            
            half4 PS(VertexOut pin) : SV_Target
            {
                half4 color = SAMPLE_TEXTURE2D(_CameraScreenTexture, sampler_CameraScreenTexture, pin.ScreenUV);
                UNITY_BRANCH
                if (_EnableGaussian)
                    color = blur(pin.ScreenUV);

                UNITY_BRANCH
                if (_EnableGrainy)
                    color = GrainyBlur(pin);
                
                return half4(color.rgb * pin.color,pin.color.a);
            }
            
            ENDHLSL
        }
    }
}