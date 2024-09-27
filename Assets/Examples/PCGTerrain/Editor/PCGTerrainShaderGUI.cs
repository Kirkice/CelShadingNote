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
    public PartitioningMode partitioningMode;
    public OutputtopologyMode outputtopologyMode;

    public GUILayoutOption[] shortButtonStyle = new GUILayoutOption[] { GUILayout.Width(130) };
    public GUILayoutOption[] middleButtonStyle = new GUILayoutOption[] { GUILayout.Width(130) };
    public GUILayoutOption[] bigButtonStyle = new GUILayoutOption[] { GUILayout.Width(180) };

    public void FindProperties(MaterialProperty[] props)
    {
        AlbedoTex0 = FindProperty(ShaderIDs.AlbedoTex0, props, false);
        NormalTex0 = FindProperty(ShaderIDs.NormalTex0, props, false);
        TangentTex0 = FindProperty(ShaderIDs.TangentTex0, props, false);
        NormalStrength0 = FindProperty(ShaderIDs.NormalStrength0, props, false);
        BaseColor0 = FindProperty(ShaderIDs.BaseColor0, props, false);
        Metallic0 = FindProperty(ShaderIDs.Metallic0, props, false);
        Subsurface0 = FindProperty(ShaderIDs.Subsurface0, props, false);
        Specular0 = FindProperty(ShaderIDs.Specular0, props, false);
        RoughnessMapMod0 = FindProperty(ShaderIDs.RoughnessMapMod0, props, false);
        Roughness0 = FindProperty(ShaderIDs.Roughness0, props, false);
        SpecularTint0 = FindProperty(ShaderIDs.SpecularTint0, props, false);
        Anisotropic0 = FindProperty(ShaderIDs.Anisotropic0, props, false);
        Sheen0 = FindProperty(ShaderIDs.Sheen0, props, false);
        SheenTint0 = FindProperty(ShaderIDs.SheenTint0, props, false);
        ClearCoat0 = FindProperty(ShaderIDs.ClearCoat0, props, false);
        ClearCoatGloss0 = FindProperty(ShaderIDs.ClearCoatGloss0, props, false);
        SkyboxCube0 = FindProperty(ShaderIDs.SkyboxCube0, props, false);
        IndirectF0_0 = FindProperty(ShaderIDs.IndirectF0_0, props, false);
        IndirectF90_0 = FindProperty(ShaderIDs.IndirectF90_0, props, false);
        AlbedoTex1 = FindProperty(ShaderIDs.AlbedoTex1, props, false);
        NormalTex1 = FindProperty(ShaderIDs.NormalTex1, props, false);
        TangentTex1 = FindProperty(ShaderIDs.TangentTex1, props, false);
        NormalStrength1 = FindProperty(ShaderIDs.NormalStrength1, props, false);
        BaseColor1 = FindProperty(ShaderIDs.BaseColor1, props, false);
        Metallic1 = FindProperty(ShaderIDs.Metallic1, props, false);
        Subsurface1 = FindProperty(ShaderIDs.Subsurface1, props, false);
        Specular1 = FindProperty(ShaderIDs.Specular1, props, false);
        RoughnessMapMod1 = FindProperty(ShaderIDs.RoughnessMapMod1, props, false);
        Roughness1 = FindProperty(ShaderIDs.Roughness1, props, false);
        SpecularTint1 = FindProperty(ShaderIDs.SpecularTint1, props, false);
        Anisotropic1 = FindProperty(ShaderIDs.Anisotropic1, props, false);
        Sheen1 = FindProperty(ShaderIDs.Sheen1, props, false);
        SheenTint1 = FindProperty(ShaderIDs.SheenTint1, props, false);
        ClearCoat1 = FindProperty(ShaderIDs.ClearCoat1, props, false);
        ClearCoatGloss1 = FindProperty(ShaderIDs.ClearCoatGloss1, props, false);
        SkyboxCube1 = FindProperty(ShaderIDs.SkyboxCube1, props, false);
        IndirectF0_1 = FindProperty(ShaderIDs.IndirectF0_1, props, false);
        IndirectF90_1 = FindProperty(ShaderIDs.IndirectF90_1, props, false);
        AlbedoTex2 = FindProperty(ShaderIDs.AlbedoTex2, props, false);
        NormalTex2 = FindProperty(ShaderIDs.NormalTex2, props, false);
        TangentTex2 = FindProperty(ShaderIDs.TangentTex2, props, false);
        NormalStrength2 = FindProperty(ShaderIDs.NormalStrength2, props, false);
        BaseColor2 = FindProperty(ShaderIDs.BaseColor2, props, false);
        Metallic2 = FindProperty(ShaderIDs.Metallic2, props, false);
        Subsurface2 = FindProperty(ShaderIDs.Subsurface2, props, false);
        Specular2 = FindProperty(ShaderIDs.Specular2, props, false);
        RoughnessMapMod2 = FindProperty(ShaderIDs.RoughnessMapMod2, props, false);
        Roughness2 = FindProperty(ShaderIDs.Roughness2, props, false);
        SpecularTint2 = FindProperty(ShaderIDs.SpecularTint2, props, false);
        Anisotropic2 = FindProperty(ShaderIDs.Anisotropic2, props, false);
        Sheen2 = FindProperty(ShaderIDs.Sheen2, props, false);
        SheenTint2 = FindProperty(ShaderIDs.SheenTint2, props, false);
        ClearCoat2 = FindProperty(ShaderIDs.ClearCoat2, props, false);
        ClearCoatGloss2 = FindProperty(ShaderIDs.ClearCoatGloss2, props, false);
        SkyboxCube2 = FindProperty(ShaderIDs.SkyboxCube2, props, false);
        IndirectF0_2 = FindProperty(ShaderIDs.IndirectF0_2, props, false);
        IndirectF90_2 = FindProperty(ShaderIDs.IndirectF90_2, props, false);
    }

    private MaterialEditor m_MaterialEditor;

    static bool _BasicShaderSettings_Foldout = true;
    static bool _BasicMsoSettings_Foldout = true;
    static bool _NormalSettings_Foldout = true;
    static bool _ParallaxSettings_Foldout = true;
    static bool _MatCapSettings_Foldout = true;
    static bool _EmissionSettings_Foldout = true;
    static bool _StencilSettings_Foldout = true;
    static bool _HSVSettings_Foldout = true;

    private MaterialProperty AlbedoTex0 = null;
    private MaterialProperty NormalTex0 = null;
    private MaterialProperty TangentTex0 = null;
    private MaterialProperty NormalStrength0 = null;

    private MaterialProperty BaseColor0 = null;
    private MaterialProperty Metallic0 = null;
    private MaterialProperty Subsurface0 = null;
    private MaterialProperty Specular0 = null;

    private MaterialProperty RoughnessMapMod0 = null;
    private MaterialProperty Roughness0 = null;
    private MaterialProperty SpecularTint0 = null;
    private MaterialProperty Anisotropic0 = null;
    private MaterialProperty Sheen0 = null;

    private MaterialProperty SheenTint0 = null;
    private MaterialProperty ClearCoat0 = null;
    private MaterialProperty ClearCoatGloss0 = null;
    private MaterialProperty SkyboxCube0 = null;
    private MaterialProperty IndirectF0_0 = null;
    private MaterialProperty IndirectF90_0 = null;

    private MaterialProperty AlbedoTex1 = null;
    private MaterialProperty NormalTex1 = null;
    private MaterialProperty TangentTex1 = null;
    private MaterialProperty NormalStrength1 = null;

    private MaterialProperty BaseColor1 = null;
    private MaterialProperty Metallic1 = null;
    private MaterialProperty Subsurface1 = null;
    private MaterialProperty Specular1 = null;

    private MaterialProperty RoughnessMapMod1 = null;
    private MaterialProperty Roughness1 = null;
    private MaterialProperty SpecularTint1 = null;
    private MaterialProperty Anisotropic1 = null;
    private MaterialProperty Sheen1 = null;

    private MaterialProperty SheenTint1 = null;
    private MaterialProperty ClearCoat1 = null;
    private MaterialProperty ClearCoatGloss1 = null;
    private MaterialProperty SkyboxCube1 = null;
    private MaterialProperty IndirectF0_1 = null;
    private MaterialProperty IndirectF90_1 = null;

    private MaterialProperty AlbedoTex2 = null;
    private MaterialProperty NormalTex2 = null;
    private MaterialProperty TangentTex2 = null;
    private MaterialProperty NormalStrength2 = null;

    private MaterialProperty BaseColor2 = null;
    private MaterialProperty Metallic2 = null;
    private MaterialProperty Subsurface2 = null;
    private MaterialProperty Specular2 = null;

    private MaterialProperty RoughnessMapMod2 = null;
    private MaterialProperty Roughness2 = null;
    private MaterialProperty SpecularTint2 = null;
    private MaterialProperty Anisotropic2 = null;
    private MaterialProperty Sheen2 = null;

    private MaterialProperty SheenTint2 = null;
    private MaterialProperty ClearCoat2 = null;
    private MaterialProperty ClearCoatGloss2 = null;
    private MaterialProperty SkyboxCube2 = null;
    private MaterialProperty IndirectF0_2 = null;
    private MaterialProperty IndirectF90_2 = null;

    private static class Styles
    {
        public static GUIContent AlbedoMapText =
            new GUIContent("AlbedoMap", "Albedo Color : Texture(sRGB) × Color(RGB) Default:White");

        public static GUIContent TangentMapText =
            new GUIContent("TangentTexture", "TangentTexture : Texture(sRGB) Default:White");

        public static GUIContent NormalMapText = new GUIContent("NormalMap", "NormalMap : Texture(bump)");

        public static GUIContent RoughnessMapText = new GUIContent("RoughnessMap", "RoughnessMap(RGB):");
    }
}