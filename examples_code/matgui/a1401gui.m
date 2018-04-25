function varargout = a1401gui(varargin)
% a1401gui M-file for a1401gui.fig
%      A1401GUI, by itself, creates a new A1401GUI or raises the existing
%      singleton*.
%
%      H = A1401GUI returns the handle to a new A1401GUI or the handle to
%      the existing singleton*.
%
%      A1401GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in A1401GUI.M with the given input arguments.
%
%      A1401GUI('Property','Value',...) creates a new A1401GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before a1401gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to a1401gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help a1401gui

% Created by GUIDE v2.5 03-Mar-2007 14:05:11
% 26.06.07: Parameters work, Delete OK, Raw/Av OK
% 18.08.07: save results
% 17.11.07: works with Matlab 7.1, note case-sensitivity - all MATCED32
%                                   (for MATCED32.DLL)
% 22.11.07: add apostrophes to allow directories with spaces
% 07.03.15: co3nverted to 64 bit version needs matced64c ver 71_64c
%           and 64bit compatible version of use1432

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @a1401gui_OpeningFcn, ...
                   'gui_OutputFcn',  @a1401gui_OutputFcn, ...
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

% --- Executes just before a1401gui is made visible.
function a1401gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to a1401gui (see VARARGIN)

% Choose default command line output for a1401gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes a1401gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% initialise
guiversion='71_64c'; % 
defSRate=5000; % default values
defsDurn=0.02;
offVal=[0 0 0 0 0 0 0 0];
chanVec=[1 1 0 0 0 0 0 0];
rectVec=[0,0,0,0,0,0,0,0];
unitspVolt=[1,1,1,1,1,1,1,1]; % default units/Volt
unitsVal={'Volts','Volts','Volts','Volts','Volts','Volts','Volts','Volts'};
namesVal={'Channel0','Channel1','Channel2','Channel3','Channel4','Channel5','Channel6','Channel7'};
h1401=matced64c('cedOpenX');
setappdata(hObject,'handle1401',h1401);
str=datestr(floor(now));
setappdata(hObject,'sampleDate',str);
str=datestr(rem(now,1));
setappdata(hObject,'sampleTime',str);
setappdata(hObject,'chanVec',chanVec);
setappdata(hObject,'offVal',offVal);
setappdata(hObject,'rectVec',rectVec);
setappdata(hObject,'noOfChan',2);
setappdata(hObject,'periMode',0);
setappdata(hObject,'runsToDo',10);
setappdata(hObject,'sampleRate',defSRate);
setappdata(hObject,'sampDuration',defsDurn);  % total, in sec
setappdata(hObject,'preTrigTime',0); % in sec
ptsperChan=round(defsDurn*defSRate);
setappdata(hObject,'pointsPerChan',ptsperChan);
setappdata(hObject,'unitsPVolt',unitspVolt);
setappdata(hObject,'unitsVal',unitsVal);
setappdata(hObject,'namesVal',namesVal);
setappdata(hObject,'guiversion',guiversion);
if (h1401<0)
    beep;
    selection=questdlg(['1401 not opened so no sampling! Err No. ' int2str(h1401)],...
        '1401 not opened!',...
        'OK','OK');
else
    matced64c('cedLd','ADCMEM','ADCBST','PERI32'); % load commands
      % ADCBST may not work on a standard 1401
   %   matced32('cedLd','ADCPERI'); % ADCPERI is obsolete now
    res=matced64c('cedResetX');
    typeOf1401=matced64c('cedTypeOf1401');
    yScale=5/32768;
    yScaleV=yScale*ones(1,8);  % 8 channels
    setappdata(hObject,'yScale',yScale);

     % setappdata(hObject,'highChan',1);
    setappdata(hObject,'runsDone',0);
   % setappdata(hObject,'testver',testver);
    setappdata(hObject,'average',0); % raw data
    setappdata(hObject,'typeOf1401',typeOf1401);
    setappdata(hObject,'version',guiversion);
   % disp('OK so far');
 end   


