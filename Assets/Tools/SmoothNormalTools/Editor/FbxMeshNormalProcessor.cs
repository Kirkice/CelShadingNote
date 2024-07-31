using System.IO;
using Mikktspace.NET;
using System.Collections.Generic;
using Autodesk.Fbx;
using Unity.Mathematics;
using UnityEditor;
using UnityEngine;

public static class FbxMeshNormalProcessor
{
    public static void FbxModelNormalSmoothTool(Object[] selectionObjects, ChannelType type, ObjectSpace space)
    {
        if (selectionObjects.Length < 1)
        {
            return;
        }
        
        FbxManager fbxManager = FbxManager.Create();
        FbxIOSettings fbxIOSettings = FbxIOSettings.Create(fbxManager, Globals.IOSROOT);
        fbxManager.SetIOSettings(fbxIOSettings);

        int fbxFileCount = 0;
        int smoothedCount = 0;
        foreach (Object asset in selectionObjects)
        {
            string assetPath = AssetDatabase.GetAssetPath(asset);
            string oldExt = Path.GetExtension(assetPath).ToLower();
            if (!oldExt.Equals(".fbx"))
            {
                continue;
            }

            FbxImporter fbxImporter = FbxImporter.Create(fbxManager, "");
            if (!fbxImporter.Initialize(assetPath, -1, fbxIOSettings))
            {
                Debug.Log(fbxImporter.GetStatus().GetErrorString());
                continue;
            }
            FbxScene fbxScene = FbxScene.Create(fbxManager, "myScene");
            fbxImporter.Import(fbxScene);
            fbxImporter.Destroy();
            FbxNode rootNode = fbxScene.GetRootNode();
            if (rootNode == null)
            {
                continue;
            }

            fbxFileCount++;
            SearchMeshNode(rootNode, type, space);
            
            FbxExporter fbxExporter = FbxExporter.Create(fbxManager, "");
            if (!fbxExporter.Initialize(assetPath, -1, fbxIOSettings))
            {
                Debug.Log(fbxExporter.GetStatus().GetErrorString());
                continue;
            }

            smoothedCount++;
            fbxExporter.Export(fbxScene);
            fbxExporter.Destroy();
        }
        fbxManager.Destroy();
        AssetDatabase.Refresh();
        Debug.Log($"Fbx模型法线平滑化完成!\n共选中{fbxFileCount}个有效的FBX模型文件, 已成功平滑化处理{smoothedCount}个模型文件。");
    }

    static void SearchMeshNode(FbxNode currentNode, ChannelType type, ObjectSpace space)
    {
        FbxNodeAttribute nodeAttribute = currentNode.GetNodeAttribute();
        
        if (nodeAttribute != null)
        {
            FbxNodeAttribute.EType attributeType = nodeAttribute.GetAttributeType();
            if (attributeType == FbxNodeAttribute.EType.eMesh)
            {
                SmoothMeshNode(currentNode.GetMesh(), type, space);
            }
        }
        for (int i = 0; i < currentNode.GetChildCount(); i++)
        {
            SearchMeshNode(currentNode.GetChild(i), type, space);
        }
    }

    struct VertexInfo
    {
        public int vertexIndex;
        public FbxVector4 normal;
        public double weight;
    }

