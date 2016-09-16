dbstop if error

Test1XZ = [   0 0 -.5;
            -1 0 .5;
            1 0 .5;]
        
Test1XY = [0 -.5 0;
              -1 .5 0;
              1 .5 0;];
          
Test2XZ = [1 0 -1;
              -1 0 1;
              3 0 1];

Test2XY  = [0 -1 1;
              -2 1 0;
              2 1 0;];
          
Test3XZ = [1 0 -1;
              -1 0 1;
              3 0 1];

Test3XY  = [0 -1 0;
              -1 1 0;
              1 1 0;];          
          
Test3XZ = [0 0 -1;
              -1 0 1;
              1 0 1];
          
Test4XY  = [0 -1 0;
              -1 1 0;
              1 1 0;];          
          
Test4XZ = [0 0 -1;
              -2.5 0 1;
              2.5 0 1];  
          
Test5XY  = [0 -1 0;
              -2.5 1 0;
              2.5 1 0;];          
          
Test5XZ = [0 0 -1;
              -1 0 1;
              1 0 1];      
          
Test6XY  = [1 -1 0;
              -1 1 0;
              2 1 0;];          
          
Test6XZ = [0 0 -1;
              -1 0 1;
              1 0 1]; 
          
Test7XY = [0 -1 0;
            -2 1  0;
            1 1 0];
            
Test7XZ = [0 -1 0;
            2 -1  1;
            1 1 0];
            
Test7YZ = [2 0 0;
               -.5 0 -1;
               -.5 0 1;];
           
Test8XY = [0 1 0;
            -1 -1  0;
            1 -1 0];
            
Test8XZ = [1 -1 0;
            0 1  0;
            0 1 1];
            
Test8YZ = [2 0 2;
               -2 0 -.5;
               2 0 -.5;];
           
Test9XZ = [0 0 1;
              1 0  0;
              -1 0 0];
            
Test9XY = [0 1 0;
              1 0 0;
              -1 0 0;];
          
Test10XY = [1.0000   -1.0000         0;
            2.0000   -1.0000    1.0000;
            1.0000    1.0000         0;];
        
Test10XZ = [-0.5000         0    1.0000;
             0.5000         0         0;
             2.0000         0         0];

Test11XY = [0.0000   -1.0000         0;
            2.0000   -1.0000    1.0000;
            1.0000    1.0000         0;];
        
Test11XY2 = [0.0000   -1.0000       .5;
            2.0000   -1.0000    1.50000;
            1.0000    1.0000         .5;];        
        
Test11XZ = [-0.5000         0    2.0000;
             0.5000         0         -1;
             3.0000         0         -1];
         
Test12XY = [-1.0000   1.0000     0;
            1.0000   1.0000         0;
            0.0000    -1.0000         0;];
        
Test12XY2 = [-1.0000   -1.0000    .5;
            1.0000   -1.0000         .5;
            0    1.0000         .5;];        
        
Test12XZ = [0         0    2.0000;
             -2         0         -1;
             2         0         -1]
         
 Test12XZ2 = [0         -.5    2.0000;
              -2         -.5         -1;
              2      -.5         -1];         

Test13XY = [-1   0     0;
            1   0     0;
            0   1    0;];
                
Test13XZ = [0         0       2.0000;
            2         0         -1;
            -2    0         -1];
            
Test14XY = [-1   1     1.5;
            0   0     0;
            1   1     1.5;];
                
Test14XZ = [0         1         1;
            0         1         -1;
            0         -1        1];
              
Test15XY = [-1  1     1.5;
            0   0     0;
            1   1     1.5;];
                
Test15XZ = [0         .5         1;
            0         1         -1;
            0         -1        1];
             
Test16XY = [0   0     1.5;
            -1   0     0;
            1   0     0;];
                
Test16XZ = [0         0         .75;
            0         1        0;
            0         -1        0];
             
Test17XY = [0   .1     .75;
            -1   0     0;
            1   0     0;];
                
