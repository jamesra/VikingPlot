function [ ChildIDs ] = FetchODataChildStructures( endpoint, cellIDs, recurse  )
%FETCHODATACHILDSTRUCTURES Return a list of the IDs of all child structures
%of cellIDs, including the passed IDs

    if isempty(cellIDs)
       ChildIDs = [];
       return
    end

    options = ODataWebOptions();
    numIDs = length(cellIDs);
    child_data = cell(1,numIDs);

    parfor i = 1:numIDs
        cellID = cellIDs(i);
        query_url = [endpoint '/Structures(' num2str(cellID) ')/Children?$select=ID&$expand=Children($select=ID)' ];
        child_data{i} = webread(query_url, options);
    end

    totalChildren = 0;
    ChildrenWithGrandchildren = [];
    totalGrandchildren = 0;
    for i = 1:numIDs
       
       child_struct = child_data{i}.value;
       num_children = length(child_struct);
       totalChildren = totalChildren + num_children; 
       
       if num_children > 0
        totalGrandchildren = totalGrandchildren + length(vertcat(child_struct.Children));
        
        for iChild = 1:num_children
               if ~isempty(child_struct(iChild).Children)
                   ChildrenWithGrandchildren = horzcat(ChildrenWithGrandchildren, child_struct(iChild).ID);
               end
        end
       end
    end

    NewIDs = zeros(totalChildren, 1);
         
    iInsert = 1;
    for i = 1:numIDs
        child_structures = child_data{i}.value;
        child_count = length(child_structures);
        if child_count > 0
            NewIDs(iInsert:iInsert+child_count-1, 1) = vertcat(child_structures.ID);
            iInsert = iInsert + child_count;
        end
    end
    
    if recurse
        recurse_IDs = IO.OData.FetchODataChildStructures(endpoint, ChildrenWithGrandchildren, recurse);
        ChildIDs = vertcat(NewIDs, recurse_IDs);
    else
        ChildIDs = NewIDs;
    end
    
    ChildIDs = unique(ChildIDs);
    
    if size(ChildIDs, 2) > 1
        ChildIDs = ChildIDs';
    end
    
    

end

