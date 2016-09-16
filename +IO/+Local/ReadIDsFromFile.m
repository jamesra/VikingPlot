function [ IDs ] = ReadIDsFromFile( filename, endpoint )
%READLOCATIONSFROMFILE Read locations from a tab-delimited text file

    IDs = [];
    if ~exist(filename, 'file')
        disp(['Input file does not exist: ' filename]);
        return;
    end
    fileID = fopen(filename);
    
    %Figure out the directory the filename lives in
    [path, ~,~] = fileparts(filename);
 
    data = textscan(fileID, '%[^\n]','MultipleDelimsAsOne',1,'CommentStyle','#');
    ID_strings = data{1};
    num_strings = size(ID_strings,2);
    
    for iStr = 1:length(ID_strings)
        %String could be a number, OData query, or another filename
        line = strtrim(ID_strings{iStr});
        ID = str2num(line);
        if ~isempty(ID)
            IDs = [IDs; ID];
        else
           subfilename = fullfile(path, line);
           if exist(subfilename, 'file')
               sub_IDs = ReadIDsFromFile(subfilename, endpoint);
               
               IDs = vertcat(IDs, sub_IDs);
           elseif ~isempty(endpoint)
               query_IDs = QueryODataIDs(endpoint, line); 
               
               IDs = vertcat(IDs, query_IDs);
           end
        end
                
    end

    fclose(fileID);
end
 