
function PPlot2(Structs, Locs, LocLinks, scale_struct, VolumeName, varargin)
    
   dbstop if error
   
   if isempty(Structs)
      disp('Cannot render, no structures found') 
      return
   end
   
   if isempty(Locs)
      disp('Cannot render, no locations found') 
      return
   end
   
    SaveFrames = 0; 
    HideChildren = 0; 
    RenderMode = 1; 
    ObjPath = []; 
    ColladaPath = []; 
    WindowSize = [0 0 1024 768]; 
    ShowLabels = true; 
    ShowChildLabels = false; 
    IsDebug = false;
    NumThreads = 0;
    DefaultAlpha = 1;
    ChildScalar = 1;
    InvertZ = 0;
    
    optargin = size(varargin,2);
    stdargin = nargin - optargin;
    
    MaterialsManager = MaterialManager(); 
    
    %Parse the optional arguments
    for(i = 1:2:optargin)
       if(strcmpi(varargin{i},'SaveFrames') )
          SaveFrames = logical(varargin{i+1}); 
       elseif(strcmpi(varargin{i},'Debug'))
           IsDebug = logical(varargin{i+1});
       elseif(strcmpi(varargin{i},'HideChildren') )
          HideChildren = logical(varargin{i+1}); 
       elseif(strcmpi(varargin{i},'HideLabels'))
          ShowLabels = ~logical(varargin{i+1});
       elseif(strcmpi(varargin{i},'ShowChildLabels'))
          ShowChildLabels = logical(varargin{i+1});
       elseif(strcmpi(varargin{i},'Threads'))
           NumThreads = int(varargin{i+1}); 
       elseif(strcmpi(varargin{i},'RenderMode') )
          RenderMode = int32(varargin{i+1}); 
       elseif(strcmpi(varargin{i},'ObjPath') )
          ObjPath = varargin{i+1}; 
       elseif(strcmpi(varargin{i},'ColladaPath') )
          ColladaPath = varargin{i+1}; 
       elseif(strcmpi(varargin{i},'DefaultAlpha') )
          DefaultAlpha = varargin{i+1}; 
       elseif(strcmpi(varargin{i},'ScaleChildren') )
          ChildScalar = varargin{i+1}; 
       elseif(strcmpi(varargin{i},'InvertZ') )
          InvertZ = varargin{i+1}; 
       elseif(strcmpi(varargin{i},'WindowSize'))
          WindowSizeCells = textscan(varargin{i+1}, '%d,%d');
          if(length(WindowSizeCells) ~= 2)
             disp(['Bad window size specified, expected two numbers seperated by a comma']); 
             return;
          end
          
          WindowSize(3) = WindowSizeCells{1}; 
          WindowSize(4) = WindowSizeCells{2}; 
          
       else
          disp(['Unknown argument to pplot2: ' varargin(i)]); 
          return;
       end    
    end 
    
    if DefaultAlpha < 1.0
       RenderMode = 2;
    end
%      
%     if(~IsDebug)
%         nExistingPool = ~isempty(gcp('nocreate'));
%         if(nExistingPool > 0)
%             if(nExistingPool ~= NumThreads)
%                 delete(gcp('nocreate'));
%             end
%         end
%         
%         if(NumThreads == 0)
%             parpool;
%         elseif(NumThreads > 1)
%             parpool(NumThreads);  
%         end
%     else
%         if(isempty(gcp('nocreate')))
%             delete(gcp('nocreate'));
%         end
%     end

    if(SaveFrames && RenderMode ~= 1) %Use software renderer when saving frames to avoid bugs
       RenderMode = 1;
       disp('Forcing software renderer because SaveFrames specified'); 
    end

    disp('Rendering...'); 

    renderer = 'zbuffer';
    if(RenderMode == 2)
        renderer = 'opengl';
        g = opengl('data');
        disp(['  ' g.Vendor]);
        disp(['  ' g.Version]);
        disp(['  ' g.Renderer]);
        disp(['  Max Texture Size: ' num2str(g.MaxTextureSize)]);
        disp(['  ' g.Visual]);
        disp(['  ' num2str(g.Software)]);
    else
        disp('   Matlab ZBuffer software renderer with Phong lighting'); 
    end
    
    %SectionExcludeList = [8 22 56 60 66 72 81 108 179]; 
    SectionExcludeList = [];
    
    ValidZ = unique(Locs.Z); 

    %CircleVerts = CirclePatch(numCirclePts, 1, [0 0 1]); 
    %Faces = CylinderFaces(numCirclePts);
    if(length(LocLinks.A) == 1)
        %An edge case when we have no links
        numLinks = 0;
    else
        numLinks = size(LocLinks.A,1);
    end

    if(length(Locs.ID) == 1)
        %An edge case for no locations
        return; 
    end

    numLocs = size(Locs.ID,1);
    
    numStructs = length(Structs);
    
    scale_struct = ConvertScaleUnits(scale_struct, 'um');
