function varargout = channels(varargin)
% CHANNELS M-file for channels.fig
%      CHANNELS, by itself, creates a new CHANNELS or raises the existing
%      singleton*.
%
%      H = CHANNELS returns the handle to a new CHANNELS or the handle to
%      the existing singleton*.
%
%      CHANNELS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHANNELS.M with the given input arguments.
%
%      CHANNELS('Property','Value',...) creates a new CHANNELS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before channels_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to channels_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help channels

% Last Modified by GUIDE v2.5 26-Jan-2007 21:56:52

% Begin initialization code - DO NOT EDIT

% 13.11.07: jgc original in 6.5.1, modify for 7.0.4 (R14SP2)
%           mainly case-sensitivity
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @channels_OpeningFcn, ...
                   'gui_OutputFcn',  @channels_OutputFcn, ...
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

% 03.11.07: first version completed

% --- Executes just before channels is made visible.
function channels_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to channels (see VARARGIN)

% Choose default command line output for channels
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);



 
% OffVal=[0,0,0,0,0,0,0,0];
 tcell=varargin(2);
 chanVec=tcell{1};
 OffVal=varargin(4);
% RectVal=[0,0,0,0,0,0,0,0];
 
 strVec=varargin(6); % is a cell
 RectVal=strVec{1};  % convert to vector
 strVec=varargin(8);
 unitsPVolt=strVec{1}; % extract vector
 namesVal=varargin(10);
 unitsVal=varargin(12);
 % chanInfo holds all the channel information
 chanInfo=struct('Names',namesVal,'Units',unitsVal,'UnitsPerV',unitsPVolt,'Offset',OffVal,'On',chanVec,'Rect',RectVal);

 handles.chanInf=chanInfo;  % alternative method
 
 guidata(hObject,handles);
 
 % setappdata(gcf,'chanInfo',chanInfo);

 for i=1:8
% set default name, units, gain and offset
 eval(['set(handles.edChName' int2str(i-1) ',''String'',chanInfo.Names{' int2str(i) '});']);
 % eval(['set(handles.edUnit' int2str(i-1) ',''String'',chanInfo.Units(' int2str(i) '));']);
 eval(['set(handles.edUnit' int2str(i-1) ',''String'',chanInfo.Units{' int2str(i) '});']);
 % chanInfo.Units{1}{i}
 eval(['set(handles.edGain' int2str(i-1) ',''String'',chanInfo.UnitsPerV(' int2str(i) '));']);
 eval(['set(handles.edOffset' int2str(i-1) ',''String'',chanInfo.Offset(' int2str(i) '));']);
 % set On/off
 if (chanInfo.On(i)==1)
    eval(['set(handles.rbChan' int2str(i-1) ',''Value'',1);']);
 else
    eval(['set(handles.rbChan' int2str(i-1) ',''Value'',0);']);  
 end % if chanInfo.On
 if (chanInfo.Rect(i)==1)
    eval(['set(handles.rbRect' int2str(i-1) ',''Value'',1);']);
 else
    eval(['set(handles.rbRect' int2str(i-1) ',''Value'',0);']);  
 end % if chanInfo.Rect  
end % for i=
setappdata(gcf,'chanInfo',chanInfo); 
% UIWAIT makes channels wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = channels_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function edChName0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edChName0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end




function edChName0_Callback(hObject, eventdata, handles)
% hObject    handle to edChName0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edChName0 as text
%        str2double(get(hObject,'String')) returns contents of edChName0 as a double

handles.chanInf.Names{1}=get(hObject,'String');  % set as cell
guidata(gcf,handles);


% --- Executes during object creation, after setting all properties.
function edUnit0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edUnit0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edUnit0_Callback(hObject, eventdata, handles)
% hObject    handle to edUnit0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edUnit0 as text
%        str2double(get(hObject,'String')) returns contents of edUnit0 as a double

handles.chanInf.Units{1}=get(hObject,'String');
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function edGain0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edGain0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edGain0_Callback(hObject, eventdata, handles)
% hObject    handle to edGain0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edGain0 as text
%        str2double(get(hObject,'String')) returns contents of edGain0 as a double

handles.chanInf.UnitsPerV(1)=str2double(get(hObject,'String'));
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function edOffset0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edOffset0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edOffset0_Callback(hObject, eventdata, handles)
% hObject    handle to edOffset0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edOffset0 as text
%        str2double(get(hObject,'String')) returns contents of edOffset0 as a double

handles.chanInf.Offset(1)=str2double(get(hObject,'String'));
guidata(gcf,handles);


