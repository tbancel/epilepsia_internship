% mat1401X_64c.m
% mfile to demonstrate use of matced64c routines
% for details of 1401 command strings see the 1401 Programmer's handbook
%
% this example assumes that matced64c is installed on the matlab
% path and that use1432.dll is in the system directory
%
% reads channels 0 and 1 and extracts the data for display
% with menu option of waiting for a trigger pulse
% uses ~X version of Open, Reset and Close that do not echo
% to the screen

% by JG Colebatch Dec 2013
% 


U14TYPEPOWER=3;  % Power1401  
yScale=5/32768; % results in Volts
res=matced64c('cedOpenX',0);  % v3+ can specify 1401
if (res < 0)
   disp(['1401 not opened, error number ' int2str(res)]);
else %opened OK  
typeOf1401=matced64c('cedTypeOf1401');  % see below
res=matced64c('cedResetX');
res=0;
% uncomment this next line, if you get a -544 error later
% res=matced64c('cedWorkingSet',400,4000);
if (res > 0)
    disp('error with call to cedWorkingSet - try commenting it out');
    return
end    
matced64c('cedLdX','C:\1401Lang\','ADCMEM','ADCBST');
% collect 100 pts at 5000 Hz from both channels 0 and 1 = 400 bytes,
% and implies a overall sampling rate of 10000 Hz for ADCMEM = 16x25
% but just set desired sample rate for ADCBST (5000Hz) = 32x25 (H clock)
if typeOf1401==U14TYPEPOWER
  matced64c('cedSendString','ADCBST,T,0,100;');  % limit burst rate on Power14
end
ktrig=input('Await trigger pulse (y=yes)? ','s');
if ktrig =='y'
   % for ADCMEM, next line should use ... HT,16,25;
   disp('Waiting for trigger (on Trigger input)');
   matced64c('cedSendString','ADCBST,I,2,0,400,0 1,1,HT,32,25;');
else % default option
   matced64c('cedSendString','ADCBST,I,2,0,400,0 1,1,H,32,25;');
end   
res=-1;
% 1401 polling loop, note pause which allows other processing
while res ~=0
   matced64c('cedSendString','ADCBST,?;');
   res=eval(matced64c('cedGetString'));
   % pause(0.1);  % this is an alternative to drawnow
   drawnow; % flushes the event queue
end
% now get the data, no. of words not bytes
data=matced64c('cedToHost',200,0);
res=matced64c('cedCloseX');
% extract the channel data
chan1samples=1:2:199;
chan2samples=chan1samples+1;
y1=data(chan1samples);
y2=data(chan2samples);
time=1:100;
time=time/5000; % in seconds
subplot(2,1,1), plot(time, yScale*y1);
title('1401 sampled data, channel 1');
xlabel('Time (s)');
ylabel('Input (Volts)');
subplot(2,1,2), plot(time, yScale*y2);
title('1401 sampled data, channel 2');
xlabel('Time (s)');
ylabel('Input (Volts)');
end