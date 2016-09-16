function [ Verts ] = TranslateVerts( Verts, vector )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

Verts(:, 1) = Verts(:,1) + vector(1); 
Verts(:,2) = Verts(:,2) + vector(2); 
Verts(:,3) = Verts(:,3) + vector(3);

end

