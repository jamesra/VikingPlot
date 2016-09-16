function [ Bounds ] = BoundingBox( Verts )
%BOUNDINGBOX Returns a mx2 matrix of bounding box information, 
% [minX minY minZ; maxX maxY maxZ]

[numVerts, nDims] = size(Verts);

Bounds = zeros(2, nDims); 

for(iDim = 1:nDims)
    Bounds(1, iDim) = min(Verts(:,iDim));
    Bounds(2, iDim) = max(Verts(:,iDim));
end