Test17XZ = [-0.1         0         0;
            0         1        .75;
            0         -1       .75];             
               
Test18XY = [0   0     -1;
            1   0     0;
            -1   0     0;];
                
Test18XZ = [0         1         0;
            0         0         -.25;
            0        -1       -.25];             
     
Test19XY = [0   0     -1;
            1   0     0;
            0   0     -.5;];
                
Test19XZ = [1         -.5         -.5;
            1         1         -.5;
            0         -1        0];   
              
Test20XY = [-1   0     0;
            1   0     0;
            0   1    0;];
                
Test20XZ = [0         0       1.0000;
            1         0         -1;
            -1        0         -1];
            
Test21XY = [-1   0     0;
            1   0     0;
            0   1    0;];
                
Test21XZ = [0         0       3.0000;
            1         0          -1;
            -1        0           -1];
            
Test22XY = [-1   0     0;
             1   0     0;
             0   1    0;];
                
Test22XZ = [0         1       0;
            0         0       0;
            0         0           -1]; 
               
Test23XY = [-1   0     0;
            1   0     0;
            0   1    0;];
                
Test23XZ = [0         1       0;
            0         .25       .1;
            0    .25           -1]; 
               

Test24XY = [0   0.5   0;
            -1 0    0;
            1   0    0;];
                
Test24XZ = [0        0       0.5;
            0        0       -0.5;
            0        -0.5    0]; 

Test25XY = [0    0    0;
            -1   0.5     0;
            1    0.5     0;];
                
Test25XZ = [0         0       0.5;
            0         0       -0.5;
            0         -.5       0]; 
                
Test26XY = [0.5   0    .5;
            0   -0.5     0;
            0   0.5     0;];
                
Test26XZ = [-0.5        0       0.5;
             0         .5       0;
             0        -.5       0]; 
                
Test27XY = [0    -.5       0;
            0    -1        0;
            1    -.75      0;];
                
Test27XZ = [0          0       -0.5;
            0         -0.5        0;
            0          0       0.5];         
                
Test28XY = [0        1        0.5;
            0         0        0.5;
            0         0        -0.5;];
                
Test28XZ = [1        0       1;
            1        0       0;
            -1       0       0];  
                
Test29XY = [0        1        0.5;
            0        0        0.5;
            0        0        -0.5;];
                
Test29XZ = [1        0       1;
            1        0       0;
            -1       0       0];  
        
Test30XY = [0        1        0;
            -1       0        0;
            1        0        0;];
                
Test30XZ = [0        -1       .1;
            -.5      0       0;
            1.5      0       0];
        
Test31XY = [0        1        0;
            -1       0        0;
            0        0        0;];
                
Test31XZ = [0        0       0;
            0      -1       0;
            1      0       0]; 

cla; 
        
vars = who;

tris = regexpi(vars, 'test\d+', 'match');

maxNumber = 0; 
VertTank = [];

for(i = 1:length(tris))
   if(isempty(tris{i}))
       continue; 
   end
   
   iMatchStart = tris{i}; 
   Varname = vars{i};
   
   Number = regexpi(Varname, '\d+', 'match');
   Number = str2num(Number{1});
   if(Number > maxNumber)
       maxNumber = Number; 
   end
   
   verts = eval(Varname); 
   [numVerts, numDims] = size(verts); 
   
   NumberMatrix = ones(numVerts, 1) .* Number;
   
   verts = cat(2, NumberMatrix, verts);
   
   VertTank = [VertTank;
              verts];
end

%Figure out the dimensions we should use
dims = nthroot(maxNumber, 3);

dims = ceil(dims);

xdims = dims; 
ydims = dims; 
zdims = dims; 

if(xdims * ydims * zdims > NumberMatrix / 2)
   xdims = xdims - 1;  
end

if(xdims * ydims * zdims > NumberMatrix / 2)
   ydims = ydims - 1;  
end

