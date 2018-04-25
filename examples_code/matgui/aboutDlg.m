function varargout = aboutDlg(varargin)
% ABOUTDLG M-file for aboutDlg.fig
%      ABOUTDLG, by itself, creates a new ABOUTDLG or raises the existing
%      singleton*.
%
%      H = ABOUTDLG returns the handle to a new ABOUTDLG or the handle to
%      the existing singleton*.
%
%      ABOUTDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ABOUTDLG.M with the given input arguments.
%
%      ABOUTDLG('Property','Value',...) creates a new ABOUTDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before aboutDlg_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to aboutDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help aboutDlg

% Last Modified by GUIDE v2.5 17-Nov-2007 20:48:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @aboutDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @aboutDlg_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before aboutDlg is made visible.
function aboutDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to aboutDlg (see VARARGIN)

% Choose default command line output for aboutDlg
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes aboutDlg wait for user response (see UIRESUME)
% uiwait(handles.figure1);

guiversionC=varargin(2); % it's a cell
guiversionS=guiversionC{1};
set(handles.txtMatCompat,'string','OK with Matlab 6.5.1,7.0,7.1');
set(handles.txtVersion,'string',['version: ' guiversionS]);

% --- Outputs from this function are returned to the command line.
function varargout = aboutDlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pbOK.
function pbExit_Callback(hObject, eventdata, handles)
% hObject    handle to pbOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close;
