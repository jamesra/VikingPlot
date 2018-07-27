function [ Locs ] = ScaleLocations( Locs, scale_struct )
%SCALELOCATIONS Scale the locations structure
     %Keep a copy of the original data and scale the coordinates.
    [Locs(:).UnscaledX] = Locs.X;
    [Locs(:).UnscaledY] = Locs.Y;
    [Locs(:).UnscaledZ] = Locs.Z;
    [Locs(:).UnscaledRadius] = Locs.Radius;

    Locs.X = Locs.X * scale_struct.X.Value;
    Locs.Y = Locs.Y * scale_struct.Y.Value;
    Locs.Z = Locs.Z * scale_struct.Z.Value;
    Locs.Radius = Locs.Radius * scale_struct.X.Value;
end

