function [ verts,normals,Faces ] = HemispherePatch(  numPts, radius, axis  )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    axis = axis ./ norm(axis);
    RhoStep = (pi/2) / ((numPts/2)+1);
    ThetaStep = (2*pi) / numPts;
    
    numVerts = numPts * (numPts / 2) + 1
    
    verts = zeros(numVerts,3);
    normals = zeros(numVerts,3);

    iVert = 1;
    for(rho = pi/2:-RhoStep:0+RhoStep)
        for(theta = 0:ThetaStep:(2*pi) - ThetaStep)
            x = cos(theta) * sin(rho) * radius;
            y = sin(theta) * sin(rho) * radius; 
            z = cos(rho) * radius;         
            verts(iVert, :) = [x y z];
            normals(iVert, :) = [x y z]; 
            iVert = iVert+1;
        end
    end
    
    verts(iVert,:) = [0 0 radius]; 
    normals(iVert,:) = [0 0 radius]; 
    
    [angle, newaxis] = AngleAndAxis([0 0 1], axis);
    
    RotMat = RotationMatrix(angle, newaxis);
    
    TestVector = verts(1,:);
    
    TestVectorRot = TestVector * RotMat; 
    
    [testangle,testaxis] = AngleAndAxis(axis, TestVectorRot);
    
%    disp(['Test Angle: ' num2str(testangle)]); 
    
     if(testangle > .0001 || testangle < .0001)
         angle = pi-angle;
     end

     RotMat = RotationMatrix(angle, newaxis);
    
     verts = verts * RotMat; 
     normals = normals * RotMat;
     
     %Build faces for the sphere
     %One triangle from each pair to the cap...
     %
     NumFaces = numPts + (numPts * (numPts-1)/2);
     Faces = zeros(NumFaces,3);
     
     %Add the cap
     
     iFace = 1; 
     
     for(iZ = 0:(numPts/2)-1)
        ZOffset = iZ * numPts;
        for(iTheta = 1:numPts)
            NextIndexOnCircle = iTheta + 1;
            if(iTheta + 1 > numPts)
                NextIndexOnCircle = 1; 
            end
            
            Faces(iFace, :) = [iTheta + ZOffset NextIndexOnCircle + ZOffset iTheta + ((iZ+1) * numPts)];
            iFace = iFace + 1; 
            Faces(iFace, :) = [NextIndexOnCircle + ZOffset NextIndexOnCircle + ((iZ+1) * numPts) iTheta + ((iZ+1) * numPts)];
            iFace = iFace + 1; 
        end
     end
     
     iCap = length(verts);
     ZOffset = (numPts/2) * numPts; 
     for(i = 1:numPts)
         if(i+1 > numPts)
            Faces(iFace,:) = [i+ZOffset 1+ZOffset iCap]; 
         else
            Faces(iFace,:) = [i+ZOffset i+1+ZOffset iCap]; 
         end
         
         iFace = iFace + 1; 
     end
     
%       patch('Faces', Faces, ...
%              'Vertices', verts, ...
%              'FaceVertexCData', [0 0 0], ...
%              'VertexNormals', normals, ...
%              'FaceColor', [1 0 0]); 
%       set(gca, 'DataAspectRatio', [1 1 1]); 
end

