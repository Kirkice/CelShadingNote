using UnityEngine;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using UnityEditor;
using System;

public class MeshData
{
    public MeshData()
    {
        Indexs = new List<int>();
        Positions = new List<Vector3>();
        Normals = new List<Vector3>();
        Colors = new List<Color>();
        UV0s = new List<Vector2>();
        UV1s = new List<Vector2>();
        UV2s = new List<Vector2>();
        Tangents = new List<Vector4>();
    }

    public MeshData(int vetexCount)
    {
        Indexs = new List<int>(vetexCount);
        Indexs.AddRange(Enumerable.Repeat(0, vetexCount));
        Positions = new List<Vector3>(vetexCount);
        Positions.AddRange(Enumerable.Repeat(new Vector3(), vetexCount));
        Normals = new List<Vector3>(vetexCount);
        Normals.AddRange(Enumerable.Repeat(new Vector3(), vetexCount));
        Colors = new List<Color>(vetexCount);
        Colors.AddRange(Enumerable.Repeat(new Color(), vetexCount));
        UV0s = new List<Vector2>(vetexCount);
        UV0s.AddRange(Enumerable.Repeat(new Vector2(), vetexCount));
        UV1s = new List<Vector2>(vetexCount);
        UV1s.AddRange(Enumerable.Repeat(new Vector2(), vetexCount));
        UV2s = new List<Vector2>(vetexCount);
        UV2s.AddRange(Enumerable.Repeat(new Vector2(), vetexCount));
        Tangents = new List<Vector4>(vetexCount);
        Tangents.AddRange(Enumerable.Repeat(new Vector4(), vetexCount));
    }

    public List<int> Indexs;
    public List<Vector3> Positions;
    public List<Vector3> Normals;
    public List<Color> Colors;
    public List<Vector2> UV0s;
    public List<Vector2> UV1s;
    public List<Vector2> UV2s;
    public List<Vector4> Tangents;

    public int VetexCount => Positions.Count;
}

public class CSVtoMeshDynamic
{
    // // 此属性添加上下文菜单到Project视图中的.dds文件
    // [MenuItem("Assets/Convert To Mesh", true)]
    // private static bool FixDdsFileValidation()
    // {
    // // 这个验证方法决定菜单项的启用/禁用状态
    // string path = AssetDatabase.GetAssetPath(Selection.activeObject);
    // // 仅当选中的文件是.dds文件时，该菜单项才可用
    // return path.EndsWith(".csv");
    // }

    // 此方法在上下文菜单项被点击时调用
    [MenuItem("Assets/Convert To Mesh")]
    private static void ConvertToMesh()
    {
        UnityEngine.Object[] selectedAsset =
            Selection.GetFiltered(typeof(UnityEngine.Object), SelectionMode.DeepAssets);
        foreach (UnityEngine.Object obj in selectedAsset)
        {
            string path = AssetDatabase.GetAssetPath(obj);
            if (path.Contains(".csv"))
            {
                var data = File.ReadAllText(path);
                var mesh = CreateMeshFromDynamicCSV(data);
                var outFile = path.Replace(".csv", ".mesh");
                if (File.Exists(outFile.Replace("Assets/", Application.dataPath)))
                {
                    File.Delete(outFile.Replace("Assets/", Application.dataPath));
                }

                AssetDatabase.CreateAsset(mesh, outFile);
                AssetDatabase.SaveAssets();
            }
        }


        // string path = AssetDatabase.GetAssetPath(Selection.activeObject);
        // var data = File.ReadAllText(path);
        // var mesh = CreateMeshFromDynamicCSV(data);
        // var outFile = path.Replace(".csv", ".mesh");
        // if(File.Exists(outFile.Replace("Assets/",Application.dataPath)))
        // {
        //     File.Delete(outFile.Replace("Assets/",Application.dataPath));
        // }
        // AssetDatabase.CreateAsset(mesh, outFile);
        // AssetDatabase.SaveAssets();
    }


