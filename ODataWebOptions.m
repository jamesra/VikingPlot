function [ options ] = ODataWebOptions( )
%ODATAWEBOPTIONS Standard options for OData webread requests
    
    options = weboptions('Timeout', 30, ...
                     'ContentType', 'json', ...
                     'CharacterEncoding', 'UTF-8');

end