% --- Outputs from this function are returned to the command line.
function varargout = a1401gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function FileMain_Callback(hObject, eventdata, handles)
% hObject    handle to FileMain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenCfg1_Callback(hObject, eventdata, handles)
% hObject    handle to OpenCfg1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 [shortName, saveDir]=uigetfile({'*.mat','Mat files (*.mat)'},'Choose a filename to load');
 
 if (shortName ~= 0)
    loadfile=[saveDir shortName];
    eval(['load ' '''' loadfile '''' ';']); % avoids problems with spaces
    guiversion=getappdata(gcf,'guiversion');
    if (sampleInfo.version == guiversion)
        chanVec=chanInfo.chanVec;
        offVal=chanInfo.offVal;
        rectVec=chanInfo.rectVec;
        unitspVolt=chanInfo.unitsPVolt;        
        unitsVal=chanInfo.unitsVal;
        namesVal=chanInfo.namesVal;
        timeBase=sampleInfo.timeBase;
        timeUnit=sampleInfo.timeUnit;
        periMode=sampleInfo.periMode;
        sampleRate=sampleInfo.sampleRate;
        preTrigTime=sampleInfo.preTrigTime; % always in s
        sampleDuration=sampleInfo.sampleDuration; % always in s
        runsToDo=sampleInfo.runsDone;
        % now set the values - to be completed
        setappdata(gcf,'chanVec',chanVec);
        setappdata(gcf,'offVal',offVal);
        setappdata(gcf,'rectVec',rectVec);
        setappdata(gcf,'namesVal',namesVal);
        setappdata(gcf,'unitsVal',unitsVal);
        setappdata(gcf,'runsToDo',runsToDo);
        setappdata(gcf,'periMode',periMode);
        setappdata(gcf,'preTrigTime',preTrigTime);
        setappdata(gcf,'sampDuration',sampleDuration);
        setappdata(gcf,'sampleRate',sampleRate);
        setappdata(gcf,'unitsPVolt',unitspVolt);
    else
        beep;
        disp('Wrong version');
        return
    end % if sampleInfo    
 else
    disp('User cancelled');
 end  % if shortName    

% --------------------------------------------------------------------
function Save1_Callback(hObject, eventdata, handles)
% hObject    handle to Save1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sampleOK=getappdata(gcf,'sampleOK');
runsDone=getappdata(gcf,'runsDone');
if (sampleOK==1) && (runsDone > 0)
  % next two lines are for adding a comment - comment out if not required
  beep;
  fcomment=input('Comment for this file: ','s');

    % test=getappdata(gcf,'testver');  % flag for test version (= 1)
  [shortName, saveDir]=uiputfile({'*.mat','Mat files (*.mat)'},'Choose a filename to save');

 if shortName ~= 0
  
  saveFName=[saveDir shortName];

 % need to save multiple channels here

  chanVec=getappdata(gcf,'chanVec');
  chanSamp=[];
  for i=1:8
    if chanVec(i)
        chanSamp=[chanSamp (i-1)]; % 
    end % if chanVec
  end % for i= 
  rectVec=getappdata(gcf,'rectVec');
  noOfChan=length(chanSamp);   
  timeBase=getappdata(gcf,'Timebase');
  timeUnit=getappdata(gcf,'Time_Unit');
  sampleRate=getappdata(gcf,'sampleRate');
  sampleDate=getappdata(gcf,'sampleDate');
  sampleTime=getappdata(gcf,'sampleTime');
  sampleDuration=getappdata(gcf,'sampDuration');
  runsDone=getappdata(gcf,'runsDone');
  preTrigTime=getappdata(gcf,'preTrigTime');
  mode=getappdata(gcf,'periMode');
  version=getappdata(gcf,'version');
  unitspVolt=getappdata(gcf,'unitsPVolt');
  unitsVal=getappdata(gcf,'unitsVal'); % retrieves the cell OK
  namesVal=getappdata(gcf,'namesVal');
  offVal=getappdata(gcf,'offVal');
  unitspVolt=getappdata(gcf,'unitsPVolt');
  guiversion=getappdata(gcf,'guiversion');
  sampleInfo=struct('version',guiversion,'date',sampleDate, 'time',sampleTime,'comment', fcomment,...
      'timeBase',timeBase,'timeUnit',timeUnit,'sampleRate',sampleRate, ...
      'periMode', mode, 'preTrigTime', preTrigTime, 'sampleDuration', sampleDuration, 'runsDone', runsDone);
  chanInfo=struct('chanVec',chanVec,'offVal', offVal,'rectVec',rectVec,'unitsPVolt',unitspVolt,...
       'namesVal',{namesVal},'unitsVal',{unitsVal});  % etc
  saveData=[];
  for i=1:noOfChan
   chanNo=chanSamp(i);   
   eval(['chan' int2str(chanNo) 'Data=getappdata(gcf,''chan' int2str(chanNo) 'Data'');']);
   eval(['saveData=[saveData '' chan' int2str(chanNo) 'Data''];']);
  end
   eval(['save ' '''' saveFName '''' ' sampleInfo chanInfo' saveData]); % needed for spaces in directory    
else
     disp('User cancelled save');
 end % if shortname ~=0    

else
    beep;
    disp('Sampling or no data collected - cannot save');
end    

% --------------------------------------------------------------------
function Print1_Callback(hObject, eventdata, handles)
% hObject    handle to Print1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ignores print dialog

set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperPosition',[0.6 1.2 19.2 24]);
% print -dwinc;
printdlg(gcf);


% --------------------------------------------------------------------
function Exit1_Callback(hObject, eventdata, handles)
% hObject    handle to Exit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

beep;
h1401=getappdata(gcf,'handle1401');   
selection=questdlg(['Close ' get(gcf,'Name') '?'],...
     ['Close ' get(gcf,'Name') '...'],...
     'Yes','No','Yes');
 if strcmp(selection,'No')
     return;
 end
 if h1401 > -1
    res=matced64c('cedCloseX');
    setappdata(gcf,'handle1401',-1);  % must flag its closed
 end
% pOpen=getappdata(gcf,'pFigOpen'); % must update this is pFigure closed
% if pOpen==1
%  h=getappdata(gcf,'pHandle');
%  close(h);  % note this causes trouble if the figure is not open !
% end
 h=gcf;
 close(h);

% --------------------------------------------------------------------
function Sample2_Callback(hObject, eventdata, handles)
% hObject    handle to SamplingMain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% header only

[object,mfigure]=gcbo;  % get figure handle (must be gcf)
U14TYPEPOWER=3;  % Power1401 
h1401=getappdata(mfigure,'handle1401');
typeOf1401=getappdata(mfigure,'typeOf1401');
if h1401 >=0  % must have valid handle to sample
if exist('dataRun','var') > 0
    eval('clear dataRun');
end  

bytesToCollect=0;
runsDone=0;
sampleOK=1;
setappdata(mfigure,'sampleOK',sampleOK);
setappdata(mfigure,'runsDone',runsDone);
% loChan=getappdata(mfigure,'lowChan');
% hiChan=getappdata(mfigure,'highChan');
% chanVec=[0 1];  % this has to be sequential channels at present
chanRect=getappdata(mfigure,'rectVec');
chanVec=getappdata(mfigure,'chanVec');

% convert chanVec to 1401 command compatible
chanSamp=[];
% chanRect=[];
% chanRect=rectVec;
for i=1:8
    if chanVec(i)
        chanSamp=[chanSamp (i-1)]; % for 1401 command line
    end % if chanVec
  %  if rectVec(i)
  %      chanRect=[chanRect (i)];
  %  end    
end % for i=    
% setappdata(mfigure,'chanVec',chanVec);
noOfChan=length(chanSamp);
setappdata(mfigure,'noOfChan',noOfChan);
for i=1:noOfChan
    eval(['chan' int2str(i) 'data=[];']);
end    
sampleRate=getappdata(mfigure,'sampleRate');
periMode=getappdata(mfigure,'periMode');
% disp(['sample rate now is: ' num2str(sampleRate)]);
% efsampRate=noOfChan*sampleRate;
efsampRate=sampleRate; % if not using ADCMEM
div2=round(200000/efsampRate);
sampleRate=200000/div2; % ignore noOfChan for ADCBSTR and PERI32
setappdata(mfigure,'sampleRate',sampleRate);  % true rate, not nec what was set
sampDuration=getappdata(mfigure,'sampDuration');
chSampPts=round(sampDuration*sampleRate);
setappdata(mfigure,'pointsPerChan',chSampPts);
preTrigTime=getappdata(mfigure,'preTrigTime');
sampleTime=datestr(rem(now,1));
nulldata=ones(1,chSampPts);
time=1:chSampPts;
timeUnit='s';
time=time/sampleRate;  % in seconds
if periMode==1
      time=time-preTrigTime;
 end    
 if max(time) < 0.5    
      time=time*1000;  % display in msec
      timeUnit='ms';
end  
setappdata(mfigure,'Timebase',time);
setappdata(mfigure,'Time_Unit',timeUnit);
% disp(['preTrigTime is: ' num2str(preTrigTime)]);
 for i=1:noOfChan
  chanToDo=noOfChan-i+1;  
  eval(['subplot(' int2str(noOfChan) ',1,' int2str(chanToDo) ');']);
  plot(time, nulldata);  % clears display
  if i==1
      xlabel(['Time (' timeUnit ')']);
  end    
end  
title('Waiting for trigger');
runsToDo=getappdata(mfigure,'runsToDo');
bytesToCollect=noOfChan*2*chSampPts;
if periMode==1
 preTrigBytes=noOfChan*2*round(sampleRate*preTrigTime);
 if preTrigBytes > bytesToCollect
   disp(['Error in pretrigger time: total is ' int2str(bytesToCollect) ' pre: ' int2str(preTrigBytes)] );
   return
 end
end % if periMode==1 
% note can use the 'H' clock here if faster sampling required
if periMode==0
  sendStr=['ADCBST,I,2,0,' int2str(bytesToCollect) ',' int2str(chanSamp) ',1,HT,20,' int2str(div2) ';ERR;'];
  if typeOf1401==U14TYPEPOWER  % avoid sampling bug on Power1401
     matced64c('cedSendString','ADCBST,T,0,100;');  % 55 about minimum
  end 
 disp('Expect trigger on Trigger input');
else
    % preTrigger mode
  sendStr=['PERI32,2,0,' int2str(bytesToCollect) ',' int2str(chanSamp) ',' ];
  sendStr=[sendStr int2str(preTrigBytes) ',H,20,' int2str(div2) ';ERR;'];  % CT not meaningful  
  if typeOf1401==U14TYPEPOWER  % avoid sampling bug on Power1401
     matced64c('cedSendString','PERI32,T,0,100;');  % 55 about minimum
  end 
  matced64c('cedSetTransfer',0,bytesToCollect);  % set transfer area (v3 of matced32)
  disp('Expect trigger on Event 0 input');
end
testver=getappdata(mfigure,'testver');
if testver==1
    disp(['sendStr is ' sendStr]);
end
if getappdata(mfigure,'handle1401') < 0
        selection= questdlg('1401 not opened so no sampling!', ...
                    '1401 not opened!',...
                   'OK','OK'); 
           else
   % start sampling  ***********************************
  
  while (runsDone < runsToDo ) && (sampleOK==1)  % allow early stopping
    matced64c('cedSendString',sendStr);      
    retAr=matced64c('cedLongsFrom1401',2); % waits for command to be processed 
  if periMode==1  
    matced64c('cedSendString','PERI32,E;');  % set Event 0 trigger
    matced64c('cedSendString','PERI32,G;');  % and start sampling
  end    
   res=-1;
  % 1401 polling loop
  % get more data, only for ADCBST/ADCMEM  
  while (res ~=0)
      if periMode==0
         matced64c('cedSendString','ADCBST,?;');
      else
         matced64c('cedSendString','PERI32,?;'); 
      end   
      sampleOK=getappdata(mfigure,'sampleOK');
      if sampleOK==1
         tmp=matced64c('cedGetString');
         res=eval(tmp);
     else
         res=0;
     end
      drawnow;  % flush event cue
  end
  % get and display data
 %  disp('a1401: triggered'); % test only
  if sampleOK==1  % start of the sampleOK loop - don't transfer/display if stopped
   if periMode==0   
      dataRun=matced64c('cedToHost',bytesToCollect,0);
   else % peri32 mode
      matced64c('cedSendString','PERI32,P;'); % bytesAvail should = bytesToCollect
      bytesAvail=eval(matced64c('cedGetString'));
      if bytesAvail ~= bytesToCollect
       disp('Difference in byte sizes');
      end    
      sendStr=['PERI32,F,0,0,' int2str(bytesAvail) ';ERR;'];
      matced64c('cedSendString',sendStr);
      retAr2=matced64c('cedLongsFrom1401',2); % imp. waits for data to be reordered
      % now get the sampled data
      intAvail=round(bytesAvail/2);
      dataRun=matced64c('cedGetTransData',0,intAvail,2);
   end % peri mode  
   runsDone=getappdata(mfigure,'runsDone');
   runsDone=runsDone+1;
   setappdata(mfigure,'runsDone',runsDone); % allows restart
  % extract channel data - write for arbitrary no. of channels

  baseSamples=1:noOfChan:round(bytesToCollect/2);
  yBase=dataRun(baseSamples);
%  time=1:length(yBase);
  if (length(chanRect)>0) && chanRect(chanSamp(1)+1)  % first
      yBase=abs(yBase);
  end    
  eval(['y' int2str(chanSamp(1)) '=yBase;']);    
  eval(['setappdata(mfigure,''y' int2str(chanSamp(1)) ''',yBase);']);
  clear yBase;
  
  yScale=getappdata(mfigure,'yScale');
 % yScaleV=getappdata(mfigure,'yScaleV');
  average=getappdata(mfigure,'average');
 if noOfChan > 1 
  for i=2:noOfChan
  chanNo=chanSamp(i);
  eval(['chan' int2str(chanNo) 'samples=baseSamples+(i-1);']);
  eval(['y' int2str(chanNo) '=dataRun(chan' int2str(chanNo) 'samples);']);
  if (length(chanRect) > 0) && chanRect(chanSamp(i)+1)
    eval(['y' int2str(chanNo) '=abs(y' int2str(chanNo) ');']); % rectify
  end % if chanRect    
  eval(['setappdata(mfigure,''y' int2str(chanNo) ''',y' int2str(chanNo) ');']);
  end % for i loop
 end % if noOfChan
for i=1:noOfChan
  chanToDo=chanSamp(i);   % 
  eval(['chan' int2str(chanToDo) 'Data(runsDone,:)=yScale*y' int2str(chanToDo) ';']);
  eval(['channel=chan' int2str(chanToDo) 'Data;']);   
  eval(['setappdata(mfigure,''chan' int2str(chanToDo) 'Data'',channel);']);
  eval(['ymean=mean(chan' int2str(chanToDo) 'Data(1:runsDone,:));']);  % calculate the average
  % and save it
  eval(['setappdata(mfigure,''y' int2str(chanToDo) 'mean'',ymean);']);
  if average==0 
    eval(['subplot(noOfChan,1,i), plot(time, yScale*y' int2str(chanToDo) ');']);
   else
    subplot(noOfChan,1,i), plot(time, yScale*ymean);
  end  % average 
  eval(['ylabel(''Chan ' int2str(chanToDo) ' (V)'');']);
  if i==1  % title at top
    if average==0
       title(['Showing raw data: ' int2str(runsDone) ' of ' int2str(runsToDo)]);  
    else
        title(['Showing average data: ' int2str(runsDone) '/' int2str(runsToDo)]); 
    end   
  end
  if i==noOfChan % print at bottom
        xlabel(['Time (' timeUnit ')']);  % temp
  end    
end % i (chan display) loop 

else  % if sampleOK==1
   if periMode==1
      matced64c('cedUnSetTransfer',0); % free memory now
   end % if periMode ==    
   res=matced64c('cedResetX'); % don't leave the 1401 hanging.
end % if sampleOK==1 loop
end  %sweep loop *******************************8

beep  % flag finished
 setappdata(mfigure,'sampleTime',sampleTime);
if sampleOK==1 % #2
 for i=1:noOfChan
   chanToDo=chanSamp(i);  
   eval(['channel=chan' int2str(chanToDo) 'Data;']);   
   eval(['setappdata(mfigure,''chan' int2str(chanToDo) 'Data'',channel);']);
 % setappdata(mfigure,'chan2Data',chan2Data);
 end % i chan allocation
end % if samnpleOK #2
end
else % if h1401 >=0
    beep
    disp('No valid 1401 handle, no sampling');
end    




% --------------------------------------------------------------------
function AverageMain3_Callback(hObject, eventdata, handles)
% hObject    handle to AverageMain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% header only


% --------------------------------------------------------------------
function AboutMain4_Callback(hObject, eventdata, handles)
% hObject    handle to AboutMain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Parameters2_Callback(hObject, eventdata, handles)
% hObject    handle to Parameters2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% sets sampling parameters

[bObject,thisFigure]=gcbo;
chanVec=getappdata(thisFigure,'chanVec');
periMode=int2str(getappdata(thisFigure,'periMode'));
runsToDo=int2str(getappdata(thisFigure,'runsToDo'));
sampleRate=num2str(getappdata(thisFigure,'sampleRate'));
sampDuration=num2str(getappdata(thisFigure,'sampDuration'));
preTrigTime=num2str(getappdata(thisFigure,'preTrigTime'));
myPhandle=myParam('chanVec',chanVec,'periMode',periMode,...
                 'runsToDo',runsToDo,'sampleRate',sampleRate,...
                 'sampDuration',sampDuration,'preTrigTime',preTrigTime);  % send parameters, as strings
% myPhandle=myParam;
setappdata(thisFigure,'pHandle',myPhandle);
setappdata(thisFigure,'pFigOpen',1);
% setappdata(myPhandle,'lowChan',lowChan);
% setappdata(myPhandle,'highChan',hiChan);


% --------------------------------------------------------------------
function Channels2_Callback(hObject, eventdata, handles)
% hObject    handle to Channels2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% sets channel data

[bObject, thisFigure]=gcbo;
chanVec=getappdata(thisFigure,'chanVec');
offVal=getappdata(thisFigure,'offVal');
rectVec=getappdata(thisFigure,'rectVec');
unitspVolt=getappdata(thisFigure,'unitsPVolt');
unitsVal=getappdata(thisFigure,'unitsVal'); % retrieves the cell OK
namesVal=getappdata(thisFigure,'namesVal');
myCHandle=channels('chanVec',chanVec,'offVal',offVal,'rectVec',rectVec,'unitsPVolt',unitspVolt,...
     'namesVal',namesVal,'unitsVal',unitsVal);
setappdata(thisFigure,'chFigOpen',1);

% --------------------------------------------------------------------
function Delete2_Callback(hObject, eventdata, handles)
% hObject    handle to Delete2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% this requires double buffering


runsDone=getappdata(gcf,'runsDone');
if runsDone > 0
yScale=getappdata(gcf,'yScale');
timebase=getappdata(gcf,'Timebase');
timeUnit=getappdata(gcf,'Time_Unit');
average=getappdata(gcf,'average');
chanVec=getappdata(gcf,'chanVec');
noOfChan=sum(chanVec);  % not length!
chanSamp=[];
for i=1:8
    if chanVec(i)
        chanSamp=[chanSamp (i-1)];
    end % if chanVec
end % for i=
% length(chanSamp) sbould also = noOfChan
runsToDo=getappdata(gcf,'runsToDo');

% still have to adjust the average though, if displayed
runsDone=runsDone-1;
setappdata(gcf,'runsDone',runsDone); 
for i=1:noOfChan
  chanToDo=chanSamp(noOfChan-i+1);     
  eval(['chanData=getappdata(gcf,''chan' int2str(chanToDo) 'Data'');']);
  eval(['chan' int2str(chanToDo) 'Data=chanData;']);
  if runsDone > 0 
    eval(['yToDo=chan' int2str(chanToDo) 'Data(runsDone,:);']);
    eval(['ymean=mean(chan' int2str(chanToDo) 'Data(1:runsDone,:));']);  % calculate the average
  else  % set to zero
    eval(['yToDo=zeros(1,length(chan' int2str(chanToDo) 'Data(1,:)));']);
    ymean=yToDo;  % set it to zero as well
  end    
  % and save it
  eval(['setappdata(gcf,''y' int2str(chanToDo) 'mean'',ymean);']);
 if average==0 
   % eval(['yToDo=getappdata(gcf,''y' int2str(chanToDo) ''');']);
   subplot(noOfChan,1,noOfChan-i+1), plot(timebase, yScale*yToDo);
  else
   % eval(['ymean=getappdata(gcf,''y' int2str(chanToDo) 'mean'');']);
   subplot(noOfChan,1,noOfChan-i+1), plot(timebase, yScale*ymean);
  end            
  eval(['ylabel(''Chan ' int2str(chanToDo) ' (V)'');']);  
  if i==1
      xlabel(['Time (' timeUnit ')']);
  end % for i==1    
end % for i

if average==0
     title(['Showing raw data: ' int2str(runsDone) ' of ' int2str(runsToDo)]); 
 else
     title(['Showing average data: ' int2str(runsDone) '/' int2str(runsToDo)]);
end  % average==0  


else  % have pressed delete with no data collected
   beep;
   disp('No data to delete!');
end    


% --------------------------------------------------------------------
function Restart2_Callback(hObject, eventdata, handles)
% hObject    handle to Restart2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sampPts=getappdata(gcf,'pointsPerChan');
noOfChan=getappdata(gcf,'noOfChan');
time=getappdata(gcf,'Timebase');
tlabel=getappdata(gcf,'Time_Unit');
nulldata=ones(1,sampPts);
% disp(['preTrigTime is: ' num2str(preTrigTime)]);
for i=1:noOfChan
  chanToDo=noOfChan-i+1;  
  eval(['subplot(' int2str(noOfChan) ',1,' int2str(chanToDo) ');']);
  plot(time, nulldata);  % clears previous display
  if i==1
     xlabel(['Time (' tlabel ')']);
 end   
end 
title('Sampling restarted: waiting');
setappdata(gcf,'runsDone',0);

% --------------------------------------------------------------------
function Kill2_Callback(hObject, eventdata, handles)
% hObject    handle to Kill2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 h1401=getappdata(gcf,'handle1401');
 if h1401 >=0
  sampPts=getappdata(gcf,'pointsPerChan');
  noOfChan=getappdata(gcf,'noOfChan');
  timebase=getappdata(gcf,'Timebase');
  tlabel=getappdata(gcf,'Time_Unit');
  nulldata=ones(1,sampPts);
  for i=1:noOfChan
    chanToDo=noOfChan-i+1;  
    eval(['subplot(' int2str(noOfChan) ',1,' int2str(chanToDo) ');']);
    plot(timebase, nulldata);  % clears display
     if i==1
      xlabel(['Time (' tlabel ')']);
    end   
  end 
   setappdata(gcf,'sampleOK',0);
   res=matced64c('cedResetX');
   title('Sampling killed');
else
  beep;  
  disp('No sampling possible!');
end

% --------------------------------------------------------------------
function About4_Callback(hObject, eventdata, handles)
% hObject    handle to About4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guiversion=getappdata(gcf,'guiversion');
aboutH=aboutDlg('guiversion',guiversion);  % show about, send version as parameter (cell)

% --------------------------------------------------------------------
function RawOrAv3_Callback(hObject, eventdata, handles)
% hObject    handle to RawOrAv3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

runsDone=getappdata(gcf,'runsDone');
chanVec=getappdata(gcf,'chanVec');
average=getappdata(gcf,'average');
runsToDo=getappdata(gcf,'runsToDo');
yScale=getappdata(gcf,'yScale');
timeUnit=getappdata(gcf,'Time_Unit');
timebase=getappdata(gcf,'Timebase');
% size(timebase);
chanSamp=[];
for i=1:8
    if chanVec(i)
        chanSamp=[chanSamp (i-1)];
    end % if chanVec
end % for i=    
noOfChan=length(chanSamp);
% now invert the option for next time
if average==0
    average=1;
else
    average=0;
end
for i=1:noOfChan
  chanToDo=chanSamp(noOfChan-i+1);     
 if average==0 
   eval(['yToDo=getappdata(gcf,''y' int2str(chanToDo) ''');']);
   subplot(noOfChan,1,noOfChan-i+1), plot(timebase, yScale*yToDo);
  else
   eval(['ymean=getappdata(gcf,''y' int2str(chanToDo) 'mean'');']);
  % size(yScale)
  % size(ymean)
   subplot(noOfChan,1,noOfChan-i+1), plot(timebase, yScale*ymean);
  end            
  eval(['ylabel(''Chan ' int2str(chanToDo) ' (V)'');']);  
  if i==1
      xlabel(['Time (' timeUnit ')']);
  end % for i==1    
end % for i
if average==0
     title(['Showing raw data: ' int2str(runsDone) ' of ' int2str(runsToDo)]); 
 else
     title(['Showing average data: ' int2str(runsDone) '/' int2str(runsToDo)]);
end  

setappdata(gcf,'average',average);
