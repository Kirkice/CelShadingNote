Shader "Unlit/UI-Blur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
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
            "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"
        }

        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            
            HLSLPROGRAM
            #pragma vertex VS
            #pragma fragment PS
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct VertexIn
            {
                float4 PosL : POSITION;
                float2 TexC : TEXCOORD0;
            };
            
            struct VertexOut
            {
                float4 PosH : SV_POSITION;
                float4 TexC : TEXCOORD0;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex); 
            uniform float4 _MainTex_ST;
            uniform float4 _MainTex_TexelSize;
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
                vout.TexC.xy = vin.TexC;
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
                    O += gaussian(d,sigma) * SAMPLE_TEXTURE2D( _MainTex, sampler_MainTex, U + _Scale * d);
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
	            float random = Rand(pin.TexC);
	            
	            for (int k = 0; k < int(_Iteration); k ++)
	            {
		            random = frac(43758.5453 * random + 0.61432);;
		            randomOffset.x = (random - 0.5) * 2.0;
		            random = frac(43758.5453 * random + 0.61432);
		            randomOffset.y = (random - 0.5) * 2.0;
		            
		            finalColor += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, half2(pin.TexC + randomOffset * _BlurRadius));
	            }
	            return finalColor / _Iteration;
            }
            
            half4 PS(VertexOut pin) : SV_Target
            {
                UNITY_BRANCH
                if (_EnableGaussian)
                    return blur(pin.TexC);

                UNITY_BRANCH
                if (_EnableGrainy)
                    return GrainyBlur(pin);
                
                return SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, pin.TexC);
            }
            
            ENDHLSL
        }
    }
}