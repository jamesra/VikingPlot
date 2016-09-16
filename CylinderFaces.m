function [ T ] = CylinderFaces( NumPts, AAxis, BAxis )
%CYLINDERFACES Given a cylinder defined by two circles
%with NumPts around their perimeters
%Return a Nx3 matric defining faces required to render the cylinder
%with the patch command

    T = zeros(NumPts*2, 3);
    
    N1 = AAxis ./ norm(AAxis); 
    N2 = BAxis ./ norm(BAxis); 
    
    angle = atan2(norm(cross(N1,N2)),dot(N1,N2));
    disp(angle); 
    
    for(i = 1:NumPts-1)
        T(i,:) = [i i+NumPts i+1];
        T(i+NumPts,:) = [i+NumPts i+1 i+NumPts+1];
    end
    
    T(NumPts,:) = [NumPts NumPts*2  1]; 
    T(NumPts*2,:) = [NumPts*2 1 NumPts+1];


end

