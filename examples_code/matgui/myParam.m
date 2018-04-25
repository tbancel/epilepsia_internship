function varargout = myParam(varargin)
% MYPARAM M-file for myParam.fig
%      MYPARAM, by itself, creates a new MYPARAM or raises the existing
%      singleton*.
%
%      H = MYPARAM returns the handle to a new MYPARAM or the handle to
%      the existing singleton*.
%
%      MYPARAM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MYPARAM.M with the given input arguments.
%
%      MYPARAM('Property','Value',...) creates a new MYPARAM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before myParam_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to myParam_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help myParam

% Last Modified by GUIDE v2.5 02-Jun-2007 17:48:36

% Begin initialization code - DO NOT EDIT

% by jgc colebatch
% 13.11.07: original written for 6.5.1
%           works OK with 7.0.4 (nb case-sensitivity)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @myParam_OpeningFcn, ...
                   'gui_OutputFcn',  @myParam_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before myParam is made visible.
function myParam_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to myParam (see VARARGIN)

% Choose default command line output for myParam
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes myParam wait for user response (see UIRESUME)
% uiwait(handles.figure1);

strVec=varargin(2);
chanVec=strVec{1};  % extract vector from cell{1}
for i=1:8
   eval(['set(handles.ck' int2str(i-1) ',''value'',chanVec(i));']);
end
% disp(varargin);
% this works OK - but can't send a structure as an argument
% set(handles.edLowChan,'String',varargin(2));
% highChan=str2double(varargin(4));
perimode=str2double(varargin(4));
if perimode==0
    set(handles.rbPost,'value',1);
    set(handles.rbPeri,'value',0);
elseif perimode==1
    set(handles.rbPost,'value',0);
    set(handles.rbPeri,'value',1);
end    
 % set(handles.edHighChan,'String',varargin(4));
% setappdata(hObject,'lowChan',lowChan);
% setappdata(hObject,'highChan',highChan);
% runs to do
runsToDo=str2double(varargin(6));
set(handles.edRuns,'String',varargin(6));
setappdata(hObject,'runsToDo',runsToDo);
% sample rate
sampleRate=str2double(varargin(8));
set(handles.edSampleR,'String',varargin(8));
setappdata(hObject,'sampleRate',sampleRate);
% sample Duration
sampDuration=str2double(varargin(10));
set(handles.edDurn,'String',varargin(10));
setappdata(hObject,'sampDuration',sampDuration);
%pretrig time
preTrigTime=str2double(varargin(12));
set(handles.edPreTrig,'String',varargin(12));
setappdata(hObject,'preTrigTime',preTrigTime);
setappdata(hObject,'chanVec',chanVec);


% --- Outputs from this function are returned to the command line.
function varargout = myParam_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function edLowChan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edLowChan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end




function edLowChan_Callback(hObject, eventdata, handles)
% hObject    handle to edLowChan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edLowChan as text
%        str2double(get(hObject,'String')) returns contents of edLowChan as a double

lowChan=str2double(get(hObject,'String'));
setappdata(gcf,'lowChan',lowChan);


% --- Executes during object creation, after setting all properties.
function edHighChan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edHighChan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edHighChan_Callback(hObject, eventdata, handles)
% hObject    handle to edHighChan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edHighChan as text
%        str2double(get(hObject,'String')) returns contents of edHighChan as a double

highChan=str2double(get(hObject,'String'));
setappdata(gcf,'highChan',highChan);

% --- Executes on button press in btnSave.
function btnSave_Callback(hObject, eventdata, handles)
% hObject    handle to btnSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[bObject, thisFigure]=gcbo;

h1401fig=openfig('a1401gui','reuse');  % this is now gcf
% lowChan=getappdata(gcf,'lowChan');
% highChan=getappdata(gcf,'highChan');
% setappdata(h1401fig,'lowChan',lowChan);
% setappdata(h1401fig,'highChan',highChan);
perimode=get(handles.rbPeri,'value');
setappdata(h1401fig,'periMode',perimode);
runsToDo=getappdata(thisFigure,'runsToDo');
setappdata(h1401fig,'runsToDo',runsToDo);
sampleRate=getappdata(thisFigure,'sampleRate');
setappdata(h1401fig,'sampleRate',sampleRate);
preTrigTime=getappdata(thisFigure,'preTrigTime');
setappdata(h1401fig,'preTrigTime',preTrigTime);
sampDurn=getappdata(thisFigure,'sampDuration');
setappdata(h1401fig,'sampDuration',sampDurn);
chanVec=getappdata(thisFigure,'chanVec');
setappdata(h1401fig,'chanVec',chanVec);
close(thisFigure);


