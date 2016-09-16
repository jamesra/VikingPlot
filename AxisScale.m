function [ scale ] = AxisScale( scale, units )
%AXISSCALE Return a struct describing the scale along an axis

    scale = struct('Value', scale, 'Units', units);
end