Spacing = 5; 
StartCoord = -(dims * 2.5);

%Adjust the position of the test triangles
map = zeros(maxNumber,3); 
iVert = 1; 
for(iZ = 1:zdims)
    z = StartCoord + (iZ * Spacing);
    for(iY = 1:ydims)
        y = StartCoord + (iY * Spacing);
        for(iX = 1:xdims)
            x = StartCoord + (iX * Spacing);
            
            map(iVert,:) = [x y z];
            
            text(map(iVert,1)+2.5,map(iVert,2),map(iVert,3), ...
                 num2str(iVert), ...
                 'Color', [0 0 1], ...
                 'FontSize', 12, ...
                 'FontWeight', 'bold');
            
            iVert = iVert + 1; 
        end
    end 
end



[numVerts] = size(VertTank, 1);
TriVerts = zeros(numVerts, 3); 

for(iVert = 1:numVerts)
   TriVerts(iVert, :) = VertTank(iVert, 2:end) + map(VertTank(iVert,1),:);
end

TestNumberRange = [1:maxNumber];
%TestNumberRange = [30 24 31 28 29];
%TestNumberRange = [12]; 
%TestNumberRange = [30]; 
iDisplay = ismember(VertTank(:,1), TestNumberRange);

TriVerts(~iDisplay,:) = [];


%          
% TriVerts =  [Test1XZ; 
%              Test1XY; 
%              Test2XZ; 
%              Test2XY;
%              Test3XY;
%              Test3XZ;
%              Test4XY;
%              Test4XZ;
%              Test5XY;
%              Test5XZ;
%              Test6XY;
%              Test6XZ;
%              Test7XY;
%              Test7XZ;
%              Test7YZ;
%              Test8XZ;
%              Test8XY;
%              Test8YZ;
%              Test9XZ;
%              Test9XY;
%              Test10XY;
%              Test10XZ;
%              Test11XY;
%              Test11XY2;
%              Test11XZ;
%              Test12XY2;
%              Test12XY;
%              Test12XZ;
%              Test12XZ2;
%              Test13XY;
%              Test13XZ;
%              Test14XZ;
%              Test14XY;
%              Test15XZ;
%              Test15XY;
%              Test16XY;
%              Test16XZ;
%              Test17XY;
%              Test17XZ;
%              Test18XY;
%              Test18XZ;
%              Test19XY;
%              Test19XZ;
%              Test20XY;
%              Test20XZ;
%              Test21XY;
%              Test21XZ;
%              Test22XY;
%              Test22XZ;
%              Test23XY;
%              Test23XZ;
%              Test24XY;
%              Test24XZ;
%              Test25XY;
%              Test25XZ;
%              Test26XY;
%              Test26XZ;
%              Test27XY;
%              Test27XZ;
%              Test28XY;
%              Test28XZ];
%           

%    TriVerts = [
%              Test1XZ;
%              Test1XY;
%              Test2XZ; 
%              Test2XY;];     
%       
%      TriVerts = [
%                Test5XY; 
%                Test5XZ;];

%    TriVerts = [
%              Test6XZ; 
%              Test6XY;];

%   TriVerts = [ Test7XY;
%               Test7XZ;
%               Test7YZ;];
% % % 
%   TriVerts = [ Test8XZ;
%                Test8XY;
%                Test8YZ;];

% TriVerts = [ Test7XY;
%              Test7XZ;
%              Test7YZ;
%              Test8XY;
%              Test8YZ;
%              Test8XZ;];

% 
% TriVerts = [Test10XY;
% %             Test10XZ;]

% TriVerts = [Test11XY;
%             Test11XZ;
%             Test11XY2;];

% 
% TriVerts = [ Test12XY2;
%               Test12XY;
%               Test12XZ;
%               Test12XZ2;];
% 
% TriVerts = [Test13XY;
%             Test13XZ;];

%  TriVerts = [Test4teenXZ;
%              Test4teenXY;];