% --- Executes during object creation, after setting all properties.
function edChName1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edChName1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edChName1_Callback(hObject, eventdata, handles)
% hObject    handle to edChName1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edChName1 as text
%        str2double(get(hObject,'String')) returns contents of edChName1 as a double

handles.chanInf.Names{2}=get(hObject,'String');
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function edUnit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edUnit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edUnit1_Callback(hObject, eventdata, handles)
% hObject    handle to edUnit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edUnit1 as text
%        str2double(get(hObject,'String')) returns contents of edUnit1 as a double

handles.chanInf.Units{2}=get(hObject,'String');
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function edGain1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edGain1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edGain1_Callback(hObject, eventdata, handles)
% hObject    handle to edGain1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edGain1 as text
%        str2double(get(hObject,'String')) returns contents of edGain1 as a double

% alternative method:
% chanInfo=getappdata(gcf,'chanInfo');
% chanInfo.UnitsPerV(2)=str2double(get(hObject,'String'));
% setappdata(gcf,'chanInfo',chanInfo);

handles.chanInf.UnitsPerV(2)=str2double(get(hObject,'String'));
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function edOffset1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edOffset1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edOffset1_Callback(hObject, eventdata, handles)
% hObject    handle to edOffset1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edOffset1 as text
%        str2double(get(hObject,'String')) returns contents of edOffset1 as a double

handles.chanInf.Offset(2)=str2double(get(hObject,'String'));
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function edChName2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edChName2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edChName2_Callback(hObject, eventdata, handles)
% hObject    handle to edChName2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edChName2 as text
%        str2double(get(hObject,'String')) returns contents of edChName2 as a double

handles.chanInf.Names{3}=get(hObject,'String');
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function edUnit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edUnit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edUnit2_Callback(hObject, eventdata, handles)
% hObject    handle to edUnit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edUnit2 as text
%        str2double(get(hObject,'String')) returns contents of edUnit2 as a double


handles.chanInf.Units{3}=get(hObject,'String');
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function edGain2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edGain2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edGain2_Callback(hObject, eventdata, handles)
% hObject    handle to edGain2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edGain2 as text
%        str2double(get(hObject,'String')) returns contents of edGain2 as a double

handles.chanInf.UnitsPerV(3)=str2double(get(hObject,'String'));
guidata(gcf,handles);


% --- Executes during object creation, after setting all properties.
function edOffset2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edOffset2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edOffset2_Callback(hObject, eventdata, handles)
% hObject    handle to edOffset2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edOffset2 as text
%        str2double(get(hObject,'String')) returns contents of edOffset2 as a double

handles.chanInf.Offset(3)=str2double(get(hObject,'String'));
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function edChName3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edChName3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edChName3_Callback(hObject, eventdata, handles)
% hObject    handle to edChName3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edChName3 as text
%        str2double(get(hObject,'String')) returns contents of edChName3 as a double

handles.chanInf.Names{4}=get(hObject,'String');
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function edUnit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edUnit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edUnit3_Callback(hObject, eventdata, handles)
% hObject    handle to edUnit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edUnit3 as text
%        str2double(get(hObject,'String')) returns contents of edUnit3 as a double

handles.chanInf.Units{4}=get(hObject,'String');
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function edGain3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edGain3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edGain3_Callback(hObject, eventdata, handles)
% hObject    handle to edGain3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edGain3 as text
%        str2double(get(hObject,'String')) returns contents of edGain3 as a double

handles.chanInf.UnitsPerV(4)=str2double(get(hObject,'String'));
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function edOffset3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edOffset3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edOffset3_Callback(hObject, eventdata, handles)
% hObject    handle to edOffset3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edOffset3 as text
%        str2double(get(hObject,'String')) returns contents of edOffset3 as a double

handles.chanInf.Offset(4)=str2double(get(hObject,'String'));
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function edChName4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edChName4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edChName4_Callback(hObject, eventdata, handles)
% hObject    handle to edChName4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edChName4 as text
%        str2double(get(hObject,'String')) returns contents of edChName4 as a double

handles.chanInf.Names{5}=get(hObject,'String');
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function edUnit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edUnit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edUnit4_Callback(hObject, eventdata, handles)
% hObject    handle to edUnit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edUnit4 as text
%        str2double(get(hObject,'String')) returns contents of edUnit4 as a double

handles.chanInf.Units{5}=get(hObject,'String');
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function edGain4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edGain4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edGain4_Callback(hObject, eventdata, handles)
% hObject    handle to edGain4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edGain4 as text
%        str2double(get(hObject,'String')) returns contents of edGain4 as a double


