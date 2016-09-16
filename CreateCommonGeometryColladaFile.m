function CreateCommonGeometryColladaFile(Path, FileName)
%CREATECOMMONGEOMETRYCOLLADAFILE Summary of this function goes here
%   Detailed explanation goes here

    if(~isempty(Path))
       if(Path(end) ~= filesep)
        Path = [Path filesep];
       end
    end

    TargetPath = [Path FileName];
            
    DOM = CreateColladaFile();
    
    WriteColladaGeometry(DOM, 'sphere', [], ...
                                        StructureObj.UnitSphere.Verts, ...
                                        StructureObj.UnitSphere.Faces, ...
                                        StructureObj.UnitSphere.Normals);
                                    
    xmlwrite(TargetPath, DOM);
end