%  TriVerts = [TestFifteenXY;
% %              TestFifteenXZ;];
% 
%    TriVerts = [Test6teenXY;
%                Test6teenXZ;];

%   TriVerts = [Test8eenXY;
%               Test8eenXZ;];

%     TriVerts = [Test19XZ;
%                 Test19XY;];

%    TriVerts = [Test22XY;
%                Test22XZ;
%                Test23XZ;
%                Test23XY;];
% 
%      TriVerts = [Test24XY;
%                  Test24XZ;
%                  Test25XZ;
%                  Test25XY;];

%       TriVerts = [Test26XY;
%                   Test26XZ;];

%       TriVerts = [Test27XY;
%                   Test27XZ;];

%        TriVerts = [Test28XY;
%                    Test28XZ;];

     
TriFaces = 1:(numel(TriVerts)/3);
TriFaces = reshape(TriFaces',3,[])';

%Remove the points of every triangle
VertsToRemove = []; 
%VertsToRemove = [3:3:numel(TriVerts)/3];% 3:3:numel(TriVerts)/3];
%VertsToRemove = [1:3:numel(TriVerts)/3];
%VertsToRemove = []; 

%Prepare quiver plot
hFig = gcf;
set(gcf, 'Renderer', 'opengl');
axes = gca; 
set(gca, 'DataAspectRatio', [1 1 1]);
set(gca, 'Color', [0.5 0.5 0.5]);


%Figure out the normals
OriginalTriRep = TriRep(TriFaces, TriVerts);
OriginalNormals = OriginalTriRep.faceNormals();
OriginalTriCenters = OriginalTriRep.incenters(); 

OriginalNormals = OriginalNormals ./ 2; 

[NewVerts, NewFaces] = StitchFaces(TriVerts, TriFaces, VertsToRemove);

cla;

hold on; 

for(iVert = 1:maxNumber)
    text(map(iVert,1)+2.5,map(iVert,2),map(iVert,3), ...
                 num2str(iVert), ...
                 'Color', [0 0 1], ...
                 'FontSize', 12, ...
                 'FontWeight', 'bold');
end

scale = 0;
% quiver3(OriginalTriCenters(:,1), OriginalTriCenters(:,2), OriginalTriCenters(:,3), ...
%         OriginalNormals(:,1), OriginalNormals(:,2), OriginalNormals(:,3), scale, ...
%         'Color', [1 1 0], 'Linestyle', '-', 'LineWidth', 2); 
%      
StitchedTriRep = TriRep(NewFaces, NewVerts);
StitchedNormals = StitchedTriRep.faceNormals();
StitchedTriCenters = StitchedTriRep.incenters(); 

StitchedNormals = StitchedNormals ./ 3; 

patch('Faces', NewFaces, ...
             'Vertices', NewVerts, ...
             'FaceVertexCData', [1 0 0], ...
             ...%'VertexNormals', obj.Normals, ...
             'FaceColor', [1 0 0], ...
             'EdgeColor', [0 0 1], ...
             'FaceAlpha', [0.5], ...
             'FaceLighting', 'phong',...
             'AmbientStrength', .2, ...
             'DiffuseStrength', .8,...
             'SpecularStrength', .02, ...
             'SpecularExponent', 15,...
             'BackFaceLighting', 'lit');
         
% quiver3(StitchedTriCenters(:,1), StitchedTriCenters(:,2), StitchedTriCenters(:,3), ...
%         StitchedNormals(:,1), StitchedNormals(:,2), StitchedNormals(:,3), scale, ...
%         'Color', [0 1 0], 'LineWidth', 2); 
    
for(iVert = 1:size(NewVerts,1))
     text(NewVerts(iVert,1)+0.01,NewVerts(iVert,2)+0.01,NewVerts(iVert,3)+0.01, ...
             num2str(iVert), ...
             'Color', [1 1 1], ...
             'FontSize', 8);
 end
    
    
%close(hFig); 