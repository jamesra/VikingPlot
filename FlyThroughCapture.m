function FlyThroughCapture( hFig, hAxes )
%Roll down from XZ to XY and fly through volume

    XDim = get(hAxes, 'XLim'); 
    YDim = get(hAxes, 'YLim'); 
    ZDim = get(hAxes, 'ZLim'); 
    
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
        camAngles = XZva:-(XZva-XYva)/(length(tilts)-1):XYva;
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
    
    step = 1; 
    angle = 0; 
    while(angle <= 90)
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
      
    %camva(XYva); 
    view(90,0);
    
    %OK, figure out the camera position
    CamPosition = get(hAxes, 'CameraPosition');
    CamTarget = get(hAxes, 'CameraTarget'); 
    
    %Put the camera target on the back of the Y axis
    CamTarget(1) = XDim(1); 
    
    set(hAxes, 'CameraTarget', CamTarget); 
    
    %Walkt the camera forward for a while
    StepSize = (XDim(2)-XDim(1)) / 400; 
    NumSteps = (XDim(2)-XDim(1)) / 250; %Step 100 pixels each frame
    disp(['Num Steps: ' num2str(NumSteps)]); 
    Distance = CamTarget(1) - CamPosition(1); 
    Steps = CamPosition(1):Distance/NumSteps:CamTarget(1); 
    
    while(CamPosition(1) > XDim(1))
        f = getframe(hFig);              %Capture screen shot
        [im,map] = frame2im(f);    %Return associated image data 
        if isempty(map)            %Truecolor system
          rgb = im;
        else                       %Indexed system
          rgb = ind2rgb(im,map);   %Convert image data
        end

        imwrite(rgb, ['Frame_'  num2str(FrameNumber) '.png']);
        FrameNumber = FrameNumber +1; 
        
        if(CamPosition(1) > XDim(2))
            TempStep = StepSize + ((CamPosition(1) - XDim(2)) / 25);
            CamPosition(1) = CamPosition(1) - TempStep; 
        else
            CamPosition(1) = CamPosition(1) - StepSize; 
        end
        
        set(hAxes, 'CameraPosition', CamPosition); 
    end    
   
%   camva(XYva); %Fix the camera at a set distance
   


end

