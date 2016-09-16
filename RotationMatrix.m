function [ RotMat ] = RotationMatrix( angle, axis)
%RotationMatrix Return a matrix that rotates points around an axis by the specified angle

iX = 1; 
iY = 2; 
iZ = 3;  

P = [axis(iX) * axis(iX) axis(iX) * axis(iY) axis(iX) * axis(iZ); 
     axis(iX) * axis(iY) axis(iY) * axis(iY) axis(iY) * axis(iZ); 
     axis(iX) * axis(iZ) axis(iY) * axis(iZ) axis(iZ) * axis(iZ)]; 
 
I = eye(3); 

Q = [0 -axis(iZ) axis(iY); 
     axis(iZ) 0 -axis(iX); 
     -axis(iY) axis(iX) 0;];
 
RotMat = P + ((I - P) * cos(angle)) + (Q * sin(angle)); 

end