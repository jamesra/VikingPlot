function [ outStruct ] = SpherePatch(  numPts, radius, varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    FlipZ = false; 
    optargin = size(varargin,2);
    if(optargin == 0)
        axis = [0 0 1];
        hemisphere = False; 
    elseif(optargin == 1)
        axis = varargin{1}; 
        hemisphere = false; 
    elseif(optargin == 2)
        axis = varargin{1};
        hemisphere = varargin{2};
    elseif(optargin == 3)
        FlipZ = varargin{3}; 
        axis = varargin{1};
        hemisphere = varargin{2};
    end
    
    numVerts = (numPts * numPts) + 2;
    RhoStep = (pi) / (numPts+2);
    RhoRange = pi;
       
    if(hemisphere)
        RhoStep = (pi/2) / ((numPts/2)+1);
        RhoRange = pi/2 + RhoStep;
        numVerts = numPts * (numPts / 2) + 1;
    end
    
    axis = axis ./ norm(axis);
   
    ThetaStep = (2*pi) / numPts;
       
    verts = zeros(numVerts,3);
    normals = zeros(numVerts,3);

    iVert = 1;
    for(rho = RhoRange-RhoStep:-RhoStep:0+RhoStep) %Leave the tips of the sphere as single points
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
    iVert = iVert+1; 
    
    if(~hemisphere)
        verts(iVert,:) = [0 0 -radius]; 
        normals(iVert,:) = [0 0 -radius]; 
        iVert = iVert+1; 
    end
    
    if(FlipZ)
        verts(:, 3) = -verts(:, 3); 
        normals(:, 3) = -normals(:, 3); 
    end
    
    %We never bother rotating spheres
    if(hemisphere)
        %CreateRotationMatrix(world_up=[0 0 1], out=axis, up=[1? 0 0])
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
    end
     
     %Build faces for the sphere
     %One triangle from each pair to the cap...
     %
     NumFaces = numPts + (numPts * (numPts-1)/2);
     Faces = zeros(NumFaces,3);
     
     %Add the cap
     
     iFace = 1; 
     
     
     
     if(hemisphere)
         for(iZ = 0:(numPts/2)-1)
            ZOffset = iZ * numPts;
            for(iTheta = 1:numPts)
                NextIndexOnCircle = iTheta + 1;
                if(iTheta + 1 > numPts)
                    NextIndexOnCircle = 1; 
                end

                Faces(iFace, :) = [iTheta + ZOffset iTheta + ((iZ+1)) * numPts NextIndexOnCircle + ZOffset ];
                iFace = iFace + 1; 
                Faces(iFace, :) = [NextIndexOnCircle + ZOffset iTheta + ((iZ+1) * numPts) NextIndexOnCircle + ((iZ+1) * numPts) ];
                iFace = iFace + 1; 
            end
         end
     
         iCap = length(verts);
         ZOffset = (numPts/2) * numPts; 
         for(i = 1:numPts)
             if(i+1 > numPts)
                Faces(iFace,:) = [i+ZOffset iCap 1+ZOffset ]; 
             else
                Faces(iFace,:) = [i+ZOffset iCap i+1+ZOffset ]; 
             end

             iFace = iFace + 1; 
         end
         
               
         if(FlipZ)
            temp = Faces(:,1);
            Faces(:,1) = Faces(:,3);
            Faces(:,3) = temp;
         end
     else
         for(iZ = 0:(numPts)-1)
            ZOffset = iZ * numPts;
            for(iTheta = 1:numPts)
                NextIndexOnCircle = iTheta + 1;
                if(iTheta + 1 > numPts)
                    NextIndexOnCircle = 1; 
                end

                Faces(iFace, :) = [iTheta + ZOffset iTheta + ((iZ+1) * numPts) NextIndexOnCircle + ZOffset ];
                iFace = iFace + 1; 
                Faces(iFace, :) = [NextIndexOnCircle + ZOffset iTheta + ((iZ+1) * numPts) NextIndexOnCircle + ((iZ+1) * numPts) ];
                iFace = iFace + 1; 
            end
         end
         
         iCap = length(verts)-1;
         ZOffset = (numPts) * numPts; 
         for(i = 1:numPts)
             if(i+1 > numPts)
                Faces(iFace,:) = [ i+ZOffset  iCap 1+ZOffset ]; 
             else
                Faces(iFace,:) = [ i+ZOffset iCap  i+1+ZOffset  ]; 
             end

             iFace = iFace + 1; 
         end
         
         iCap = length(verts);
         ZOffset = 0; 
         for(i = 1:numPts)
             if(i+1 > numPts)
                Faces(iFace,:) = [i+ZOffset  1+ZOffset iCap]; 
             else
                Faces(iFace,:) = [i+ZOffset  i+1+ZOffset iCap]; 
             end

             iFace = iFace + 1; 
         end
         
         
%            temp = Faces(:,1);
%            Faces(:,1) = Faces(:,3);
%            Faces(:,3) = temp;
     end
     
     
     
     outStruct = struct('Verts', verts, ...
                     'Normals', normals, ...
                     'Faces', Faces); 
     
%       patch('Faces', Faces, ...
%              'Vertices', verts, ...
%              'FaceVertexCData', [0 0 0], ...
%              'VertexNormals', normals, ...
%              'FaceColor', [1 0 0]); 
%       set(gca, 'DataAspectRatio', [1 1 1]); 
end

