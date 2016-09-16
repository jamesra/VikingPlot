function [ UniqueFaces ] = UniqueFaces( Faces )
%UniqueFaces Return only one instance of each face in the input

    if(isempty(Faces))
        UniqueFaces = [];
        return;
    end
    temp = sort(Faces,2); 
    [~,ix] = sort(temp(:,1),1);
    
    tempSorted = temp(ix,:);
    
    [numFaces, dim] = size(tempSorted);
    
    iFaces = logical(ones(numFaces,1));
    
    for(iFace = 1:numFaces)
        
        if(iFaces(iFace) == false)
            continue; %No need to check again if it is already a duplicate
        end
        
        for(iNextFace = iFace+1:numFaces)
            if(iNextFace > numFaces) %This changes size in the loop so check it again.
                break; 
            end
                
            if(sum(ismember(tempSorted(iFace,:), tempSorted(iNextFace,:))) == dim)
               iFaces(iNextFace) = 0; 
            end
            
            if(tempSorted(iNextFace, 1) ~= tempSorted(iFace,1))
                break; 
            end
        end
    end

    UniqueFaces = Faces(ix(iFaces), :);
end

