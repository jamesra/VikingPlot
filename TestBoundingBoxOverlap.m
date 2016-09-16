function [ overlap] = TriangleIntersection( VertsOne, VertsTwo, epsilon)

    %I hit some rounding errors using the distanceToPlane test.  Make sure
    %the bounding boxes overlap
    [numVerts, nDims] = size(VertsOne); 
    overlap = true;
    
    for(iDim = 1:nDims)
        min1 = min(VertsOne(:,iDim));
        max1 = max(VertsOne(:,iDim)); 
        
        min2 = min(VertsTwo(:,iDim));
        max2 = max(VertsTwo(:,iDim)); 
       
        if(max1 + epsilon < min2)
            overlap = false; 
            return;
        end
        
        if(max2 + epsilon < min1)
            overlap = false;
            return; 
        end
    end