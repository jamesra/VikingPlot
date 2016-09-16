function [ W ] = Window( Image, X, Y, Radius )
%WINDOW A helper function which returns an array of pixel values
%surrounding a target coordinate in the passed image.

%Window returns a 1D array of intensity values neighboring the
%passed coordinates.  If the window passes the boundaries of
%the input image the window is clipped. 

    [YDim, XDim, Channels] = size(Image);
    WindowDimension = ceil((Radius * 2)) + 1; 
    Output = zeros(WindowDimension * WindowDimension,Channels);
    
    MinY = Y-Radius; 
    MaxY = Y+Radius; 
    
    if(MinY <= 0)
        MinY = 1; 
    end
        
    MaxY = Y+Radius;
    if(MaxY > YDim)
        MaxY = YDim;
    end

    iOutput = 1; 
    for(iY = MinY:MaxY)       
        MinX = X-Radius;
        if(MinX <= 0)
            MinX = 1; 
        end
        
        MaxX = X+Radius;
        if(MaxX > XDim)
            MaxX = XDim;
        end
        
        XLength = MaxX - MinX; 
        Output(iOutput:iOutput+XLength,1:Channels) = Image(iY,MinX:MaxX,1:Channels); 
        
        iOutput = iOutput + XLength + 1;
    end
    
    W = Output(1:iOutput-1,:);

end

