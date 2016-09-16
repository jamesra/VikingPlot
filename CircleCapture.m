function CircleCapture( hFig, hAxes )
%CircleCapture: Spin the target in a circle taking pictures
    
    FrameNumber = 0; 
    
    tilt = 0;
    angle = 0;
    step = 1;

    %Figure out where the camera should be when circling the target
    view(0,0);
    drawnow
    XYva = camva; 
    
    view(0,90);
    drawnow
    XZva = camva;
    angle = 0; 
    tilt = 90; 
    step = -1;
    tilts = 90:step:0;
    camAngles = [];
    if(XZva ~= XYva)
        camAngles = XZva:-(XZva-XYva)/(length(tilts)):XYva;
    else
        camAngles = repmat(XZva, 1, length(tilts));
    end
    
    %startVA = 
    for(i = 1:length(tilts))
        f = getframe(hFig);              %Capture screen shot
        [im,map] = frame2im(f);    %Return associated image data 
        if isempty(map)            %Truecolor system
          rgb = im;
        else                       %Indexed system
          rgb = ind2rgb(im,map);   %Convert image data
        end

        imwrite(rgb, ['Frame_'  num2str(FrameNumber) '.png']);
        FrameNumber = FrameNumber +1; 
        tilt = tilts(i); 
        camva(camAngles(i)); 
        view(0,tilt);
        
        camorbit(hAxes, 0, step);
%        drawnow
    end
    
   
   camva(XYva); %Fix the camera at a set distance
   
   step = 1; 
   angle = 0; 
   while(angle < 360)
        f = getframe(hFig);              %Capture screen shot
        [im,map] = frame2im(f);    %Return associated image data 
        if isempty(map)            %Truecolor system
          rgb = im;
        else                       %Indexed system
          rgb = ind2rgb(im,map);   %Convert image data
        end
        
        imwrite(rgb, ['Frame_'  num2str(FrameNumber) '.png']);
        FrameNumber = FrameNumber +1; 
       angle = angle + step;
       view(angle,tilt);
       camorbit(hAxes, step, 0);
%       drawnow
   end
   
   for(i = length(tilts):-1:1)
    f = getframe(hFig);              %Capture screen shot
    [im,map] = frame2im(f);    %Return associated image data 
    if isempty(map)            %Truecolor system
      rgb = im;
    else                       %Indexed system
      rgb = ind2rgb(im,map);   %Convert image data
    end

    imwrite(rgb, ['Frame_'  num2str(FrameNumber) '.png']);
    FrameNumber = FrameNumber +1; 
    angle = angle + step;
    
    tilt = tilts(i); 
    camva(camAngles(i)); 
    
%    camva(camAngles(i)); 
    view(0,tilt);
   end
   
   %Camera Position: [940000 -757182 803840]
   %Camera Target: [128925 143675 13815]
    

end

