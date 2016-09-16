function PPlot(Locs, LocLinks)
    iID = 1;
    iParentID = 2; 
    iX = 3;
    iY = 4;
    iZ = 5;
    iRadius = 6;   
    
    numCirclePts = 24; 
    
    CircleVerts = CirclePatch(numCirclePts, 1, [0 0 1]); 
    Faces = CylinderFaces(numCirclePts);
    
    numLocs = size(Locs,1);
    numLinks = size(LocLinks,1);
    
    scrsz = get(0,'ScreenSize');
    hFig = figure('OuterPosition',scrsz, ...
        'Renderer', 'zbuffer');
    
    hAxes =  axes(); 
    
    nmPerPixel = 2.12; 
       
    Colors = [0, 0,0,0]; 
    DrawnSpheres = []; 
    
    hold on; 
    
    for(iLink = 1:numLinks)
        
       iLocA = find(Locs(:,1) == LocLinks(iLink,1));
       
       if(isempty(iLocA))
           continue; 
       end
       
       iLocB = find(Locs(:,1) == LocLinks(iLink,2)); 
       
       if(isempty(iLocB))
           continue; 
      
       
       
       
       end
       
       ParentID = Locs(iLocA, iParentID); 
       
       iColor = find(Colors(:,1) == ParentID,1); 
       color = [0 0 0];
       if(isempty(iColor))
          color = rand(3,1); 
          Colors(end+1, :) = [ParentID color(1) color(2) color(3)];
          [iColor, numCols] = size(Colors);
       else
          color = Colors(iColor,2:end); 
         
       end

%       set(gcf, 'Colormap', Colors(:,2:end));
       
       %Scale to using nm units
       X = [Locs(iLocA, iX) * nmPerPixel Locs(iLocB,iX) * nmPerPixel]; 
       Y = [Locs(iLocA, iY) * nmPerPixel Locs(iLocB,iY) * nmPerPixel]; 
  %     Z = [Locs(iLocA, iZ) * -90 Locs(iLocB,iZ) * -90]; 
       Z = [Locs(iLocA, iZ) Locs(iLocB,iZ)]; 
       
       if(Z(1) == 56 || Z(2) == 56 || Z(1) == 8 || Z(2) == 8 || Z(1) == 22 || Z(2) == 22 || Z(1) == 81 || Z(2) == 81 || Z(1) == 72 || Z(2) == 72 || Z(1) == 60 || Z(2) == 60) 
           continue; 
       end
       
       %Map Z into volume space
       Z = Z .* -90;
       
       RadiusA = Locs(iLocA, iRadius);
       RadiusB = Locs(iLocB, iRadius);
       
       %Create two sets of verticies for the circles
       VertsA = repmat(CircleVerts, 1);
       VertsB = repmat(CircleVerts, 1); 
       
       %Scale the radius of the two arrays
       VertsA(:,1:2) = VertsA(:,1:2) .* RadiusA; 
       VertsB(:,1:2) = VertsB(:,1:2) .* RadiusB;
       
       %Translate the position of the two arrays
       VertsA(:, 1) = VertsA(:,1) + X(1); 
       VertsA(:,2) = VertsA(:,2) + Y(1); 
       VertsA(:,3) = VertsA(:,3) + Z(1); 
       
       VertsB(:,1) = VertsB(:,1) + X(2);
       VertsB(:,2) = VertsB(:,2) + Y(2);
       VertsB(:,3) = VertsB(:,3) + Z(2); 
       
       Verts = [VertsA; 
                VertsB];
            
       patch('Faces',Faces,'Vertices',Verts, ...
             'FaceVertexCData', color, ...
             'FaceColor', color, ...
             'EdgeColor', 'none', ...
             'FaceLighting', 'phong',...
             'AmbientStrength',.3, ...
             'DiffuseStrength',.8,...
             'SpecularStrength',.9, ...
             'SpecularExponent',15,...
             'BackFaceLighting','unlit'); 
    end
    
    
    lightangle(45,30);
    
    %Set the size of the axes display
    minX = min(Locs(:,iX)) * nmPerPixel;
    maxX = max(Locs(:,iX)) * nmPerPixel;
    minY = min(Locs(:,iY)) * nmPerPixel;
    maxY = max(Locs(:,iY)) * nmPerPixel;
    minZ = min(Locs(:,iZ)) * -90;
    maxZ = max(Locs(:,iZ)) * -90;
    maxRadius = max(Locs(:,iRadius)); 
    
    set(hAxes, 'XLim', [minX-maxRadius maxX+maxRadius]); 
    set(hAxes, 'YLim', [minY-maxRadius maxY+maxRadius]); 
    set(hAxes, 'ZLim', [maxZ-maxRadius minZ+maxRadius ]); 
    
    set(hAxes, 'DataAspectRatio', [1 1 1]); 
    
    xlabel('X (nm)');
    ylabel('Y (nm)');
    zlabel('IPL Depth (nm)'); 
    
    title('Laminae of Inner Nuclear Layer Cells'); 
%     
     view(0,0);
%     angle = 0; 
%     step = 2.5;
%     while(angle < 360)
%         f = getframe(hFig);              %Capture screen shot
%         [im,map] = frame2im(f);    %Return associated image data 
%         if isempty(map)            %Truecolor system
%           rgb = im;
%         else                       %Indexed system
%           rgb = ind2rgb(im,map);   %Convert image data
%         end
%         
%         imwrite(rgb, ['Frame_'  num2str(angle/step) '.png']);
%         
%         angle = angle + step;
%         %view(angle,5);
%         camorbit(hAxes, step, 0);
%         %drawnow
%     end
%     
%     view(0,-90);
%     angle = -90; 
%     step = 2.5;
%     while(angle <= 90)
%         f = getframe(hFig);              %Capture screen shot
%         [im,map] = frame2im(f);    %Return associated image data 
%         if isempty(map)            %Truecolor system
%           rgb = im;
%         else                       %Indexed system
%           rgb = ind2rgb(im,map);   %Convert image data
%         end
%         
%         imwrite(rgb, ['VertFrame_'  num2str(angle/step) '.png']);
%         
%         angle = angle + step;
%         %view(angle,5);
%         camorbit(hAxes, 0, step);
%         %drawnow
%     end
end