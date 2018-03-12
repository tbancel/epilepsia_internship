function checkInputs(A,B,varargin)
    minArgs=2;
    maxArgs=5;
    narginchk(minArgs,maxArgs)
    
    fprintf('Received 2 required and %d optional inputs\n', length(varargin))
end