    static void SmoothMeshNode(FbxMesh fbxMesh, ChannelType type, ObjectSpace space)
    {
        int controlPointsCount = fbxMesh.GetControlPointsCount();
        List<List<VertexInfo>> controlIndexToVertexInfos = new List<List<VertexInfo>>();
        for (int i = 0; i < controlPointsCount; i++)
        {
            controlIndexToVertexInfos.Add(new List<VertexInfo>());
        }
        
        int vertexIndex = 0;
        for (int polygonIndex = 0; polygonIndex < fbxMesh.GetPolygonCount(); polygonIndex++)
        {
            int vertexCountInPolygon = fbxMesh.GetPolygonSize(polygonIndex);

            for (int vertexIndexInPolygon = 0; vertexIndexInPolygon < vertexCountInPolygon; vertexIndexInPolygon++)
            {
                int lastVertexIndex = (vertexIndexInPolygon - 1 + vertexCountInPolygon) % vertexCountInPolygon;
                int nextVertexIndex = (vertexIndexInPolygon + 1) % vertexCountInPolygon;
                
                int controlIndex = fbxMesh.GetPolygonVertex(polygonIndex, vertexIndexInPolygon);
                int lastControlIndex = fbxMesh.GetPolygonVertex(polygonIndex, lastVertexIndex);
                int nextControlIndex = fbxMesh.GetPolygonVertex(polygonIndex, nextVertexIndex);
                
                FbxVector4 controlPoint = fbxMesh.GetControlPointAt(controlIndex);
                FbxVector4 lastControlPoint = fbxMesh.GetControlPointAt(lastControlIndex);
                FbxVector4 nextControlPoint = fbxMesh.GetControlPointAt(nextControlIndex);
                
                fbxMesh.GetPolygonVertexNormal(polygonIndex, vertexIndexInPolygon, out FbxVector4 vertexNormal);
                vertexNormal /= vertexNormal.Length();
                
                FbxVector4 edge0 = lastControlPoint - controlPoint;
                FbxVector4 edge1 = nextControlPoint - controlPoint;

                edge0 /= edge0.Length();
                edge1 /= edge1.Length();
                
                double radian = math.acos(edge0.DotProduct(edge1));
                
                List<VertexInfo> vertexNormals = controlIndexToVertexInfos[controlIndex];
                vertexNormals.Add(new VertexInfo
                {
                    vertexIndex = vertexIndex++,
                    normal = vertexNormal,
                    weight = radian
                });
            }
        }

        // 存入UV2
        if (type == ChannelType.UV2)
        {
            FbxVector4[] meshTangents = GetMeshTangents(fbxMesh);
            int layerCount = fbxMesh.GetLayerCount();
            for (int i = 0; i < 2 - layerCount; i++)
            {
                int layerIndex = fbxMesh.CreateLayer();
                FbxLayer layer = fbxMesh.GetLayer(layerIndex);
                layer.SetUVs(FbxLayerElementUV.Create(fbxMesh, ""));
            }
            
            FbxLayer targetLayer = fbxMesh.GetLayer(1);
            FbxLayerElementUV targetUv = targetLayer.GetUVs();
            if (targetUv == null)
            {
                targetLayer.SetVertexColors(FbxLayerElementVertexColor.Create(fbxMesh, ""));
                targetUv = targetLayer.GetUVs();
            }
            
            targetUv.SetMappingMode(FbxLayerElement.EMappingMode.eByPolygonVertex);
            targetUv.SetReferenceMode(FbxLayerElement.EReferenceMode.eDirect);
            FbxLayerElementArrayTemplateFbxVector2 uvDirectArray = targetUv.GetDirectArray();
            uvDirectArray.SetCount(vertexIndex);

            for (int controlIndex = 0; controlIndex < controlPointsCount; controlIndex++)
            {
                List<VertexInfo> vertexInfos = controlIndexToVertexInfos[controlIndex];

                FbxVector4 smoothNormal = new FbxVector4();
                foreach (VertexInfo vertexInfo in vertexInfos)
                {
                    smoothNormal += vertexInfo.weight * vertexInfo.normal;
                }
                smoothNormal /= smoothNormal.Length();

                foreach (VertexInfo vertexInfo in vertexInfos)
                {
                    Vector3 vcolor = new float3((float)smoothNormal.X, (float)smoothNormal.Y, (float)smoothNormal.Z);
                    if (space == ObjectSpace.TangentSpace)
                    {
                        Vector3 N = new Vector3((float)vertexInfo.normal.X,(float)vertexInfo.normal.Y,(float)vertexInfo.normal.Z);
                        Vector3 T = new Vector3((float)meshTangents[vertexInfo.vertexIndex].X, (float)meshTangents[vertexInfo.vertexIndex].Y, (float)meshTangents[vertexInfo.vertexIndex].Z);
                        float sgn = (float)meshTangents[vertexInfo.vertexIndex].W;
                        Vector3 B = math.cross(N, T) * sgn;
                        float3x3 tbn = new float3x3(
                            T.x, B.x, N.x,
                            T.y, B.y, N.y,
                            T.z, B.z, N.z
                        );
                        float3x3 Inv_TBN = math.inverse(tbn);
                        vcolor = math.mul(Inv_TBN, new float3((float)smoothNormal.X,(float)smoothNormal.Y,(float)smoothNormal.Z));   
                    }
                    else
                    {
                        vcolor = new float3((float)smoothNormal.X,(float)smoothNormal.Y,(float)smoothNormal.Z);
                    }
                    uvDirectArray.SetAt(vertexInfo.vertexIndex, new FbxVector2(vcolor.x * 0.5f + 0.5f,vcolor.y * 0.5f + 0.5f));
                }
            }
        }
        else if(type == ChannelType.VertexColor)
        {
            FbxVector4[] meshTangents = GetMeshTangents(fbxMesh);
            FbxLayer targetLayer = fbxMesh.GetLayer(0);
            FbxLayerElementVertexColor targetColors = targetLayer.GetVertexColors();

            if (targetColors == null)
            {
                targetLayer.SetVertexColors(FbxLayerElementVertexColor.Create(fbxMesh, ""));
                targetColors = targetLayer.GetVertexColors();
            }
            
            targetColors.SetMappingMode(FbxLayerElement.EMappingMode.eByPolygonVertex);
            targetColors.SetReferenceMode(FbxLayerElement.EReferenceMode.eDirect);
            FbxLayerElementArrayTemplateFbxColor colorDirectArray = targetColors.GetDirectArray();
            colorDirectArray.SetCount(vertexIndex);
            
            for (int controlIndex = 0; controlIndex < controlPointsCount; controlIndex++)
            {
                List<VertexInfo> vertexInfos = controlIndexToVertexInfos[controlIndex];
                Debug.LogError(vertexInfos.Count);
                FbxVector4 smoothNormal = new FbxVector4();
                foreach (VertexInfo vertexInfo in vertexInfos)
                {
                    smoothNormal += vertexInfo.weight * vertexInfo.normal;
                }
                smoothNormal /= smoothNormal.Length();
                
                foreach (VertexInfo vertexInfo in vertexInfos)
                {
                    Vector3 vcolor = new float3((float)smoothNormal.X, (float)smoothNormal.Y, (float)smoothNormal.Z);
                    if (space == ObjectSpace.TangentSpace)
                    {
                        Vector3 N = new Vector3((float)vertexInfo.normal.X,(float)vertexInfo.normal.Y,(float)vertexInfo.normal.Z);
                        Vector3 T = new Vector3((float)meshTangents[vertexInfo.vertexIndex].X, (float)meshTangents[vertexInfo.vertexIndex].Y, (float)meshTangents[vertexInfo.vertexIndex].Z);
                        float sgn = (float)meshTangents[vertexInfo.vertexIndex].W;
                        Vector3 B = math.cross(N, T) * sgn;
                        float3x3 tbn = new float3x3(
                            T.x, B.x, N.x,
                            T.y, B.y, N.y,
                            T.z, B.z, N.z
                        );
                        float3x3 Inv_TBN = math.inverse(tbn);
                        vcolor = math.mul(Inv_TBN, new float3((float)smoothNormal.X,(float)smoothNormal.Y,(float)smoothNormal.Z));
                    }
                    else
                    {
                        vcolor = new float3((float)smoothNormal.X,(float)smoothNormal.Y,(float)smoothNormal.Z);
                    }
                    colorDirectArray.SetAt(vertexInfo.vertexIndex, new FbxColor(vcolor.x * 0.5f + 0.5f,vcolor.y * 0.5f + 0.5f,vcolor.z * 0.5f + 0.5f,1));
                }
            }
        }
        else
        {
            // FbxGeometryElementTangent tangent = fbxMesh.GetElementTangent(0);
            FbxLayer targetLayer = fbxMesh.GetLayer(0);
            FbxLayerElementTangent targetTangents = targetLayer.GetTangents();
            
            if (targetTangents == null)
            {
                targetLayer.SetTangents(FbxLayerElementTangent.Create(fbxMesh, ""));
                targetTangents = targetLayer.GetTangents();
            }
            
            targetTangents.SetMappingMode(FbxLayerElement.EMappingMode.eByPolygonVertex);
            targetTangents.SetReferenceMode(FbxLayerElement.EReferenceMode.eDirect);
            FbxLayerElementArrayTemplateFbxVector4 tangentDirectArray = targetTangents.GetDirectArray();
            tangentDirectArray.SetCount(vertexIndex);
            
            for (int controlIndex = 0; controlIndex < controlPointsCount; controlIndex++)
            {
                List<VertexInfo> vertexInfos = controlIndexToVertexInfos[controlIndex];
            
                FbxVector4 smoothNormal = new FbxVector4();
                foreach (VertexInfo vertexInfo in vertexInfos)
                {
                    smoothNormal += vertexInfo.weight * vertexInfo.normal;
                }
                smoothNormal /= smoothNormal.Length();
            
                foreach (VertexInfo vertexInfo in vertexInfos)
                { 
                    tangentDirectArray.SetAt(vertexInfo.vertexIndex, smoothNormal);
                }
            }
        }
    }

