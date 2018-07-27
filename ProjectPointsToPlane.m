function [ V2D ] = ProjectPointsToPlane( Normal, V )
%PROJECTPOINTSTOPLANE Given a normal and a matrix of nx3 points, 
%   project the points to the 2D plane

%Find the largest component of the Normal.  This is the axis we will ignore
[~, iMax] = max(Normal);
iV = [1 2 3] ~= iMax;

V2D = V(:,iV); 

end

