function is_endpoint = IsEndpoint( server )
%ISENDPOINT Summary of this function goes here
%   Detailed explanation goes here

    is_endpoint = strncmpi(server, 'http', 4);

end

