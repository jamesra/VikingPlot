%Test2 expects two variables to be present, Verts and Links
function Test3(Verts, Links)

    dbstop if error
    
    nmPerPixel = 1;%StructureObj.nmPerPixel; 
    nmPerSection = 1;%StructureObj.nmPerSection;

    iID = 1;
    iParentID = 2; 
    iX = 3;
    iY = 4;
    iZ = 5;
    iRadius = 6;   
    iType = 7;
    iSectionX = 8; %These are the coords in section space, used to map color
    iSectionY = 9; 

    numPts = 6; 

    T = ones(numPts,3);

    for(i = 1:numPts-1)
       T(i,:) = [1 i+1 i+2];
    end

    T(numPts,:) = [1 numPts+1 2];

    %Put verts in a form that the structure object can understand
    %[ID ParentID X Y Z Radius TypeID SectionX SectionY]
    Radius = 1; 
    numVerts = size(Verts,1);
    Locs = zeros(numVerts, 9);
    for iVert = 1:numVerts 
       Locs(iVert,:) = [iVert 1 Verts(iVert,:) Radius 1 0 0];
    end

    %Verts = [B;C;D;E;]; 

    structObj = StructureObj(Locs,[1 0 0], 'StructObj', 1);

    numLinks = size(Links, 1);
    for iLink = 1:numLinks
       structObj = structObj.AddLink(Links(iLink,1), Links(iLink,2), true, true);  
    end

    structObj = structObj.EndAddLinks(); 

    structObj = structObj.CullOverlappingLocations(); 

    structObj = structObj.UpdateMesh();
    
    %structObj = structObj.CleanMesh(); 

    structObj = structObj.UpdateNormals();
    
    structObj.WriteColladaFile(''); 
    

    hFig = figure('Units', 'Pixels', ...
            'OuterPosition', [0 0 1024 768], ...
            'Renderer', 'OpenGL', ...
            'Color', [0 0 0]);

    hAxes =  axes('color', [0 0 0], ...
                  'FontWeight', 'bold', ...
                  'XColor', [.5 .5 .5], ...
                  'YColor', [.5 .5 .5], ... 
                  'ZColor', [.5 .5 .5], ...
                  'Position', [0 0 1 1]); 
              
              
    lightangle(0,-45);

    hold on; 
    
    structObj.Draw(false);
    
    structObj.DrawNormals(false, [0 1 0]);
   % structObj.DrawNormals(true, [1 0 1]);

    set(get(hAxes,'XLabel'), 'Color', [0.75 0.75 0.75], ...
                   'String', 'X (nm)');
    set(get(hAxes,'YLabel'), 'Color', [0.75 0.75 0.75], ...
                   'String', 'Y (nm)');
    set(get(hAxes,'ZLabel'), 'Color', [0.75 0.75 0.75], ...
                   'String', 'Z IPL Depth (nm)'); 
               
    hCameras = findall(gca, 'Type', 'light'); 
            
    CamPositions = get(hCameras, 'Position');
    scale = 20; 
    scatter3(CamPositions(:,1), CamPositions(:,2), CamPositions(:,3), scale, 'yellow', 'filled');

    %Set the size of the axes display
    minX = min([Locs(:,iX); CamPositions(:,1)]) * nmPerPixel;
    maxX = max([Locs(:,iX); CamPositions(:,1)]) * nmPerPixel;
    minY = min([Locs(:,iY); CamPositions(:,2)]) * nmPerPixel;
    maxY = max([Locs(:,iY); CamPositions(:,2)]) * nmPerPixel;
    minZ = min([Locs(:,iZ); CamPositions(:,3)]) * nmPerSection;
    maxZ = max([Locs(:,iZ); CamPositions(:,3)]) * nmPerSection;
    maxRadius = max(Locs(:,iRadius)) * nmPerPixel * 3;

    set(hAxes, 'XLim', [minX-maxRadius maxX+maxRadius]); 
    set(hAxes, 'YLim', [minY-maxRadius maxY+maxRadius]); 
    
    zlim = [minZ maxZ]; 
    
    set(hAxes, 'ZLim', [min(zlim)-maxRadius max(zlim)+maxRadius]); 

    set(hAxes, 'DataAspectRatio', [1 1 1]); 
end
%disp(get(p, 'VertexNormals'));