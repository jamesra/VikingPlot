function [ options ] = ODataWebOptions( )
%ODATAWEBOPTIONS Standard options for OData webread requests
    
    options = weboptions('Timeout', 60, ...
                     'ContentType', 'json', ...
                     'CharacterEncoding', 'UTF-8');

end

