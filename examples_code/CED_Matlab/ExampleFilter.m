%{
    Copyright (C) Cambridge Electronic Design Limited 2014
    Author: Greg P. Smith
    Web: www.ced.co.uk email: greg@ced.co.uk

    This file is part of CEDS64ML, an SON MATLAB interface.

    CEDS64ML is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    CEDS64ML is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with CEDS64ML.  If not, see <http://www.gnu.org/licenses/>.
%}

% This function opens a file and reads the data from a waveform channel as 32-bit floats. Then applies a MATLAB filter to the data and saves it to a new file. It does not alter the orignal data.
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

% Set up filter parameters, see MATLAB documnetation for more details
a = 1;
b = [1/10, 1/10, 1/10, 1/10, 1/10, 1/10, 1/10, 1/10, 1/10, 1/10];

% Apply the filter to fVals and save output as FiltVals
FiltVals = filter(b, a, fVals);

% create a new file
fhand2 = CEDS64Create( '..\Data\ExampleFilter.smrx', 32, 2 );
if (fhand2 <= 0); unloadlibrary ceds64int; return; end
% set the time base in the new file to be the same as in the original file
tbase = CEDS64TimeBase( fhand1 );
CEDS64TimeBase( fhand2, tbase );
% set the chan divide and ideal rates to be the same as the original file
chandiv = CEDS64ChanDiv( fhand1, 1 );
rate = CEDS64IdealRate( fhand1, 1 );
% create a new real wave channel
CEDS64SetWaveChan( fhand2, 1, chandiv, 9, rate );
% write filtered data to new channel
CEDS64WriteWave( fhand2, 1, FiltVals, 0 );

% close all the files
CEDS64CloseAll();
% unload ceds64int.dll
unloadlibrary ceds64int;