function [ Locs ] = ReadLocationsFromFile( filename )
%READLOCATIONSFROMFILE Read locations from a tab-delimited text file

    fileID = fopen(filename);
 
    Locations = textscan(fileID, '%f %f %f %f %f %f %f %f%*[^\n]','MultipleDelimsAsOne',1,'CommentStyle','#');

    fclose(fileID);

    Locs = horzcat(Locations{:,:});

end
 