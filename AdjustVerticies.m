function [ FixedIndicies ] = AdjustVerticies( ValidIndicies, IndiciesToChange )
%ADJUSTVERTICIES Input is a set of valid indicies which is a subset of
%indicies to change. 

FixedIndicies = IndiciesToChange; 

memberVerts = ismember(ValidIndicies, IndiciesToChange);
nonmemberVerts = ~memberVerts; 
indexToSkip = iSortedVertOrder(nonmemberVerts);

for i = 1:length(indexToSkip)
  iDecrement = iSortedVertOrderTriOne > indexToSkip(i); 
  FixedIndicies(iDecrement) = FixedIndicies(iDecrement) - 1;
end

end

