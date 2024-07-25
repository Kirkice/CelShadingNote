#ifndef MC_LIGHTING_INCLUDED
#define MC_LIGHTING_INCLUDED
#include "mc_shading_function.hlsl"

//  PBR PART
struct BRDFInput
{
    float3 L; // Direction to light source
    float3 V; // Direction to camera/viewer
    float3 N; // World space normal (unpacked from normal map)
    float3 X; // World space tangent (unpacked from tangent map)
    float3 Y; // World space bitangent
    float roughness; // From uniform or texture map
    float3 baseColor;
};

struct BRDFResults
{
    float3 diffuse;
    float3 specular;
    float3 clearcoat;
};

float sqr(float x)
{
    return x * x;
}

float luminance(float3 color)
{
    return dot(color, float3(0.299f, 0.587f, 0.114f));
}

float SchlickFresnel(float x)
{
    x = saturate(1.0f - x);
    float x2 = x * x;

    return x2 * x2 * x; // While this is equivalent to pow(1 - x, 5) it is two less mult instructions
}

// Isotropic Generalized Trowbridge Reitz with gamma == 1
float GTR1(float ndoth, float a)
{
    float a2 = a * a;
    float t = 1.0f + (a2 - 1.0f) * ndoth * ndoth;
    return (a2 - 1.0f) / (PI * log(a2) * t);
}

// Anisotropic Generalized Trowbridge Reitz with gamma == 2. This is equal to the popular GGX distribution.
float AnisotropicGTR2(float ndoth, float hdotx, float hdoty, float ax, float ay)
{
    return rcp(PI * ax * ay * sqr(sqr(hdotx / ax) + sqr(hdoty / ay) + sqr(ndoth)));
}

// Isotropic Geometric Attenuation Function for GGX. This is technically different from what Disney uses, but it's basically the same.
float SmithGGX(float alphaSquared, float ndotl, float ndotv)
{
    float a = ndotv * sqrt(alphaSquared + ndotl * (ndotl - alphaSquared * ndotl));
    float b = ndotl * sqrt(alphaSquared + ndotv * (ndotv - alphaSquared * ndotv));

    return 0.5f / (a + b);
}

// Anisotropic Geometric Attenuation Function for GGX.
float AnisotropicSmithGGX(float ndots, float sdotx, float sdoty, float ax, float ay)
{
    return rcp(ndots + sqrt(sqr(sdotx * ax) + sqr(sdoty * ay) + sqr(ndots)));
}

BRDFResults DisneyBRDF(BRDFInput i)
{
    BRDFResults output;
    output.diffuse = 0.0f;
    output.specular = 0.0f;
    output.clearcoat = 0.0f;

    float3 H = normalize(i.L + i.V); // Microfacet normal of perfect reflection

    float ndotl = saturate(dot(i.N, i.L));
    float ndotv = saturate(dot(i.N, i.V));
    float ndoth = saturate(dot(i.N, H));
    float ldoth = saturate(dot(i.L, H));

    float Cdlum = luminance(i.baseColor);

    float3 Ctint = Cdlum > 0.0f ? i.baseColor / Cdlum : 1.0f;
    float3 Cspec0 = lerp(_Specular * 0.08f * lerp(1.0f, Ctint, _SpecularTint), i.baseColor * (1.0f + _Specular),
                         _Metallic);
    float3 Csheen = lerp(1.0f, Ctint, _SheenTint);


    // Disney Diffuse
    float FL = SchlickFresnel(ndotl);
    float FV = SchlickFresnel(ndotv);

    float Fss90 = ldoth * ldoth * i.roughness;
    float Fd90 = 0.5f + 2.0f * Fss90;

    float Fd = lerp(1.0f, Fd90, FL) * lerp(1.0f, Fd90, FV);

    // Subsurface Diffuse (Hanrahan-Krueger brdf approximation)

    float Fss = lerp(1.0f, Fss90, FL) * lerp(1.0f, Fss90, FV);
    float ss = 1.25f * (Fss * (rcp(ndotl + ndotv) - 0.5f) + 0.5f);

    // Specular
    float alpha = i.roughness;
    float alphaSquared = alpha * alpha;

    // Anisotropic Microfacet Normal Distribution (Normalized Anisotropic GTR gamma == 2)
    float aspectRatio = sqrt(1.0f - _Anisotropic * 0.9f);
    float alphaX = max(0.001f, alphaSquared / aspectRatio);
    float alphaY = max(0.001f, alphaSquared * aspectRatio);
    float Ds = AnisotropicGTR2(ndoth, dot(H, i.X), dot(H, i.Y), alphaX, alphaY);

    // Geometric Attenuation
    float GalphaSquared = sqr(0.5f + i.roughness * 0.5f);
    float GalphaX = max(0.001f, GalphaSquared / aspectRatio);
    float GalphaY = max(0.001f, GalphaSquared * aspectRatio);
    float G = AnisotropicSmithGGX(ndotl, dot(i.L, i.X), dot(i.L, i.Y), GalphaX, GalphaY);
    G *= AnisotropicSmithGGX(ndotv, dot(i.V, i.X), dot(i.V, i.Y), GalphaX, GalphaY);
    // specular brdf denominator (4 * ndotl * ndotv) is baked into output here (I assume at least)  

    // Fresnel Reflectance
    float FH = SchlickFresnel(ldoth);
    float3 F = lerp(Cspec0, 1.0f, FH);

    // Sheen
    float3 Fsheen = lerp(Cspec0, 1.0f, SchlickFresnel(ndotv)) * _Sheen * Csheen;

    // Clearcoat (Hard Coded Index Of Refraction -> 1.5f -> F0 -> 0.04)
    float Dr = GTR1(ndoth, lerp(0.1f, 0.001f, _ClearCoatGloss)); // Normalized Isotropic GTR Gamma == 1
    float Fr = lerp(0.04, 1.0f, FH);
    float Gr = SmithGGX(ndotl, ndotv, 0.25f);


    output.diffuse = (1.0f / PI) * (lerp(Fd, ss, _Subsurface) * i.baseColor + Fsheen) * (1 - _Metallic) * (1 - F);
    output.specular = saturate(Ds * F * G);
    output.clearcoat = saturate(0.25f * _ClearCoat * Gr * Fr * Dr);

    return output;
}
#endif
