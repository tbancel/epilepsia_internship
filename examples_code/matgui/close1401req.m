function closereq
%CLOSEREQ  Figure close request function.
%   CLOSEREQ deletes the current figure window.  By default, CLOSEREQ is
%   the CloseRequestFcn for new figures.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/08 22:41:27 $

%   Note that closereq now honors the user's ShowHiddenHandles setting
%   during figure deletion.  This means that deletion listeners and
%   DeleteFcns will now operate in an environment which is not guaranteed
%   to show hidden handles.

%  25.05.07: modified for a1401gui jgc
%  07.03.2015 modified for 64bit version (matced64c)

shh=get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
currFig=get(0,'CurrentFigure');
h1401=getappdata(currFig,'handle1401');
if h1401 > -1  % ensures 1401 is closed, assumes only 1 is open
    matced64c('cedReset');
    res=matced64c('cedCloseX');
end
disp('Exiting');
set(0,'ShowHiddenHandles',shh);
delete(currFig);

