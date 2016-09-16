function [ Origin ] = TwoPlaneLineOrigin( DLine, NOne, NTwo, dOne, dTwo )
%TWOPLANELINEORIGIN Summary of this function goes here
%   Detailed explanation goes here
    
    [val, iMax] = max(abs(DLine)); 
    Origin = [0 0 0]; 
    
    iX = 1; 
    iY = 2; 
    iZ = 3; 
    
    switch(iMax)
        case 1
            Origin(iY) = (dTwo * NOne(iZ) - dOne * NTwo(iZ)) / DLine(iX);
            Origin(iZ) = (dOne * NTwo(iY) - dTwo * NOne(iY)) / DLine(iX);
        case 2
            Origin(iX) = (dOne * NTwo(iZ) - dTwo * NOne(iZ)) / DLine(iY);
            Origin(iZ) = (dTwo * NOne(iX) - dOne * NTwo(iX)) / DLine(iY);
        case 3
            Origin(iX) = (dTwo * NOne(iY) - dOne * NTwo(iY)) / DLine(iZ);
            Origin(iY) = (dOne * NTwo(iX) - dTwo * NOne(iX)) / DLine(iZ);
    end

    return
    

end