%     
%     scale_struct.X.Value = .001; 
%     scale_struct.Y.Value = .001; 
%     scale_struct.Z.Value = .045; 
    
    
    if InvertZ
        scale_struct.Z.Value = scale_struct.Z.Value * -1;
    end
  
    %Scale the coordinates, keeps a copy of the original data
    Locs = ScaleLocations(Locs, scale_struct);
     
    for(iStruct = 1:numStructs)
        structure = Structs{iStruct};
        structure.Locations = ScaleLocations(structure.Locations, scale_struct);
        Structs{iStruct} = structure;
    end

    StructureTypeColors = IO.Local.ReadColorsFile('StructureTypeColors.txt', DefaultAlpha);
    
    if isempty(StructureTypeColors)
        StructureTypeColors = [35 1 0 .2 1;  %Postsynapse
                               34 0 0 1 1;   %Conventional Presynapse
                               28 1 1 0 1;   %Gap junction
                               73 0 1 0 1;   %Ribbon
                               85 1 1 1 1];  %Desmosome
    end
    
    StructureColors = IO.Local.ReadColorsFile('StructureColors.txt', DefaultAlpha);
    if isempty(StructureColors)
        StructureColors = [0 0 0 0 1];
    end

    %There is an optional file which points to a set of images at different
    %Z values.  Use that to map coordinates to colors.
    ImageColorMapFullPath = fullfile(VolumeName, 'ImageColorMaps.txt');
    %Create an ImageMapping object
    ImageColorMapObj = ImageColorMap(ImageColorMapFullPath); 

    %Figure out how many Loc objects we need to create
    StructureIDs = unique(Locs.ParentID);

    MapLocIDToIndex = java.util.Hashtable(numLocs);

    for(iLoc = 1:numLocs)
        LocID = Locs.ID(iLoc);

        MapLocIDToIndex.put(LocID, iLoc);
    end 

    %MapIDToObj = cell(max(StructureIDs),1);
    MapIDToObj = StructureManager(numStructs);
    indexToObjList = zeros(length(StructureIDs),1);
    NextObjIndex = 1;
    
    disp('Creating structure maps...');
    
    MapStructIDToIndex = java.util.Properties;
    for(iStruct = 1:numStructs)
        StructID = Structs{iStruct}.ID; 
        MapStructIDToIndex.put(StructID, iStruct); 
    end

    disp('Creating structures...'); 

    for(iStruct = 1:length(Structs))
        MaterialName = 'White'; 
        structure = Structs{iStruct};
        PID = structure.ID; 
                
        TypeID = structure.TypeID; 
        
        color = [];
        alpha = DefaultAlpha;
        
        iStructureColor = find(StructureColors(:,1) == PID,1); 
        if ~isempty(iStructureColor)
            %Structure color overrides the more broad type color
            disp(['    Mapping locations for structure ' num2str(PID)]);
            color = StructureColors(iStructureColor,2:4); 
            alpha = StructureColors(iStructureColor,5);
        else
            %Find out if the structure type has a mapped color
            iTypeColor = find(StructureTypeColors(:,1) == TypeID);
            if(~isempty(iTypeColor))
                %We skip items defined in the structuretypecolor table if the
                %render only cells flag is passed
                if(HideChildren)
                    continue;
                end

                data = StructureTypeColors(iTypeColor, 2:end);  
                color = data(1:3);
                alpha = data(4);

                MaterialName = ['Type', num2str(TypeID)];
                MaterialsManager.UpdateMaterial(MaterialName, data); 
            else
                %Create a color for this structure via image mapping
                disp(['    Creating color for structure from Images for structure ' num2str(PID)]);
                %If no color is mapped then create one from image map if
                %available                

                if(~isempty(ImageColorMapObj))
                   [ZColorMatches, iColorMatch] = intersect(structure.Locations.UnscaledZ, ImageColorMapObj.Sections);
                   if(~isempty(iColorMatch)) 
                        color = ImageColorMapObj.GetColor(structure.Locations.SectionX(iColorMatch), ...
                                                         structure.Locations.SectionY(iColorMatch), ...
                                                         structure.Locations.UnscaledZ(iColorMatch), ...
                                                         structure.Locations.UnscaledRadius(iColorMatch));
                   end
                end

                %if we didn't find a color then create one
                if(isempty(color))
                    %color = rand(3,1); 
                    color = [.5 .5 .5];
                end

                StructureColors(end+1, :) = [PID color DefaultAlpha];
                [iStructureColor, numCols] = size(StructureColors);

                if(min(color == [1 1 1]) == 0)
                    MaterialName = ['Structure', num2str(PID)];
                end

                MaterialsManager.UpdateMaterial(MaterialName, [color alpha]); 
                
                disp(['    Mapping locations for structure ' num2str(PID)]);
            end
        end

        %The structure object doesn't use anything after the type index, so
        %save some memory by not passing the rest
        obj = StructureObj(structure, color, alpha, MaterialName); 
        MapIDToObj.put(PID, obj);
        indexToObjList(NextObjIndex) = PID;
        NextObjIndex = NextObjIndex + 1;
    end
     
    disp('    Linking Locations...'); 

    %Clean up any empty entries in the indexToObjList if we are hiding
    %children
    iUnusedObjs = indexToObjList == 0;
    indexToObjList(iUnusedObjs) = [];
    
    for(iLink = 1:numLinks)
       AID = LocLinks.A(iLink);
       BID = LocLinks.B(iLink);

       iLocA = MapLocIDToIndex.get(AID);
       if(isempty(iLocA))
          continue; 
       end

       iLocB = MapLocIDToIndex.get(BID);
       if(isempty(iLocB))
           continue; 
       end 

       PID = Locs.ParentID(iLocA); 
       structure_obj = MapIDToObj.get(PID);

       if(isempty(structure_obj))
           continue;
       end

       Ax = Locs.X(iLocA);
       Ay = Locs.Y(iLocA);
       Az = Locs.UnscaledZ(iLocA);
       Bz = Locs.UnscaledZ(iLocB);

       Z = [Az, Bz];
       section_distance = abs(Az - Bz);

       if(section_distance > 2)
          SkippedRange = min(Az,Bz)+1:max(Az,Bz)-1; 

          %Remove sections which don't exist
          SkippedRange = intersect(SkippedRange, ValidZ); 

          %Remove sections which are known to be bad
          BadJumps = setdiff(SkippedRange, SectionExcludeList) ;

          if(~isempty(BadJumps))
            disp(['Warning, Structure ' num2str(PID) ': big jump between location IDs: ' num2str(iLocA) ', ' num2str(iLocB) ' Z: ' num2str(Az) ' -> ' num2str(Bz)] );
            disp(['X: ' num2str(Locs.UnscaledX(iLocA),'%1.0f') ' Y: ' num2str(Locs.UnscaledY(iLocA),'%1.0f') ' Z: ' num2str(Az)]); 
          end
       end

       AValid = 1; 
       BValid = 1; 

       %Find out if the link occurs over bad sections
       [I, iZValid, ~] = intersect(Z,SectionExcludeList);
       if(~isempty(I))
           if(find(iZValid == 1))
               AValid = 0; 
           end

           if(find(iZValid == 2))
               BValid = 0;
           end

          %Add this to the broken link list to see if we can connect it
          %later
          %BrokenLinks{iLocA} = [BrokenLinks{iLocA} iLocB];
       end

        if(Az < Bz)
            structure_obj = structure_obj.AddLink(BID,AID, BValid, AValid);
        else
            structure_obj = structure_obj.AddLink(AID,BID, AValid, BValid);
        end

       MapIDToObj.put(PID,structure_obj);

    end
        
    disp('    Building structure hierarchy'); 
    
    %Add child structures to thier parents
    for iStruct = 1:size(Structs,1)
       StructID = Structs{iStruct}.ID;
       struct = MapIDToObj.get(StructID);
       if isempty(struct)
           continue;
       end
         
       if struct.HasParent
           ParentObj = MapIDToObj.get(struct.ParentID);
           if ~isempty(ParentObj)
                ParentObj = ParentObj.AddChildStructure(struct); 
                MapIDToObj.put(ParentObj.StructureID, ParentObj);
           end 
       end
    end
    
    disp('Building cell array for multithreading...'); 
    ValidStructureObjs = MapIDToObj.toCellArray(); 
        
    disp('Jumping bad sections...'); 
    parfor iStruct = 1:length(ValidStructureObjs)
           %disp(['iStruct' num2str(iStruct)]);
           structure_obj = ValidStructureObjs{iStruct};

           %disp(structure_obj);
           if(isempty(structure_obj) == false)
                 structure_obj = structure_obj.EndAddLinks(); 
                 structure_obj = structure_obj.CullVeryLongLinks();
    %             structure_obj = structure_obj.JumpBadLinks(); 
                 ValidStructureObjs{iStruct} = structure_obj;
           end
    end
    

    disp('Culling overlapping locations...'); 
    parfor iStruct = 1:length(ValidStructureObjs)
       structure_obj = ValidStructureObjs{iStruct};

       if(isempty(structure_obj) == false)
             structure_obj = structure_obj.CullOverlappingLocations(); 
             ValidStructureObjs{iStruct} = structure_obj;
       end
    end

        disp('Translate Models to local coordinates');
        parfor iStruct = 1:length(ValidStructureObjs)
           structure_obj = ValidStructureObjs{iStruct};

           if(isempty(structure_obj) == false)
              structure_obj = structure_obj.CenterModel();
              ValidStructureObjs{iStruct} = structure_obj; 
           end
        end


        disp('Creating Meshes...');
        parfor iStruct = 1:length(ValidStructureObjs)
           structure_obj = ValidStructureObjs{iStruct};

           if(isempty(structure_obj) == false)
              structure_obj = structure_obj.UpdateMesh();
              ValidStructureObjs{iStruct} = structure_obj;            
           end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Remove all empty structures, in this case cells without
        %annotations 
        for iStruct = 1:length(ValidStructureObjs)
           structure_obj = ValidStructureObjs{iStruct}; 
           if(isempty(structure_obj.Verts))
            disp(['Structure ' num2str(structure_obj.StructureID) ' has no annotations']);
            MapIDToObj.remove(structure_obj.StructureID);
            ValidStructureObjs{iStruct} = [];
           end
        end
           
        ValidStructureObjs = ValidStructureObjs(~cellfun('isempty',ValidStructureObjs));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        disp('Cleaning Meshes...');
        parfor iStruct = 1:length(ValidStructureObjs)
           structure_obj = ValidStructureObjs{iStruct};

           if(isempty(structure_obj) == false)
              structure_obj = structure_obj.CleanMesh();
              ValidStructureObjs{iStruct} = structure_obj; 
           end
        end
        
        if ChildScalar ~= 1.0
           disp('Scaling child objects...');
           parfor iStruct = 1:length(ValidStructureObjs)
               structure_obj = ValidStructureObjs{iStruct};
               
               if ~isnan(structure_obj.ParentID)
                   structure_obj = structure_obj.ScaleModel(ChildScalar);
               end
               
               ValidStructureObjs{iStruct} = structure_obj; 
           end 
        end

        disp('Calculate bounding boxes...');
        parfor iStruct = 1:length(ValidStructureObjs)
          structure_obj = ValidStructureObjs{iStruct};
          
          
           if(isempty(structure_obj) == false)
              structure_obj = structure_obj.CalculateBoundingBox();
              ValidStructureObjs{iStruct} = structure_obj;

              %Update our boundaries
           end
        end

        disp('Fixing Normals...');
        parfor iStruct = 1:length(ValidStructureObjs)
           structure_obj = ValidStructureObjs{iStruct};

           if(isempty(structure_obj) == false)
              structure_obj = structure_obj.UpdateNormals();
              ValidStructureObjs{iStruct} = structure_obj; 
           end
        end
        
        ValidStructureObjs = gather(ValidStructureObjs);
        Structs = gather(Structs); 
    
    disp('Merging parallel computations into central hash table...'); 
    for iStruct = 1:length(ValidStructureObjs)
        structure_obj = ValidStructureObjs{iStruct};
        if(~isempty(structure_obj))
            MapIDToObj.put(structure_obj.StructureID, structure_obj);
        end
    end

    if(~isempty(ColladaPath))
        disp('Creating Collada files...');

        if(~exist(ColladaPath,'dir'))
           mkdir(ColladaPath); 
        end
        
        if(ColladaPath(end) ~= filesep)
            ColladaPath = [ColladaPath filesep];
        end
           
        MaterialFileName = 'Materials.dae';
        CommonGeometryFileName = 'CommonGeometry.dae';
        ScenePath = [ColladaPath 'Scene.dae'];
        MaterialPath = [ColladaPath MaterialFileName]; 
        
        disp('    Creating Collada material file...'); 
        MaterialsManager.CreateColladaMaterialFile(ColladaPath, MaterialFileName); 
        %MaterialsManager.AppendColladaMaterials(DOM);
        
        disp('    Creating Collada common geometry file...'); 
        CreateCommonGeometryColladaFile(ColladaPath, CommonGeometryFileName); 

        %Write verticies
        disp('    Writing Collada geometry files...');
        for iPID = 1:length(StructureIDs)
            PID = StructureIDs(iPID);
            structure_obj = MapIDToObj.get(PID);
            
            if(isempty(structure_obj) == false)
              %Only create dae files for top level structures
              if(~structure_obj.HasParent)
                disp(['    Creating ' num2str(structure_obj.StructureID)]); 
                TargetPath = [ColladaPath num2str(structure_obj.StructureID) '.dae'];
            
                [GeometryDOM, ParentNode] = structure_obj.CreateColladaGeometryFile(TargetPath, MaterialFileName);
                
                for(iChild = structure_obj.ChildList)
                    ChildObj = MapIDToObj.get(iChild);
                    if(~isempty(ChildObj)) %Children with no annotations may have been removed
                        [GeometryDOM, ParentNode, Node] = ChildObj.UpdateColladaFile(GeometryDOM, ParentNode, structure_obj.ModelTranslation, MaterialFileName);
                    end
                end
                
                xmlwrite(TargetPath, GeometryDOM); 
              end
              %MapIDToObj{PID} = structure_obj.UpdateColladaFile(DOM);
            end
        end
        
        disp('    Writing Collada scene file...');
        
        SceneBox = [];
        for iPID = 1:length(StructureIDs)
           PID = StructureIDs(iPID);
           structure_obj = MapIDToObj.get(PID);

           if(isempty(structure_obj) == false)
                if(isempty(SceneBox))
                      SceneBox = structure_obj.WorldBoundingBox; 
                else
                      SceneBox = AddBoundingBoxes([SceneBox; structure_obj.WorldBoundingBox]); 
                end
           end
        end
            
        SceneDOM = CreateColladaFile();
        
        SceneCenter = [((SceneBox(2,1) - SceneBox(1,1)) / 2) + SceneBox(1,1) ...
                       ((SceneBox(2,2) - SceneBox(1,2)) / 2) + SceneBox(1,2) ...
                       ((SceneBox(2,3) - SceneBox(1,3)) / 2) + SceneBox(1,3)];
                   
        for iPID = 1:length(StructureIDs)
            PID = StructureIDs(iPID);
            structure_obj = MapIDToObj.get(PID);
            if(isempty(structure_obj) == false)
                if(~structure_obj.HasParent)
                    structure_obj.UpdateColladaSceneFile(SceneDOM, SceneCenter );
                end
            end
        end
        
        xmlwrite(ScenePath, SceneDOM); 
    end

    if(~isempty(ObjPath))
        disp('Creating object files...');

        if(~exist(ObjPath,'dir'))
           mkdir(ObjPath); 
        end

        disp('    Writing Materials...');
        MaterialFileName = 'Master.mtl'; 
        MaterialsManager.CreateMaterialFile(ObjPath, MaterialFileName); 

        TargetPath = [ObjPath filesep 'Output.obj'];
        hFile = fopen(TargetPath,'w');

        fprintf(hFile, ['mtllib ' MaterialFileName '\n']);

        %Write verticies
        disp('    Writing Verticies...');
        Offset = 0; 
        for iPID = 1:length(StructureIDs)
            PID = StructureIDs(iPID);
            structure_obj = MapIDToObj.get(PID);

            if(isempty(structure_obj) == false)
              MapIDToObj{PID}.ObjVertexOffset = Offset;
              Offset = Offset + structure_obj.WriteVerts(hFile);
