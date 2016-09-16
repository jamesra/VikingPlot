function [ angle, axis ] = AngleAndAxis( V1, V2 )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if(V1 == V2)
    angle = 0; 
    axis = [0 0 1]; 
    return;
end

N1 = V1 ./ norm(V1); 
N2 = V2 ./ norm(V2); 

%Supposedly more precise than acos(dot(N1,N2)) near multiples of PI
angle = atan2(norm(cross(N1,N2)),dot(N1,N2));

%Special case, if angle is zero we need to rotate circle to be
%perpendicular from line along two vectors
modAngle = mod(angle,pi); 
if(modAngle < .0001 && modAngle > -.0001)
    angle = 0; 
    axis = V2 - V1;
else


    axis = cross(N1,N2); 

    if(norm(axis) == [0 0 0])
        axis = [0 0 1];
    end
end

axis = axis ./ norm(axis); 

end

