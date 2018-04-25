% This function creates a new file with one of each channel type and then fills each channel with random data.
clear;
% add path to CED code
cedpath = 'C:\Users\james\Documents\MATLAB\CEDMATLAB';
addpath(cedpath);
% load ceds64int.dll
CEDS64LoadLib( cedpath );

fhand = CEDS64Create( 'C:\Spike7\PrevNTest.smrx', 32, 2 );
if (fhand <= 0); CEDS64ErrorMessage(fhand); unloadlibrary ceds64int; return; end

CEDS64TimeBase( fhand, 0.00001 );

wavechan = CEDS64GetFreeChan( fhand );
createret = CEDS64SetWaveChan( fhand, wavechan, 100, 1000, 1 );
if createret ~= 0, warning('waveform channel not created correctly'); end;
CEDS64ChanTitle( fhand, wavechan, 'ADC');
CEDS64ChanComment( fhand, wavechan, 'ADC comment');
CEDS64ChanUnits( fhand, wavechan, 'KV' );

wavevecshort = randi([-30000, 30000], 10000, 1, 'int16');

sTime = CEDS64SecsToTicks( fhand, 50 ); % offset start by 10 seconds
i64End = CEDS64WriteWave( fhand, wavechan, wavevecshort, sTime );
dEnd = CEDS64TicksToSecs( fhand, i64End );
if i64End < 0, warning('waveform channel not filled correctly'); end;
clear wavevecshort;

getTime = CEDS64SecsToTicks( fhand, 51 );
martime1 = CEDS64PrevNTime( fhand, wavechan, getTime, 0, 50 );
martime2 = CEDS64PrevNTime( fhand, wavechan, getTime, 0, 5000 );

CEDS64CloseAll();
% unload ceds64int.dll
unloadlibrary ceds64int;
