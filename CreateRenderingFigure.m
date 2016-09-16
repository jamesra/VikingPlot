function [ hFig, hAxes ] = CreateRenderingFigure(varargin)
%CREATERENDERINGFIGURE Create the figure used to render meshes

    WindowSize = [0 0 1024 768];
    renderer = 'opengl';
    
    optargin = size(varargin,2);
    if(optargin == 1)
        WindowSize = varargin{1}; 
    elseif(optargin == 2)
        WindowSize = varargin{1};
        renderer = varargin{2};
    end
    
    hFig = figure('Units', 'Pixels', ...
        'OuterPosition', WindowSize, ...
        'Renderer', renderer, ...
        'Color', [0 0 0]);

    hAxes =  axes('color', [0 0 0], ...
                  'FontWeight', 'bold', ...
                  'XColor', [.5 .5 .5], ...
                  'YColor', [.5 .5 .5], ... 
                  'ZColor', [.5 .5 .5], ...
                  'Position', [0 0 1 1], ...
                  'DataAspectRatio', [1 1 1]);    

    hold on; 

    lightangle(45,30);
    lightangle(225,30);

end

