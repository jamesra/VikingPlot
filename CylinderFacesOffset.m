function [ T ] = CylinderFacesOffset( NumPts, AOffset, BOffset, A, B, VertsA, VertsB )
%CYLINDERFACES Given a cylinder defined by two circles
%with NumPts around their perimeters
%Return a Nx3 matric defining faces required to render the cylinder
%with the patch command

    T = zeros(NumPts*2, 3);
    
    %Find two vectors in the plane of both vert sets
    iDest1 = 1;
    iDest2 = round(NumPts/4)+1;
    
    AB = B-A; 
    NAB = AB ./ norm(AB); 
    
    BA = A-B; 
    NBA = BA ./ norm(BA); 
    
    A1 = VertsA(iDest1,:) - A; 
    A2 = VertsA(iDest2,:) - A; 
    B1 = VertsB(iDest1,:) - B; 
    B2 = VertsB(iDest2,:) - B; 
    
    NA1 = A1 ./ norm(A1); 
    NA2 = A2 ./ norm(A2); 
    NB1 = B1 ./ norm(B1);
    NB2 = B2 ./ norm(B2);
    
    AxisA = cross(A1,A2) * 2; 
    AxisB = cross(B1,B2); 
    
    %{
    line([A(:,1) AxisA(:,1) + A(:,1)], ...
         [A(:,2) AxisA(:,2) + A(:,2)], ...
         [A(:,3) AxisA(:,3) + A(:,3)]); 
     
     line([NA1(1)*2 + A(1) A(1)], ...
         [NA1(2)*2 + A(2) A(2)], ...
         [NA1(3)*2 + A(3) A(3)], ...
         'color', [1 0 0]); 
    %}
   
    NAxisA = AxisA ./ norm(AxisB); 
    NAxisB = AxisB ./ norm(AxisB); 
    
    %To figure out if we need to invert the verticies, determine which side
    %of the plane of circleA a vector from A to B lies on. Inverting means     
    %The verticies need to be order clockwise for one circle and counter
    %clockwise on the second.
    
    PlaneAToAB = Angle(NAB,NAxisA);
    PlaneBToBA = Angle(NBA,NAxisB);
    
    Inverted = 0; 
    if(PlaneAToAB < pi/2)
        Inverted = ~Inverted; 
    end
    
    if(PlaneBToBA < pi/2)
        Inverted = ~Inverted; 
    end
    
    %The normals would all be pointing in the same direction if the circles
    %were on a line, so we would expect at least one circle to be inverted,
    %account for that here by inverting the result. 
    Inverted = ~Inverted; 
       
%    disp(['Inverted: ' num2str(Inverted)]); 
    
    %Figure out the rotation needed to render correctly. 
    [axesAngle, AxesAngleAxis] = AngleAndAxis(NAxisB, NAxisA); 
    
%    disp(['axesAngle: ' num2str(axesAngle/pi)]);
%    disp(['Axis: ' num2str(AxesAngleAxis)]); 
   
    %Figure out if positive or negative rotation is required
    %Get matrix to rotate verticies with
    rotmatTemp = RotationMatrix(axesAngle, AxesAngleAxis); 
    AlignedAxisA = NAxisA * rotmatTemp; 
    
    dotAlignedAxes = dot(AlignedAxisA, NAxisB); 
    
%    disp(['Aligned Axes Dot: ' num2str(dotAlignedAxes)]); 
    negativeAxisangle = 0;
    
    if(dotAlignedAxes < 0 && ~Inverted)
        axesAngle = -axesAngle; 
        negativeAxisangle = 1; 
    elseif(dotAlignedAxes > 0 && Inverted)
        axesAngle = -axesAngle; 
        negativeAxisangle = 1; 
    end
    
%    disp(['Negative Axis Angle: ' num2str(negativeAxisangle)]); 
    
%    disp(['Fixed axesAngle: ' num2str(axesAngle/pi)]);
    
