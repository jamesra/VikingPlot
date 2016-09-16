function [ Structs, Locs, LocLinks ] = FetchOData(endpoint, cellIDs, includeChildren)
%FetchData - Collect data from a database

    if includeChildren
       childIDs = FetchODataChildStructures(endpoint, cellIDs,1);
       cellIDs = [cellIDs; childIDs];
    end
    
    cellIDs = unique(cellIDs);

    options = ODataWebOptions();
              
    numIDs = length(cellIDs);
    numLocColumns = 12;
    numLocLinkColumns = 2;
    
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
        
        numNewLocRows = size(location_data.value,1);
        iLocRow = 1;
        Locs = zeros(numNewLocRows, numLocColumns);
        
        Locs(iLocRow:end, 1) = vertcat(location_data.value.ID);
        Locs(iLocRow:end, 2) = vertcat(location_data.value.ParentID);
        Locs(iLocRow:end, 3) = vertcat(location_data.value.VolumeX);
        Locs(iLocRow:end, 4) = vertcat(location_data.value.VolumeY);
        Locs(iLocRow:end, 5) = vertcat(location_data.value.Z);
        Locs(iLocRow:end, 6) = vertcat(location_data.value.Radius);
        Locs(iLocRow:end, 7) = vertcat(location_data.value.X);
        Locs(iLocRow:end, 8) = vertcat(location_data.value.Y);
        
        Locs_out{i} = Locs; 
        
        location_link_data = webread(location_link_url, options);
        
        if iscell(location_link_data.value) || isempty(location_link_data.value)
            continue;
        end
        
        numNewLocLinkRows = size(location_link_data.value, 1);
        iLocLinkRow = 1;
        LocLinks = zeros(numNewLocLinkRows, numLocLinkColumns);
        
        LocLinks(iLocLinkRow:end, 1) = vertcat(location_link_data.value.A);
        LocLinks(iLocLinkRow:end, 2) = vertcat(location_link_data.value.B);
        
        LocLinks_out{i} = LocLinks;
    end   
    
    disp('Downloading complete.  Organizing annotation data.');
    
    Structs = cell(numIDs, 5);
    Locs = [];
    LocLinks = [];
    for i = 1:numIDs
        
        web_struct = WebStructs{i};
        Structs{i,1} = web_struct.ID;
        Structs{i, 2} = web_struct.ParentID;
        Structs{i, 3} = web_struct.TypeID;
        Structs{i, 4} = web_struct.Label;
        Structs{i, 5} = web_struct.LastModified;
        
        if isempty(Locs)
            Locs = Locs_out{i};
        else
            Locs = [Locs; Locs_out{i}];
        end
        
        if isempty(LocLinks)
            LocLinks = LocLinks_out{i};
        else
            LocLinks = [LocLinks; LocLinks_out{i}]; 
        end
    end
end

