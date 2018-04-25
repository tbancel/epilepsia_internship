% mat1401Xp_64c.m
% mfile to demonstrate use of 1401 routine PERI32 from Matlab
% for details of 1401 command strings see the 1401 Programmer's handbook
% 
% this example assumes that matced64c.mexw64 is installed on the matlab path
% and that use1432.dll (64 bit comapatible) is also in the path
% 
% reads channels 0 and 1 in peri mode and extracts the data for display



% note that polling may lock up the PC until data has been collected
% unless drawnow or pause(n) is called
% drawnow is likely to give the fastest response to the 1401.

% JG Colebatch, first 64 bit version, Dec 2013


U14TYPEPOWER=3;  % Power1401 Mk1 
yScale=5/32768; % results in Volts
res=matced64c('cedOpenX',0);  % v3: can specify 1401 to use
if (res < 0)
   disp(['1401 not opened, error number ' int2str(res)]);
else %opened OK
typeOf1401=matced64c('cedTypeOf1401');  % see below
res=matced64c('cedResetX');
timeout=matced64c('cedGetTimeOut');
timeout=180; % default value
matced64c('cedSetTimeOut',timeout);
matced64c('cedLdX','C:\1401\','PERI32');

% collect 100 pts at 5000 Hz from both channels 0 and 1 = 400 bytes,
% set clock for 5kHz sample rate, thus H (4 Mhz) clock divide by 32x25 
% with 100 bytes prior to trigger => 5 ms prior, 15 ms after

matced64c('cedSendString','PERI32,2,0,400,0 1,100,H,32,25;');
if typeOf1401==U14TYPEPOWER  % avoid sampling bug on Power1401
     matced64c('cedSendString','PERI32,T,0,100;');  % 55 about minimum
end     
res=-1;
% 1401 polling loop, note pause which allows other processing
matced64c('cedSendString','PERI32,E;');  % set event trigger
matced64c('cedSendString','PERI32,G;');  % START SAMPLING
disp('Waiting for trigger (Event 0)');
while res ~=0
   matced64c('cedSendString','PERI32,?;');
   res=eval(matced64c('cedGetString'));
   % pause(0.1);  % this is an alternative to drawnow
   drawnow; % flushes the event queue
end
matced64c('cedSendString','PERI32,P;');
amount=matced64c('cedGetString');  % returns data sample size in bytes
% must setup transfer area, size in bytes
matced64c('cedSetTransfer',0,400);
matced64c('cedSendString','PERI32,F,0,0,400;ERR;'); % must allow time to complete
retAr=matced64c('cedLongsFrom1401',2);  % should return [0 0]
% now get the data, specify tf area (0), no. of samples and data type (2)
data=matced64c('cedGetTransData',0,200,2);
matced64c('cedUnSetTransfer',0);  % free memory specifically
res=matced64c('cedCloseX');
% extract the channel data
chan1samples=1:2:199;
chan2samples=chan1samples+1;
y1=data(chan1samples);
y2=data(chan2samples);
time=1:100;
time=time-25; % pretrigger samples/time
time=time/5; % in milliseconds
subplot(2,1,1), plot(time, yScale*y1);
title('1401 sampled data, channel 1');
xlabel('Time (ms)');
ylabel('Input (Volts)');
subplot(2,1,2), plot(time, yScale*y2);
title('1401 sampled data, channel 2');
xlabel('Time (ms)');
ylabel('Input (Volts)');
end