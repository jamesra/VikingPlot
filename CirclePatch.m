function [ verts, normals ] = CirclePatch( numPts, radius, axis )
%CIRCLEPATCH Return a Nx3 matrix defining a set of verticies around a 
%unit circle

    axis = axis ./ norm(axis);
    
    step = (2*pi) / numPts;
    
    verts = zeros(numPts,3); 
    normals = zeros(numPts,3); 

    for(theta = 0:step:(2*pi) - step)
        x = cos(theta) * radius;
        y = sin(theta) * radius; 
        z = 0;         
        verts(int32(theta/step)+1, :) = [x y z];
        
        normals(int32(theta/step)+1, :) = [x y z]; 
    end
    
    [angle, newaxis] = AngleAndAxis([0 0 1], axis);
    
    RotMat = RotationMatrix(angle, newaxis);
    
    TestVector = verts(1,:);
    
    TestVectorRot = TestVector * RotMat; 
    
    [testangle,testaxis] = AngleAndAxis(axis, TestVectorRot);
    
%    disp(['Test Angle: ' num2str(testangle)]); 
    
    if(testangle > .0001 || testangle < .0001)
        angle = pi-angle;
    end
    
    %{
    if(angle > pi / 2)
       %angle =  angle - pi;
       angle = -angle;
    end
    
    
    
    %Figure out polarity of the angle
    c = cross([0 0 1], axis); 
    
%    disp(['Angle: ' num2str(angle)]);
%    disp(num2str(c)); 
%    disp(dot(c, [1 0 0]));
    
    %Rotate the circle onto the axis
    if(c(2) > 0)
       angle = -angle; 
    end
    %}
    
    RotMat = RotationMatrix(angle, newaxis);
    
    verts = verts * RotMat; 
    normals = normals * RotMat;

    return
    
end