    static FbxVector4[] GetMeshTangents(FbxMesh fbxMesh)
    {
        int polygonCount = fbxMesh.GetPolygonCount();
        void getPosition(int polygonIndex, int indexInPolygon, out float x, out float y, out float z)
        {
            int controlIndex = fbxMesh.GetPolygonVertex(polygonIndex, indexInPolygon);
            FbxVector4 position = fbxMesh.GetControlPointAt(controlIndex);
            x = (float) position.X;
            y = (float) position.Y;
            z = (float) position.Z;
        }
        
        void getNormal(int polygonIndex, int indexInPolygon, out float x, out float y, out float z)
        {
            fbxMesh.GetPolygonVertexNormal(polygonIndex, indexInPolygon, out FbxVector4 normal);
            normal /= normal.Length();
            x = (float) normal.X;
            y = (float) normal.Y;
            z = (float) normal.Z;
        }
        
        List<List<int>> uvIndexsInPolygons = new List<List<int>>();
        FbxLayer layer = fbxMesh.GetLayer(0);
        FbxLayerElementUV uvs = layer.GetUVs();
        FbxLayerElementArrayTemplateFbxVector2 directArray = uvs.GetDirectArray();
        if (uvs.GetReferenceMode() == FbxLayerElement.EReferenceMode.eDirect)
        {
            int uvIndex = 0;
            for (int i = 0; i < polygonCount; i++)
            {
                List<int> uvIndexs = new List<int>();
                for (int j = 0; j < fbxMesh.GetPolygonSize(i); j++)
                {
                    uvIndexs.Add(uvIndex++);
                }
                uvIndexsInPolygons.Add(uvIndexs);
            }
        }
        else
        {
            FbxLayerElementArrayTemplateInt indexArray = uvs.GetIndexArray();
            int uvIndex = 0;
            for (int i = 0; i < polygonCount; i++)
            {
                List<int> uvIndexs = new List<int>();
                for (int j = 0; j < fbxMesh.GetPolygonSize(i); j++)
                {
                    uvIndexs.Add(indexArray.GetAt(uvIndex++));
                }
                uvIndexsInPolygons.Add(uvIndexs);
            }
        }
        
        void getUV(int polygonIndex, int indexInPolygon, out float u, out float v)
        {
            FbxVector2 uv = directArray.GetAt(uvIndexsInPolygons[polygonIndex][indexInPolygon]);
            u = (float) uv.X;
            v = (float) uv.Y;
        }
        FbxVector4[,] polygonTangents = new FbxVector4[polygonCount, 4];

        void setTangent(int polygonIndex, int indexInPolygon, float tangentX, float tangentY, float tangentZ, float sign)
        {
            polygonTangents[polygonIndex, indexInPolygon] = new FbxVector4(tangentX, tangentY, tangentZ, sign);
        }
        
        MikkGenerator.GenerateTangentSpace(polygonCount, fbxMesh.GetPolygonSize, getPosition, getNormal, getUV,
            setTangent);
        
        FbxVector4[] tangents = new FbxVector4[polygonCount * 4];
        int index = 0;
        for (int i = 0; i < polygonCount; i++)
        {
            for (int j = 0; j < fbxMesh.GetPolygonSize(i); j++)
            {
                tangents[index++] = polygonTangents[i, j];
            }
        }

        return tangents;
    }
}

