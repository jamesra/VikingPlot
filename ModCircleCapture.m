function ModCircleCapture( hFig, hAxes )
%CircleCapture: Spin the target in a circle taking pictures
    
    FrameNumber = 0; 
    
    NumFrames = 360;
    
    tilt = 0;
    angle = 0;
    step = 1;

    %Figure out where the camera should be when circling the target
    view(0,90);
    camva('auto'); 
    view(0,90);
    drawnow
    TopViewAngle = camva; 
    
    view(0,0);
    drawnow
    MidViewAngle = camva / 3;
    
    BotViewAngle = MidViewAngle / 3;
    
    startAngle = 0; 
    endAngle = 90;
    startTilt = 90;
    endTilt = -90;
    step = -1;
    tilts = 90:step:-90;
    
    camViewingAngles = [];
    
    
    
    if(TopViewAngle ~= MidViewAngle)
        %camViewingAngles = [TopViewAngle:(MidViewAngle-TopViewAngle)/((NumFrames/2)-1):MidViewAngle MidViewAngle:-(MidViewAngle-TopViewAngle)/((NumFrames/2)-1):TopViewAngle];
        camViewingAngles = [TopViewAngle:(MidViewAngle-TopViewAngle)/((NumFrames/2)-1):MidViewAngle MidViewAngle:(BotViewAngle-MidViewAngle)/((NumFrames/2)-1):BotViewAngle];
        
    else
        camViewingAngles = repmat(TopViewAngle, 1, NumFrames-1);
    end
    
    camAngles = [];
    if(startAngle ~= endAngle)
        camAngles = startAngle:(endAngle-startAngle)/(length(camViewingAngles)-1):endAngle;
    else
        camAngles = repmat(startAngle, 1, length(camViewingAngles)-1);
    end
    
    camTilts = []; 
    if(startTilt ~= endTilt)
        %camTilts = [startTilt:(endTilt-startTilt)/((NumFrames/2)-1):endTilt endTilt:-(endTilt-startTilt)/((NumFrames/2)-1):startTilt];
        camTilts = [startTilt:(endTilt-startTilt)/(length(camViewingAngles)-1):endTilt];
    else
        camTilts = repmat(startTilt, 1, length(camViewingAngles)-1);
    end
    
    for(i = 1:length(camTilts))
        
        camva(camViewingAngles(i));
        view(camAngles(i), camTilts(i));
        
        drawnow;

         f = getframe(hFig);              %Capture screen shot
         [im,map] = frame2im(f);    %Return associated image data 
         if isempty(map)            %Truecolor system
           rgb = im;
         else                       %Indexed system
           rgb = ind2rgb(im,map);   %Convert image data
         end
         
         imwrite(rgb, ['Frame_'  num2str(FrameNumber) '.png']);
         FrameNumber = FrameNumber +1; 
    end
    %startVA = 
    
%     
%     for(i = 1:length(tilts))
%         f = getframe(hFig);              %Capture screen shot
%         [im,map] = frame2im(f);    %Return associated image data 
%         if isempty(map)            %Truecolor system
%           rgb = im;
%         else                       %Indexed system
%           rgb = ind2rgb(im,map);   %Convert image data
%         end
% 
%         imwrite(rgb, ['Frame_'  num2str(FrameNumber) '.png']);
%         FrameNumber = FrameNumber +1; 
%         tilt = tilts(i); 
%         camva(camAngles(i)); 
%         view(0,tilt);
%         
%         camorbit(hAxes, 0, step);
% %        drawnow
%     end
%     
%    
%    camva(XYva); %Fix the camera at a set distance
%    
%    step = 1; 
%    angle = 0; 
%    while(angle < 360)
%         f = getframe(hFig);              %Capture screen shot
%         [im,map] = frame2im(f);    %Return associated image data 
%         if isempty(map)            %Truecolor system
%           rgb = im;
%         else                       %Indexed system
%           rgb = ind2rgb(im,map);   %Convert image data
%         end
%         
%         imwrite(rgb, ['Frame_'  num2str(FrameNumber) '.png']);
%         FrameNumber = FrameNumber +1; 
%        angle = angle + step;
%        view(angle,tilt);
%        camorbit(hAxes, step, 0);
% %       drawnow
%    end
%    
%    for(i = length(tilts):-1:1)
%     f = getframe(hFig);              %Capture screen shot
%     [im,map] = frame2im(f);    %Return associated image data 
%     if isempty(map)            %Truecolor system
%       rgb = im;
%     else                       %Indexed system
%       rgb = ind2rgb(im,map);   %Convert image data
%     end
% 
%     imwrite(rgb, ['Frame_'  num2str(FrameNumber) '.png']);
%     FrameNumber = FrameNumber +1; 
%     angle = angle + step;
%     
%     tilt = tilts(i); 
%     camva(camAngles(i)); 
%     
% %    camva(camAngles(i)); 
%     view(0,tilt);
%    end
   
   %Camera Position: [940000 -757182 803840]
   %Camera Target: [128925 143675 13815]
    

end

