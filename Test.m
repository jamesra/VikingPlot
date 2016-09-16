hFig = figure('Renderer', 'zbuffer');
hAxes = axes;
lightangle(0,90);

numPts = 4; 

Center = [ 0 0 0]; 

Circle = CirclePatch(numPts,1, [0 0 1]); 

Verts = [Center; 
         Circle];
     
T = ones(numPts,3);

for(i = 1:numPts-1)
   T(i,:) = [1 i+1 i+2];
end

T(numPts,:) = [1 numPts+1 2];


A = [0 1 0];
B = [5 0 0]; 
C = [5 5 0];
D = [0 5 0];
E = [0 2.5 0];
F = [-5 2.5 0]; 
G = [-5 7.5 0];
H = [7.5 7.5 0];
I = [7.5 0 0];

J = [7.5 0 5];
K = [12.5 0 5]; 
L = [12.5 0 -5];
M = [5 0 -5];
N = [5 0 -7.5];
O = [15 0 -7.5]; 
P = [15 0 7.5];
Q = [-7.5 0 7.5];
R = [-7.5 0 5];

S = [-7.5 5 5]; 
T = [-7.5 5 -2.5];
U = [-7.5 -2.5 -2.5];
V = [-7.5 -2.5 -7.5 ];
W = [-7.5 7.5 -7.5]; 
X = [-7.5 7.5 10];
Y = [-7.5 -7.5 10];
Z =[-7.5 -7.5 0];

AA = [-12.5 -7.5 -5];
AB = [-15 -7.5 -5];
AC = [-20 -7.5 0];

AD = [-25 -7.5 0];

AE = [-20 -2.5 0]; 


Verts = [A; B; C; D; E; F; G; H; I; ...
         J; K; L; M; N; O; P; Q; R;
         S; T; U; V; W; X; Y; Z;
         AA; AB; AC; AD; AE]; 

%Verts = [B;C;D;E;]; 

%{
Verts =  [0 0 0; 
         0 0 5;
         5 0 5;
         10 0 10;
         5 0 10]; 
%}

%Verts = [Y; Z; AA; AB; AC];
%Verts = [D; E; F; G;]; 
%{
     
RotMat = RotationMatrix(pi/3, [0 0 1]);
Verts = Verts * RotMat; 
  %}

NumVerts = length(Verts); 

%patch('Faces',T,'Vertices',Verts,'FaceVertexCData',...
%			color,'FaceColor','flat'); 

%Calculate the axis of the rotation (Heading)
[angleAC, axisAC] = AngleAndAxis(A-B,C-B);
[angleBD, axisBD] = AngleAndAxis(B-C,D-C);

angles = zeros(length(Verts), 1); 
ReportedAxis = zeros(length(Verts), 3); 
CalculatedAxis = zeros(length(Verts), 3); 
RotMats = cell(length(Verts), 1); 
CircleVerts = zeros(length(Verts) * numPts, 3); 
CircleNormals = zeros(length(Verts) * numPts, 3); 
Faces = []; 

for(i = 2:NumVerts-1)
    
    disp(['i: ' num2str(i)]); 
    
    CalculatedAxis(i,:) = Verts(i-1,:) - Verts(i,:);
    
    [VertsTemp,NormalsTemp] = CirclePatch(numPts, 1, CalculatedAxis(i,:));
    
    VectorA = Verts(i-1,:) - Verts(i,:);
    VectorC = Verts(i+1,:) - Verts(i,:);
    
    [angles(i) ReportedAxis(i,:)] = AngleAndAxis(VectorA, VectorC);
    
    if(angles(i) < pi)
        angles(i) = pi - angles(i);
    end

    RotMat = [];
    if(mod(angles(i),pi) < .0001 && mod(angles(i), pi) > -.0001)
        RotMat = eye(3);
    else
        rotAngle = angles(i) /2;
%        rotAngle = angles(i);
%        rotAngle = 0;
        RotMat = RotationMatrix(rotAngle, ReportedAxis(i,:) );
    end
    
    RotMats{i} = RotMat; 
    
    %Rotate
    VertsTemp = VertsTemp * RotMat; 
    NormalsTemp = NormalsTemp * RotMat; 
    
    %Translate
    VertsTemp = TranslateVerts(VertsTemp, Verts(i,:)); 
     
    CircleVerts((i-1)*(numPts)+1:((i)*numPts), :) = VertsTemp;
    CircleNormals((i-1)*(numPts)+1:((i)*numPts), :) = NormalsTemp;
    
end

CalculatedAxisAB = Verts(1,:) - Verts(2,:);
[VertsTemp, NormalsTemp] = CirclePatch(numPts, 1, CalculatedAxisAB);
CircleVerts(1:numPts,:) = TranslateVerts(VertsTemp, Verts(1,:)); 
CircleNormals(1:numPts,:) = NormalsTemp; 

CalculatedAxisHI =  Verts(NumVerts-1,:) - Verts(NumVerts,:);
[VertsTemp, NormalsTemp] = CirclePatch(numPts, 1, CalculatedAxisHI);
CircleVerts((numPts*(NumVerts-1))+1:(numPts*NumVerts),:) = TranslateVerts(VertsTemp, Verts(NumVerts,:));
CircleNormals((numPts*(NumVerts-1))+1:(numPts*NumVerts),:) = NormalsTemp;
disp(['==================================']); 

for(i = 1:NumVerts-1)
    
    VA = CircleVerts(((i-1)*numPts)+1:(i*numPts),:); 
    VB = CircleVerts(((i)*numPts)+1:((i+1)*numPts),:); 
    
    disp(['i: ' num2str(i)]); 
   
    if(isempty(Faces))
        Faces = CylinderFacesOffset(numPts, (i-1)*numPts, i*numPts, Verts(i,:), Verts(i+1,:), VA, VB);
    else
        Faces = cat(1, Faces, CylinderFacesOffset(numPts, (i-1)*numPts, i*numPts, Verts(i,:), Verts(i+1,:), VA, VB));
    end
end

color = [1 .25 0];

p = patch('Faces',Faces,...
      'Vertices',CircleVerts,...
...%      'VertexNormals', CircleNormals, ...
      'FaceVertexCData', color, ...
      'EdgeColor', [.5 .5 .5], ...
      'FaceColor', color, ...
             'FaceLighting', 'flat',...
             'AmbientStrength',.3, ...
             'DiffuseStrength',.8,...
             'SpecularStrength',.9, ...
             'SpecularExponent',15,...
             'BackFaceLighting','lit');  
        
set(get(hAxes,'XLabel'), 'Color', [0.5 0.5 0.5], ...
               'String', 'X (nm)');
set(get(hAxes,'YLabel'), 'Color', [0.5 0.5 0.5], ...
               'String', 'Y (nm)');
set(get(hAxes,'ZLabel'), 'Color', [0.5 0.5 0.5], ...
               'String', 'IPL Depth (nm)'); 
           
set(hAxes, 'DataAspectRatio', [1 1 1]); 

disp(get(p, 'VertexNormals'));