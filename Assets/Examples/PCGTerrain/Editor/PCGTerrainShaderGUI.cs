using System;
using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering.Universal;

public enum PartitioningMode
{
    Integer = 0,
    FractionalEven = 1,
    FractionalOdd = 2
}

public enum OutputtopologyMode
{
    TriangleCw = 0,
    TriangleCcw = 1
}

public class ShaderIDs
{
    // public static readonly string HeightMap = "_HeightMap";
    // public static readonly string Height = "_Height";
    // public static readonly string HeightAmount = "_HeightAmount";

    #region istLit PARAMES

    public static readonly string AlbedoTex0 = "_AlbedoTex0";
    public static readonly string NormalTex0 = "_NormalTex0";
    public static readonly string TangentTex0 = "_TangentTex0";
    public static readonly string NormalStrength0 = "_NormalStrength0";

    public static readonly string BaseColor0 = "_BaseColor0";
    public static readonly string Metallic0 = "_Metallic0";
    public static readonly string Subsurface0 = "_Subsurface0";
    public static readonly string Specular0 = "_Specular0";
    
    public static readonly string RoughnessMapMod0 = "_RoughnessMapMod0";
    public static readonly string Roughness0 = "_Roughness0";
    public static readonly string SpecularTint0 = "_SpecularTint0";
    public static readonly string Anisotropic0 = "_Anisotropic0";
    public static readonly string Sheen0 = "_Sheen0";
    
    public static readonly string SheenTint0 = "_SheenTint0";
    public static readonly string ClearCoat0 = "_ClearCoat0";
    public static readonly string ClearCoatGloss0 = "_ClearCoatGloss0";
    public static readonly string SkyboxCube0 = "_SkyboxCube0";
    public static readonly string IndirectF0_0 = "_IndirectF0_0";
    public static readonly string IndirectF90_0 = "_IndirectF90_0";

    
    public static readonly string AlbedoTex1 = "_AlbedoTex1";
    public static readonly string NormalTex1 = "_NormalTex1";
    public static readonly string TangentTex1 = "_TangentTex1";
    public static readonly string NormalStrength1 = "_NormalStrength1";

    public static readonly string BaseColor1 = "_BaseColor1";
    public static readonly string Metallic1 = "_Metallic1";
    public static readonly string Subsurface1 = "_Subsurface1";
    public static readonly string Specular1 = "_Specular1";
    
    public static readonly string RoughnessMapMod1 = "_RoughnessMapMod1";
    public static readonly string Roughness1 = "_Roughness1";
    public static readonly string SpecularTint1 = "_SpecularTint1";
    public static readonly string Anisotropic1 = "_Anisotropic1";
    public static readonly string Sheen1 = "_Sheen1";
    
    public static readonly string SheenTint1 = "_SheenTint1";
    public static readonly string ClearCoat1 = "_ClearCoat1";
    public static readonly string ClearCoatGloss1 = "_ClearCoatGloss1";
    public static readonly string SkyboxCube1 = "_SkyboxCube1";
    public static readonly string IndirectF0_1 = "_IndirectF0_1";
    public static readonly string IndirectF90_1 = "_IndirectF90_1";
    
    public static readonly string AlbedoTex2 = "_AlbedoTex2";
    public static readonly string NormalTex2 = "_NormalTex2";
    public static readonly string TangentTex2 = "_TangentTex2";
    public static readonly string NormalStrength2 = "_NormalStrength2";

    public static readonly string BaseColor2 = "_BaseColor2";
    public static readonly string Metallic2 = "_Metallic2";
    public static readonly string Subsurface2 = "_Subsurface2";
    public static readonly string Specular2 = "_Specular2";
    
    public static readonly string RoughnessMapMod2 = "_RoughnessMapMod2";
    public static readonly string Roughness2 = "_Roughness2";
    public static readonly string SpecularTint2 = "_SpecularTint2";
    public static readonly string Anisotropic2 = "_Anisotropic2";
    public static readonly string Sheen2 = "_Sheen2";
    
    public static readonly string SheenTint2 = "_SheenTint2";
    public static readonly string ClearCoat2 = "_ClearCoat2";
    public static readonly string ClearCoatGloss2 = "_ClearCoatGloss2";
    public static readonly string SkyboxCube2 = "_SkyboxCube2";
    public static readonly string IndirectF0_2 = "_IndirectF0_2";
    public static readonly string IndirectF90_2 = "_IndirectF90_2";
    
    public static readonly string TerrainTillingOffset = "_TerrainTillingOffset";
    public static readonly string MaxHeight = "_MaxHeight";
    public static readonly string TerrainPower = "_TerrainPower";
    public static readonly string TerrainStrength = "_TerrainStrength";
    public static readonly string EdgeFactor = "_EdgeFactor";
    public static readonly string InsideFactor = "_InsideFactor";

    #endregion
}

public class PCGTerrainShaderGUI : ShaderGUI
{

}