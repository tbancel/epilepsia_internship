% This function opens a file and reads the data from a waveform channel as 32-bit floats. Then downsamples the data and saves it to a new file. It does not alter the orignal data.
% clear workspace
clear;
% add path to CED code
if isempty(getenv('CEDS64ML'))
    setenv('CEDS64ML', 'C:\path\to\your\folder\CEDS64ML');
end
cedpath = getenv('CEDS64ML');
addpath(cedpath);
% load ceds64int.dll
CEDS64LoadLib( cedpath );
% Open a file
fhand1 = CEDS64Open( 'C:\Spike7\Data\Demo.smr' );
if (fhand1 <= 0); unloadlibrary ceds64int; return; end

[ iOk, TimeDate ] = CEDS64TimeDate( fhand1 );

% get waveform data from channel 1
[ fRead, fVals, fTime ] = CEDS64ReadWaveF( fhand1, 1, 100000, 0 );

% downsample the data by a factor of 12
n = 12;
DSVals = fVals(1 : n : end); % selected every 12th element for the vector

% create a new file
fhand2 = CEDS64Create( '..\Data\ExampleDS.smrx' );
if (fhand2 <= 0); unloadlibrary ceds64int; return; end
% set the time base in the new file to be the same as in the original file
timebase = CEDS64TimeBase( fhand1 );
CEDS64TimeBase( fhand2, timebase );
% set the chan divide and ideal rates to be the same as the original file
chandiv = CEDS64ChanDiv( fhand1, 1 );
rate = CEDS64IdealRate( fhand1, 1 );
% create a new real wave channel
CEDS64SetWaveChan( fhand2, 1, n*chandiv, 9, rate/n );
% write filtered data to new channel
CEDS64WriteWave( fhand2, 1, DSVals, 0 );

% close all the files
CEDS64CloseAll();
% unload ceds64int.dll
unloadlibrary ceds64int;