handles.chanInf.UnitsPerV(5)=str2double(get(hObject,'String'));
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function edOffset4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edOffset4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edOffset4_Callback(hObject, eventdata, handles)
% hObject    handle to edOffset4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edOffset4 as text
%        str2double(get(hObject,'String')) returns contents of edOffset4 as a double


handles.chanInf.Offset(5)=str2double(get(hObject,'String'));
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function edChName5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edChName5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edChName5_Callback(hObject, eventdata, handles)
% hObject    handle to edChName5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edChName5 as text
%        str2double(get(hObject,'String')) returns contents of edChName5 as a double

handles.chanInf.Names{6}=get(hObject,'String');
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function edUnit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edUnit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edUnit5_Callback(hObject, eventdata, handles)
% hObject    handle to edUnit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edUnit5 as text
%        str2double(get(hObject,'String')) returns contents of edUnit5 as a double

handles.chanInf.Units{6}=get(hObject,'String');
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function edGain5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edGain5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edGain5_Callback(hObject, eventdata, handles)
% hObject    handle to edGain5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edGain5 as text
%        str2double(get(hObject,'String')) returns contents of edGain5 as a double

handles.chanInf.UnitsPerV(6)=str2double(get(hObject,'String'));
guidata(gcf,handles);


% --- Executes during object creation, after setting all properties.
function edOffset5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edOffset5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edOffset5_Callback(hObject, eventdata, handles)
% hObject    handle to edOffset5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edOffset5 as text
%        str2double(get(hObject,'String')) returns contents of edOffset5 as a double

handles.chanInf.Offset(6)=str2double(get(hObject,'String'));
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function edChName6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edChName6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edChName6_Callback(hObject, eventdata, handles)
% hObject    handle to edChName6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edChName6 as text
%        str2double(get(hObject,'String')) returns contents of edChName6 as a double

handles.chanInf.Names{7}=get(hObject,'String');
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function edUnit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edUnit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edUnit6_Callback(hObject, eventdata, handles)
% hObject    handle to edUnit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edUnit6 as text
%        str2double(get(hObject,'String')) returns contents of edUnit6 as a double


handles.chanInf.Units{7}=get(hObject,'String');
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function edGain6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edGain6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edGain6_Callback(hObject, eventdata, handles)
% hObject    handle to edGain6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edGain6 as text
%        str2double(get(hObject,'String')) returns contents of edGain6 as a double


handles.chanInf.UnitsPerV(7)=str2double(get(hObject,'String'));
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function edOffset6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edOffset6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edOffset6_Callback(hObject, eventdata, handles)
% hObject    handle to edOffset6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edOffset6 as text
%        str2double(get(hObject,'String')) returns contents of edOffset6 as a double

handles.chanInf.Offset(7)=str2double(get(hObject,'String'));
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function edChName7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edChName7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edChName7_Callback(hObject, eventdata, handles)
% hObject    handle to edChName7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edChName7 as text
%        str2double(get(hObject,'String')) returns contents of edChName7 as a double

handles.chanInf.Names{8}=get(hObject,'String');
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function edUnit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edUnit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edUnit7_Callback(hObject, eventdata, handles)
% hObject    handle to edUnit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edUnit7 as text
%        str2double(get(hObject,'String')) returns contents of edUnit7 as a double

handles.chanInf.Units{8}=get(hObject,'String');
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function edGain7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edGain7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edGain7_Callback(hObject, eventdata, handles)
% hObject    handle to edGain7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edGain7 as text
%        str2double(get(hObject,'String')) returns contents of edGain7 as a double

handles.chanInf.UnitsPerV(8)=str2double(get(hObject,'String'));
guidata(gcf,handles);

% --- Executes during object creation, after setting all properties.
function edOffset7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edOffset7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edOffset7_Callback(hObject, eventdata, handles)
% hObject    handle to edOffset7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edOffset7 as text
%        str2double(get(hObject,'String')) returns contents of edOffset7 as a double

handles.chanInf.Offset(8)=str2double(get(hObject,'String'));
guidata(gcf,handles);

% --- Executes on button press in rbChan0.
function rbChan0_Callback(hObject, eventdata, handles)
% hObject    handle to rbChan0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbChan0

handles.chanInf.On(1)=get(hObject,'Value');
guidata(gcf,handles);

% --- Executes on button press in rbChan1.
function rbChan1_Callback(hObject, eventdata, handles)
% hObject    handle to rbChan1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.chanInf.On(2)=get(hObject,'Value');
guidata(gcf,handles);