%   end

    %Get matrix to rotate verticies with
    rotmat = RotationMatrix(axesAngle, AxesAngleAxis); 
    
    %Put circle A in plane of circle B
    rotVertsA = [VertsA(:,1) - A(1) VertsA(:,2) - A(2) VertsA(:,3) - A(3)];
    rotVertsA = rotVertsA* rotmat;
    
    rotA1 = rotVertsA(iDest1,:); 
%    rotA2 = rotVertsA(iDest2,:); 
    
    rotNA1 = rotA1 ./ norm(rotA1); 
%    rotNA2 = rotA2 ./ norm(rotA2); 
        
    %Find angle between A and B
    rotationangle1 = Angle(rotNA1, NB1);
%    rotationangle2 = Angle(rotNA2, NB2); 
    
%   disp(['Rotation Angle1: ' num2str(rotationangle1 / pi)]);
%   disp(['Rotation Angle2: ' num2str(rotationangle2 / pi)]);
    
    %Figure out if the angle is negative or positive by figuring out which
    %side of the plane the normal is on
    crossRotA1B1 = cross(rotNA1, NB1); 
    
    dotCrossRotA1B1 = dot(crossRotA1B1, NAxisB); 
%    disp(['dotCrossRotA1B1: ' num2str(dotCrossRotA1B1)]);
    
    rotationangle = rotationangle1; 
    
    if(dotCrossRotA1B1 < 0 && ~Inverted)
        rotationangle = -rotationangle1; 
    elseif(dotCrossRotA1B1 > 0 && Inverted)
        rotationangle = -rotationangle1; 
    end
    
%    disp(['Negative Rot Angle: ' num2str(negativeRotangle)]); 
    
%    disp(['Rotation Angle: ' num2str(rotationangle / pi)]);
    
    RotationOffset = round((rotationangle / (2*pi)) * (NumPts));
    
    if(RotationOffset < 0)
        RotationOffset = RotationOffset + NumPts;
    end
   
    for(i = 1:NumPts)
        if(i+RotationOffset > NumPts)
            T(i,1) = [i+RotationOffset+AOffset-NumPts];
            
        else
            T(i,1) = [i+RotationOffset+AOffset];
        end
        
        if(~Inverted)
            T(i,2) = i+BOffset;
            T(i+NumPts,2) = i+BOffset;
        else
            T((NumPts+1) - i, 2) =  i+BOffset;
            T(((NumPts+1) - i) + NumPts,2) = i+BOffset;
        end
        
        if(i+RotationOffset+1 > NumPts)
           T(i+NumPts, 1) = i+1+RotationOffset+AOffset - NumPts;
           T(i,3) = i+1+RotationOffset+AOffset - NumPts;
        else
           T(i+NumPts, 1) = i+RotationOffset+1+AOffset;
           T(i,3) = i+RotationOffset+1+AOffset; 
        end
            
        if(~Inverted)
           if(i+1 > NumPts)
               T(i+NumPts, 3) = i+1+BOffset - NumPts;
           else
               T(i+NumPts, 3) = i+1+BOffset;
           end
        else
            if(i-1 < 1)
                T(((NumPts+1) - i) + NumPts,3) = i-1+BOffset + NumPts;
            else
                T(((NumPts+1) - i) + NumPts,3) = i-1+BOffset;
            end
        end
    end
    
    
    %If the angle between the normal of the first surface and
    %the center of the circle is greater than 90 then flip the 
    %triangles
    FaceBA = VertsB(T(1,2) - BOffset,:) - VertsA(T(1, 1) - AOffset,:);
    FaceCA = VertsA(T(1,3) - AOffset,:) - VertsA(T(1, 1) - AOffset,:);
    
    FaceNormal = cross(FaceBA,FaceCA);
    FaceNormal = FaceNormal ./ norm(FaceNormal); 
    
    FaceNormalAngle = Angle(FaceNormal, VertsA(T(1,1)  - AOffset,:) - A); 
    
    if(FaceNormalAngle < pi/2)
        temp = T(:,2);
        T(:,2) = T(:,3); 
        T(:,3) = temp; 
    end
end

