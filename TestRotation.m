axis = [0 0 1];

points = [0 0 0;
          1 0 0;
          0 1 0;
          0 0 1;
          -1 0 0;
          0 -1 0;
          0 0 -1];

disp('Test no rotation')
identity_rotmat = RotationMatrix(0, axis);

identity_pts = points * identity_rotmat;

assert(all(all(points == identity_pts)));


disp('Test Z 90 degree rotation')

Z90_rotmat = RotationMatrix(pi / 2.0 , axis);

Z90_pts = points * Z90_rotmat;

Z90_pts = round(Z90_pts .* 1000) ./ 1000;

Z90_reference = [0 0 0;
              0 -1 0;
              1 0 0;
              0 0 1;
              0 1 0;
              -1 0 0;
              0 0 -1];

assert(all(all(Z90_reference == Z90_pts)));