%             MapIDToObj{PID} = structure_obj.WriteObjFile(ObjPath, MaterialFileName);
            end
        end

        %Write normals
        disp('    Writing Normals...');
        for iPID = 1:length(StructureIDs)
            PID = StructureIDs(iPID);
            structure_obj = MapIDToObj.get(PID);

            if(isempty(structure_obj) == false)
              structure_obj.WriteNormals(hFile);
%             MapIDToObj{PID} = structure_obj.WriteObjFile(ObjPath, MaterialFileName);
            end
        end

        %Write Faces
        disp('    Writing Faces...');
        for iPID = 1:length(StructureIDs)
            PID = StructureIDs(iPID);
            structure_obj = MapIDToObj.get(PID);

            if(isempty(structure_obj) == false)
              Offset = structure_obj.ObjVertexOffset; 
              structure_obj.WriteFaces(hFile, Offset); 
            end
        end

        fclose(hFile); 
        
    end

    %Don't create figure window if we are not rendering output
    if(RenderMode == 0)
        return; 
    end

    disp('Creating figure...'); 
    [hFig, hAxes] = CreateRenderingFigure();
    
% 
%     hFig = figure('Units', 'Pixels', ...
%         'OuterPosition', WindowSize, ...
%         'Renderer', renderer, ...
%         'Color', [0 0 0]);
% 
%     hAxes =  axes('color', [0 0 0], ...
%                   'FontWeight', 'bold', ...
%                   'XColor', [.5 .5 .5], ...
%                   'YColor', [.5 .5 .5], ... 
%                   'ZColor', [.5 .5 .5], ...
%                   'Position', [0 0 1 1], ...
%                   'DataAspectRatio', [1 1 1]);    

    hold on; 

    lightangle(45,30);
    lightangle(225,30);

    disp('Rendering structures...'); 
    SceneBox = [];
    for iPID = 1:length(StructureIDs)
       PID = StructureIDs(iPID);
       structure_obj = MapIDToObj.get(PID);

       if(isempty(structure_obj) == false)
           
            if(isempty(SceneBox))
                  SceneBox = structure_obj.WorldBoundingBox; 
            else
                  SceneBox = AddBoundingBoxes([SceneBox; structure_obj.WorldBoundingBox]); 
            end

            UseOpenGL = RenderMode == 2;
            structure_obj.Draw(UseOpenGL);

            if(ShowLabels)
               if(structure_obj.TypeID == 1)
                   structure_obj.RenderLabelText();
               elseif(ShowChildLabels)
                   structure_obj.RenderLabelText();
               end
            end

       end
    end

    %Set the size of the axes display
    minX = SceneBox(1,1);
    maxX = SceneBox(2,1);
    minY = SceneBox(1,2);
    maxY = SceneBox(2,2);
    minZ = SceneBox(1,3);
    maxZ = SceneBox(2,3);
     
    disp('Volume dimensions:');
    disp(['X ' num2str([minX maxX])]);
    disp(['Y ' num2str([minX maxX])]);
    disp(['Z ' num2str([minX maxX])]);

    set(hAxes, 'XLim', [minX maxX]); 
    set(hAxes, 'YLim', [minY maxY]); 
    set(hAxes, 'ZLim', [minZ maxZ]); 

%    set(hAxes, 'DataAspectRatio', [1 1 1]); 
%     
%     set(get(gca,'XLabel'), 'Color', [0.5 0.5 0.5], ...
%                            'String', 'X');
%     set(get(gca,'YLabel'), 'Color', [0.5 0.5 0.5], ...
%                            'String', 'Y');
%     set(get(gca,'ZLabel'), 'Color', [0.5 0.5 0.5], ...
%                            'String', 'IPL Depth (nm)'); 
    set(gca, 'YTick', []); 
    camroll(180);
    
%    title('Laminae of Inner Nuclear Layer Cells'); 
%     

    if(SaveFrames == 0)
        return; 
    end

    ModCircleCapture( hFig, hAxes );

    %FlyThroughCapture(hFig, hAxes);

    %Shutdown the matlab pool 
    if(~IsDebug)
        matlabpool close;
    end
end