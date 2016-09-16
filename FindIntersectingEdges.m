function [ VOrigin, VOne, VTwo ] = FindIntersectingEdges( TriDistToPlane, Epsilon )
%Figure out if we have two points above or below the plane
    Above = TriDistToPlane - Epsilon > 0;
    Below = TriDistToPlane + Epsilon < 0;
    Zero = abs(TriDistToPlane) <= Epsilon;
    
    if(sum(Above) > 1)
       VOrigin = find(Above == 0);
       ind = find(Above>0);
       VOne = ind(1);
       VTwo = ind(2); 
    elseif(sum(Below) > 1)
       VOrigin = find(Below == 0);
       ind = find(Below>0);
       VOne = ind(1);
       VTwo = ind(2); 
    elseif(sum(Zero) > 1)
       VOrigin = find(Zero == 0);
       ind = find(Zero>0);
       VOne = ind(1);
       VTwo = ind(2); 
    else
       %One of the points must be on the plane, make it the origin 
       VOrigin = find(Above > 0);
       VOne = find(Below > 0);
       VTwo = find(Zero > 0);
    end
    
    dbstop at 29 if isempty(VOrigin);
    dbstop at 30 if isempty(VOne);
    dbstop at 31 if isempty(VTwo);
    
%     if(isempty(VOrigin))
%         disp('Bug in FindIntersecting Edges');
%     end
% 
%     if(isempty(VOne))
%         disp('Bug in FindIntersecting Edges');
%     end
%     
%     if(isempty(VTwo))
%         disp('Bug in FindIntersecting Edges');
%     end
end