public enum ChannelType
{
    Tangent,
    VertexColor,
    UV2
}

public enum ObjectSpace
{
    TangentSpace,
    ModelSpace
}
public class FbxMeshSmoothToolWindow : EditorWindow
{
    private static readonly Vector2 MIN_SIZE = new Vector2(320, 120);
    private static readonly Vector2 MAX_SIZE = new Vector2(320, 120);
    private static FbxMeshSmoothToolWindow instance;
    
    private Object[] objects;
    private GUIStyle labelStyle;
    public ChannelType type = ChannelType.Tangent;
    public ObjectSpace space = ObjectSpace.TangentSpace;
    
    [MenuItem("Assets/生成描边法线")]
    public static void OnpenWindow()
    {
        var selectedObjects = Selection.GetFiltered(typeof(Object), SelectionMode.Assets);
        if (selectedObjects.Length < 1)
        {
            Debug.Log("未选中任何资源文件");
            return;
        }
        instance = GetWindow<FbxMeshSmoothToolWindow>("生成描边法线", true);
        instance.minSize = MIN_SIZE;
        instance.maxSize = MAX_SIZE;
        
        instance.objects = selectedObjects;
    }

    private void OnGUI()
    {
        labelStyle ??= new GUIStyle(GUI.skin.label) {fontSize = 20, clipping = TextClipping.Overflow};
        EditorGUILayout.Space();
        EditorGUILayout.LabelField($"已选中 {objects.Length} 个资源文件", labelStyle);
        EditorGUILayout.Space();
        type = (ChannelType)EditorGUILayout.EnumPopup(new GUIContent("写入通道", "写入通道选择"), type);
        space = (ObjectSpace)EditorGUILayout.EnumPopup(new GUIContent("写入空间", "写入空间选择"), space);
        EditorGUILayout.Space(20);
        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("确定", GUILayout.Width(100), GUILayout.Height(30)))
        {
            FbxMeshNormalProcessor.FbxModelNormalSmoothTool(objects, type, space);
            Close();
        }
        EditorGUILayout.Space();
        if (GUILayout.Button("取消", GUILayout.Width(100), GUILayout.Height(30)))
        {
            Close();
        }
        EditorGUILayout.EndHorizontal();
    }

    private void OnDisable()
    {
        objects = null;
    }
}