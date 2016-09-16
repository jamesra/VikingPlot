function [ ChildIDs ] = FetchODataChildStructures( endpoint, cellIDs, recurse  )
%FETCHODATACHILDSTRUCTURES Return a list of the IDs of all child structures
%of cellIDs, including the passed IDs

    if isempty(cellIDs)
       ChildIDs = [];
       return
    end

    options = ODataWebOptions();
    numIDs = size(cellIDs,2);
    child_data = cell(1,numIDs);

    parfor i = 1:numIDs
        cellID = cellIDs(i);
        query_url = [endpoint '/Structures(' num2str(cellID) ')/Children?$select=ID' ];
        child_data{i} = webread(query_url, options);
    end

    numChildren = 0;
    for i = 1:numIDs
       numChildren = numChildren + length(child_data{i}.value); 
    end

    NewIDs = zeros(1,numChildren);

    iInsert = 1;
    for i = 1:numIDs
        child_count = length(child_data{i}.value);
        if child_count > 0
            NewIDs(1, iInsert:iInsert+child_count-1) = horzcat(child_data{i}.value.ID);
            iInsert = iInsert + child_count;
        end 
    end

    if recurse
        recurse_IDs = FetchODataChildStructures(endpoint, NewIDs, recurse);
        ChildIDs = [NewIDs recurse_IDs];
    else
        ChildIDs = NewIDs;
    end
    
    if size(ChildIDs, 2) > 1
        ChildIDs = ChildIDs';
    end

end

