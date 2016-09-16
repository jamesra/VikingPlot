function [ LocLinks ] = ReadLocationLinksFromFile( filename )
%READLOCATIONSFROMFILE Read locations from a tab-delimited text file

    fileID = fopen(filename);
 
    Locations = textscan(fileID, '%d %d%*[^\n]','TreatAsEmpty',{'#'},'MultipleDelimsAsOne',1,'CommentStyle','#');

    fclose(fileID);

    LocLinks = horzcat(Locations{:,:});

end
 