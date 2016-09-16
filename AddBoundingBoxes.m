function [ BoundingBox ] = AddBoundingBoxes( Boxes )
%ADDBOUNDINGBOXES Given a matrix of concatenated bounding boxes, add them together
%Boxes = 
% [MinX1 MinY1 MinZ1; 
% MaxX1 MaxY1 MaxZ1;
% MinX2 MinY2 MinZ2; 
% MaxX2 MaxY2 MaxZ2;
% MinX3 MinY3 MinZ3; 
% MaxX3 MaxY3 MaxZ3;]

[nRows, nDim] = size(Boxes); 
iMins = 1:2:nRows;
iMaxs = 2:2:nRows;

if(nRows < 4)
    BoundingBox = Boxes; 
    return;
end

BoundingBox = zeros(2,nDim); 

BoundingBox(1,:) = min(Boxes(iMins, :)); 
BoundingBox(2,:) = max(Boxes(iMaxs, :)); 

end