% --- Executes on button press in btnCancel.
function btnCancel_Callback(hObject, eventdata, handles)
% hObject    handle to btnCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(gcf);  % send back no changes


% --- Executes during object creation, after setting all properties.
function edSampleR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edSampleR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edSampleR_Callback(hObject, eventdata, handles)
% hObject    handle to edSampleR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edSampleR as text
%        str2double(get(hObject,'String')) returns contents of edSampleR as a double

sampleRate=str2double(get(hObject,'String'));  % can use gcf becasue modal
setappdata(gcf,'sampleRate',sampleRate);


% --- Executes during object creation, after setting all properties.
function edDurn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edDurn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edDurn_Callback(hObject, eventdata, handles)
% hObject    handle to edDurn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edDurn as text
%        str2double(get(hObject,'String')) returns contents of edDurn as a double

sampDurn=str2double(get(hObject,'String'));
setappdata(gcf,'sampDurn',sampDurn);


% --- Executes on button press in rbPost.
function rbPost_Callback(hObject, eventdata, handles)
% hObject    handle to rbPost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbPost
if get(hObject,'value')==1
   set(handles.rbPeri,'value',0);  % clear the other
else
   set(handles.rbPeri,'value',1); % set the other 
 end  


% --- Executes on button press in rbPeri.
function rbPeri_Callback(hObject, eventdata, handles)
% hObject    handle to rbPeri (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbPeri
if get(hObject,'Value')==1
   set(handles.rbPost,'Value',0);  % then clear the other
else
  set(handles.rbPost,'value',1);  % otherwise set it
 end  


% --- Executes during object creation, after setting all properties.
function edPreTrig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edPreTrig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edPreTrig_Callback(hObject, eventdata, handles)
% hObject    handle to edPreTrig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edPreTrig as text
%        str2double(get(hObject,'String')) returns contents of edPreTrig as a double

preTrigTime=str2double(get(hObject,'String'));
setappdata(gcf,'preTrigTime',preTrigTime);


% --- Executes during object creation, after setting all properties.
function edRuns_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edRuns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edRuns_Callback(hObject, eventdata, handles)
% hObject    handle to edRuns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edRuns as text
%        str2double(get(hObject,'String')) returns contents of edRuns as a double

runsToDo=str2double(get(hObject,'String'));
setappdata(gcf,'runsToDo',runsToDo);


% --- Executes on button press in ck0.
function ck0_Callback(hObject, eventdata, handles)
% hObject    handle to ck0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ck0

chanVec=getappdata(gcf,'chanVec');
chanVec(1)=get(hObject,'value');
setappdata(gcf,'chanVec',chanVec);

% --- Executes on button press in ck1.
function ck1_Callback(hObject, eventdata, handles)
% hObject    handle to ck1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ck1

chanVec=getappdata(gcf,'chanVec');
chanVec(2)=get(hObject,'value');
setappdata(gcf,'chanVec',chanVec);

% --- Executes on button press in ck2.
function ck2_Callback(hObject, eventdata, handles)
% hObject    handle to ck2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ck2

chanVec=getappdata(gcf,'chanVec');
chanVec(3)=get(hObject,'value');
setappdata(gcf,'chanVec',chanVec);

% --- Executes on button press in ck3.
function ck3_Callback(hObject, eventdata, handles)
% hObject    handle to ck3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ck3

chanVec=getappdata(gcf,'chanVec');
chanVec(4)=get(hObject,'value');
setappdata(gcf,'chanVec',chanVec);

% --- Executes on button press in ck4.
function ck4_Callback(hObject, eventdata, handles)
% hObject    handle to ck4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ck4

chanVec=getappdata(gcf,'chanVec');
chanVec(5)=get(hObject,'value');
setappdata(gcf,'chanVec',chanVec);

% --- Executes on button press in ck5.
function ck5_Callback(hObject, eventdata, handles)
% hObject    handle to ck5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ck5

chanVec=getappdata(gcf,'chanVec');
chanVec(6)=get(hObject,'value');
setappdata(gcf,'chanVec',chanVec);

% --- Executes on button press in ck6.
function ck6_Callback(hObject, eventdata, handles)
% hObject    handle to ck6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ck6

chanVec=getappdata(gcf,'chanVec');
chanVec(7)=get(hObject,'value');
setappdata(gcf,'chanVec',chanVec);

% --- Executes on button press in ck7.
function ck7_Callback(hObject, eventdata, handles)
% hObject    handle to ck7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ck7


