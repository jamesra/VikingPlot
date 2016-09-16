function AddFloatElement( DOM, Node, Name, Matrix )
%ADDFLOATELEMENT Summary of this function goes here
%   Detailed explanation goes here

    ChildNode = DOM.createElement(Name);
    numCols = size(Matrix, 1);
    if(numCols > 1)
        ChildNode.appendChild(DOM.createTextNode(num2str(reshape(Matrix', 1,[]), '%g ') ) );
    else
        ChildNode.appendChild(DOM.createTextNode(num2str(Matrix, '%g ') ) );
    end

    Node.appendChild(ChildNode);
            
end

