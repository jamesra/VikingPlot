function [ angle ] = Angle( A, B )
%Angle - returns angle between two verticies

angle = atan2(norm(cross(A,B)),dot(A,B));