% --- Executes on button press in rbChan2.
function rbChan2_Callback(hObject, eventdata, handles)
% hObject    handle to rbChan2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.chanInf.On(3)=get(hObject,'Value');
guidata(gcf,handles);

% --- Executes on button press in rbChan3.
function rbChan3_Callback(hObject, eventdata, handles)
% hObject    handle to rbChan3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.chanInf.On(4)=get(hObject,'Value');
guidata(gcf,handles);


% --- Executes on button press in rbChan4.
function rbChan4_Callback(hObject, eventdata, handles)
% hObject    handle to rbChan4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.chanInf.On(5)=get(hObject,'Value');
guidata(gcf,handles);


% --- Executes on button press in rbChan5.
function rbChan5_Callback(hObject, eventdata, handles)
% hObject    handle to rbChan5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.chanInf.On(6)=get(hObject,'Value');
guidata(gcf,handles);


% --- Executes on button press in rbChan6.
function rbChan6_Callback(hObject, eventdata, handles)
% hObject    handle to rbChan6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.chanInf.On(7)=get(hObject,'Value');
guidata(gcf,handles);


% --- Executes on button press in rbChan7.
function rbChan7_Callback(hObject, eventdata, handles)
% hObject    handle to rbChan7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.chanInf.On(8)=get(hObject,'Value');
guidata(gcf,handles);

% --- Executes on button press in rbRect0.
function rbRect0_Callback(hObject, eventdata, handles)
% hObject    handle to rbRect0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbRect0

% chanInfo=getappdata(gcf,'chanInfo');
handles.chanInf.Rect(1)=get(hObject,'Value');
% setappdata(gcf,'chanInfo',chanInfo);
guidata(gcf,handles);

% --- Executes on button press in rbRect1.
function rbRect1_Callback(hObject, eventdata, handles)
% hObject    handle to rbRect1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbRect1

handles.chanInf.Rect(2)=get(hObject,'Value');
guidata(gcf,handles);

% --- Executes on button press in rbREct2.
function rbRect2_Callback(hObject, eventdata, handles)
% hObject    handle to rbREct2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbREct2

handles.chanInf.Rect(3)=get(hObject,'Value');
guidata(gcf,handles);

% --- Executes on button press in rbRect3.
function rbRect3_Callback(hObject, eventdata, handles)
% hObject    handle to rbRect3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbRect3

handles.chanInf.Rect(4)=get(hObject,'Value');
guidata(gcf,handles);

% --- Executes on button press in rbRect4.
function rbRect4_Callback(hObject, eventdata, handles)
% hObject    handle to rbRect4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbRect4

handles.chanInf.Rect(5)=get(hObject,'Value');
guidata(gcf,handles);

% --- Executes on button press in rbRect5.
function rbRect5_Callback(hObject, eventdata, handles)
% hObject    handle to rbRect5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.chanInf.Rect(6)=get(hObject,'Value');
guidata(gcf,handles);


% --- Executes on button press in rbRect6.
function rbRect6_Callback(hObject, eventdata, handles)
% hObject    handle to rbRect6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.chanInf.Rect(7)=get(hObject,'Value');
guidata(gcf,handles);


% --- Executes on button press in rbRect7.
function rbRect7_Callback(hObject, eventdata, handles)
% hObject    handle to rbRect7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.chanInf.Rect(8)=get(hObject,'Value');
guidata(gcf,handles);


% --- Executes on button press in pbAccept.
function pbAccept_Callback(hObject, eventdata, handles)
% hObject    handle to pbAccept (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[bObject, thisFigure]=gcbo;
chanInfo=getappdata(thisFigure,'chanInfo');
% could all this data just be sent back as chanInfo?
h1401fig=openfig('a1401gui','reuse');
namesVal=handles.chanInf.Names;
setappdata(h1401fig,'namesVal',namesVal);
unitsVal=handles.chanInf.Units;
setappdata(h1401fig,'unitsVal',unitsVal);
rectVal=handles.chanInf.Rect;
setappdata(h1401fig,'rectVec',rectVal);
chanVec=handles.chanInf.On;
setappdata(h1401fig,'chanVec',chanVec);
OffVal=handles.chanInf.Offset;
setappdata(h1401fig,'offVal',OffVal);
% unitspVolt=chanInfo.UnitsPerV;
unitspVolt=handles.chanInf.UnitsPerV;  % works OK for vectors
setappdata(h1401fig,'unitsPVolt',unitspVolt);

close(thisFigure);  %

% --- Executes on button press in pbIgnore.
function pbIgnore_Callback(hObject, eventdata, handles)
% hObject    handle to pbIgnore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close;  % nothing to do
