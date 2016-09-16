function [ Structs ] = ReadStructuresFromFile( filename )
%READSTRUCTURESFROMFILE Read structures from a tab-delimited text file

    fileID = fopen(filename);
 
    Structures = textscan(fileID, '%f %f %f%*[^\n]','TreatAsEmpty',{'#'},'MultipleDelimsAsOne',1,'CommentStyle','#');

    fclose(fileID);

    Structs = horzcat(Structures{:,:});

end