    private static Mesh CreateMeshFromDynamicCSV(string csvContent)
    {
        // 找到列分隔符，这里我们支持逗号或空白字符
        char[] delimiters = new char[] { ',', ' ', '\t', ';' };

        // 初始化存储数据的列表，动态分析文件时这些都是必要的
        MeshData orgMesh = new MeshData();

        // 读取CSV的每行
        string[] lines = csvContent.Split(new[] { '\r', '\n' }, System.StringSplitOptions.RemoveEmptyEntries);

        // 解析表头
        string[] headers = lines[0].Split(delimiters, System.StringSplitOptions.RemoveEmptyEntries);
        int posIndex = System.Array.FindIndex(headers, h => h.Contains("in_POSITION0"));
        int normalIndex = System.Array.FindIndex(headers, h => h.Contains("in_NORMAL0"));
        int texCoordIndex = System.Array.FindIndex(headers, h => h.Contains("in_TEXCOORD0"));
        int texCoord2Index = System.Array.FindIndex(headers, h => h.Contains("in_TEXCOORD1"));
        int texCoord3Index = System.Array.FindIndex(headers, h => h.Contains("in_TEXCOORD2"));
        int tangentIndex = System.Array.FindIndex(headers, h => h.Contains("in_TANGENT0"));
        int colorIndex = System.Array.FindIndex(headers, h => h.Contains("in_COLOR0"));
        int idxIndex = System.Array.FindIndex(headers, h => h.Equals("IDX"));
        int maxIndex = -1;
        for (int i = 1; i < lines.Length; ++i)
        {
            string[] cells = lines[i].Split(delimiters, System.StringSplitOptions.RemoveEmptyEntries);

            if (cells.Length > 0)
            {
                // 解析位置
                if (posIndex != -1)
                {
                    orgMesh.Positions.Add(ParseVector4FromCells(cells, posIndex));
                }

                // 解析法线
                if (normalIndex != -1)
                {
                    orgMesh.Normals.Add(ParseVector4FromCells(cells, normalIndex));
                }

                // 解析UV
                if (texCoordIndex != -1)
                {
                    orgMesh.UV0s.Add(ParseVector2FromCells(cells, texCoordIndex));
                }

                // 解析UV2
                if (texCoord2Index != -1)
                {
                    orgMesh.UV1s.Add(ParseVector2FromCells(cells, texCoord2Index));
                }


                // 解析UV3
                if (texCoord3Index != -1)
                {
                    orgMesh.UV2s.Add(ParseVector2FromCells(cells, texCoord3Index));
                }

                // 解析切线
                if (tangentIndex != -1)
                {
                    orgMesh.Tangents.Add(ParseVector4FromCells(cells, tangentIndex));
                }

                // 解析顶点颜色
                if (colorIndex != -1)
                {
                    orgMesh.Colors.Add(ParseVector4FromCells(cells, colorIndex));
                }

                // 解析索引
                if (idxIndex != -1 && int.TryParse(cells[idxIndex], out int idx))
                {
                    maxIndex = Math.Max(idx, maxIndex);
                    orgMesh.Indexs.Add(idx);
                }
            }
        }


        int vertexArrayCount = maxIndex + 1;
        MeshData descMesh = new MeshData(vertexArrayCount);

        Dictionary<int, int> flagDict = new Dictionary<int, int>(vertexArrayCount);
        for (int i = 0; i < orgMesh.VetexCount; ++i)
        {
            int index = orgMesh.Indexs[i];

            if (flagDict.ContainsKey(index))
            {
                continue;
            }

            flagDict.Add(index, 1);

            descMesh.Positions[index] = orgMesh.Positions[i];

            if (orgMesh.Normals.Any())
                descMesh.Normals[index] = orgMesh.Normals[i];

            if (orgMesh.Tangents.Any())
                descMesh.Tangents[index] = orgMesh.Tangents[i];

            if (orgMesh.UV0s.Any())
                descMesh.UV0s[index] = orgMesh.UV0s[i];

            if (orgMesh.UV1s.Any())
                descMesh.UV1s[index] = orgMesh.UV1s[i];

            if (orgMesh.UV2s.Any())
                descMesh.UV2s[index] = orgMesh.UV2s[i];

            if (orgMesh.Colors.Any())
                descMesh.Colors[index] = orgMesh.Colors[i];
        }


        // 创建Mesh
        Mesh mesh = new Mesh();
        mesh.SetVertices(descMesh.Positions);
        if (orgMesh.Normals.Any()) mesh.SetNormals(descMesh.Normals);
        if (orgMesh.UV0s.Any()) mesh.SetUVs(0, descMesh.UV0s);
        if (orgMesh.UV1s.Any()) mesh.SetUVs(1, descMesh.UV1s);
        if (orgMesh.UV2s.Any()) mesh.SetUVs(2, descMesh.UV2s);
        if (orgMesh.Tangents.Any()) mesh.SetTangents(descMesh.Tangents);
        if (orgMesh.Colors.Any()) mesh.SetColors(descMesh.Colors);


        mesh.triangles = orgMesh.Indexs.ToArray();
        mesh.RecalculateBounds();

        return mesh;
    }

    private static Vector2 ParseVector2FromCells(string[] cells, int index)
    {
        return new Vector2(
            float.Parse(cells[index], CultureInfo.InvariantCulture),
            float.Parse(cells[index + 1], CultureInfo.InvariantCulture));
    }

    private static Vector3 ParseVector3FromCells(string[] cells, int index)
    {
        return new Vector3(
            float.Parse(cells[index], CultureInfo.InvariantCulture),
            float.Parse(cells[index + 1], CultureInfo.InvariantCulture),
            float.Parse(cells[index + 2], CultureInfo.InvariantCulture));
    }

    private static Vector4 ParseVector4FromCells(string[] cells, int index)
    {
        if ((index + 3) < cells.Length)
        {
            return new Vector4(
                float.Parse(cells[index], CultureInfo.InvariantCulture),
                float.Parse(cells[index + 1], CultureInfo.InvariantCulture),
                float.Parse(cells[index + 2], CultureInfo.InvariantCulture),
                float.Parse(cells[index + 3], CultureInfo.InvariantCulture));   
        }
        else
        {
            return new Vector4(
                float.Parse(cells[index], CultureInfo.InvariantCulture),
                float.Parse(cells[index + 1], CultureInfo.InvariantCulture),
                float.Parse(cells[index + 2], CultureInfo.InvariantCulture),
                1);   
        }
    }
}