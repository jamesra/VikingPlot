function [Structs, Locs, LocLinks] = FetchOData(endpoint, cellIDs, includeChildren)
%FetchData - Collect data from a database

    if includeChildren
       childIDs = IO.OData.FetchODataChildStructures(endpoint, cellIDs,1);
       cellIDs = [cellIDs; childIDs];
    end
    
    cellIDs = unique(cellIDs);

    options = ODataWebOptions();
              
    numIDs = length(cellIDs);
    
    WebStructs = cell(numIDs, 1);
    Locs_out = cell(numIDs, 1);
    LocLinks_out = cell(numIDs, 1);
    
    disp(['Downloading ' num2str(length(cellIDs)) ' structure(s)']);

    parfor i = 1:numIDs
        ID = cellIDs(i);
        structure_url = [endpoint '/' 'Structures(' num2str(ID) ')/'];
        
        structure_data = webread(structure_url, options);
        
        WebStructs{i} = structure_data;
    end
    
    disp('Downloading locations for structures...');
        
    parfor i = 1:numIDs
        ID = cellIDs(i);
        location_url = [endpoint '/Locations/?$filter=ParentID eq ' num2str(ID) '&$select=ID,ParentID,VolumeX,VolumeY,Z,Radius,X,Y'];
        structure_url = [endpoint '/' 'Structures(' num2str(ID) ')/'];
        location_link_url = [structure_url 'LocationLinks/?$select=A,B'];
        location_data = webread(location_url, options);
        
        if iscell(location_data.value) || isempty(location_data.value)
            continue;
        end
                
        Locs_out{i} = vertcat(location_data.value); 
        
        location_link_data = webread(location_link_url, options);
        
        if iscell(location_link_data.value) || isempty(location_link_data.value)
            continue;
        end
        
        LocLinks_out{i} = location_link_data.value;
    end   
    
    disp('Downloading complete.  Organizing annotation data.');
    
    Structs = cell(numIDs, 1);
    Locs = struct('ID', [], ...
                  'ParentID', [], ...
                  'X', [], ...
                  'Y', [], ...
                  'Z',       [], ...
                  'Radius',  [], ...
                  'SectionX',       [], ...
                  'SectionY',       []);
    
    LocLinks = struct('A', [], ...
                      'B', []);
    
    for i = 1:numIDs
        
        web_struct = WebStructs{i};
        
        output = IO.OData.CreateStructureForODataResult(web_struct, Locs_out{i}, LocLinks_out{i});
        Structs{i} = output;
        Locs.ID = vertcat(Locs.ID, output.Locations.ID);
        Locs.ParentID = vertcat(Locs.ParentID, output.Locations.ParentID);
        Locs.X = vertcat(Locs.X, output.Locations.X);
        Locs.Y = vertcat(Locs.Y, output.Locations.Y);
        Locs.Z = vertcat(Locs.Z, output.Locations.Z);
        Locs.Radius = vertcat(Locs.Radius, output.Locations.Radius);
        Locs.SectionX = vertcat(Locs.SectionX, output.Locations.SectionX);
        Locs.SectionY = vertcat(Locs.SectionY, output.Locations.SectionY);
        
        LocLinks.A = vertcat(LocLinks.A, output.LocationLinks.A);
        LocLinks.B = vertcat(LocLinks.B, output.LocationLinks.B);
    end
end

