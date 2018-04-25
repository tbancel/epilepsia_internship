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

%This function will open the file created by ExampleCreateFile and create a new empty file. Then copy all the data from the existing file to the new file. Then close both files when it has finished copying the data

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

%libfunctionsview ceds64int;

% Open a file
fhand1 = CEDS64Open( '..\Data\ExampleCreateFile.smrx' );
if (fhand1 <= 0);  CEDS64ErrorMessage(fhand1); unloadlibrary ceds64int; return; end
maxchans = CEDS64MaxChan( fhand1 );
% Create a new file
fhand2 = CEDS64Create( '..\Data\ExampleCopy.smrx', maxchans, 2 );
if (fhand2 <= 0);  CEDS64ErrorMessage(fhand2); unloadlibrary ceds64int; return; end
% Set timebase in new file
timebase = CEDS64TimeBase( fhand1 );
if timebase < 0, CEDS64ErrorMessage(timebase), return; end
CEDS64TimeBase( fhand2, timebase );
maxTimeTicks = CEDS64MaxTime( fhand1 )+2;

% set file comment
[ iOk, sCom1 ] = CEDS64FileComment( fhand1, 1 );
CEDS64FileComment( fhand2, 1, sCom1 );
[ iOk, sCom2 ] = CEDS64FileComment( fhand1, 2 );
CEDS64FileComment( fhand2, 2, sCom2 );
[ iOk, sCom3 ] = CEDS64FileComment( fhand1, 3 );
CEDS64FileComment( fhand2, 3, sCom3 );
[ iOk, sCom4 ] = CEDS64FileComment( fhand1, 4 );
CEDS64FileComment( fhand2, 4, sCom4 );
[ iOk, sCom5 ] = CEDS64FileComment( fhand1, 5 );
CEDS64FileComment( fhand2, 5, sCom5 );

% the maximum number of items to copy from each channel
maxpoints = 1000000;

% loop through all channels in fhand1 and copy them to fhand2
for m = 1:maxchans
    chan = CEDS64ChanType( fhand1, m );
    if (chan > 0) % is there a channel m?
        chandiv = CEDS64ChanDiv( fhand1, m );
        rate = CEDS64IdealRate( fhand1, m );
    end
    switch(chan)
        case 0 % there is no channel with this number
        case 1 % ADC channel
            [shortread, shortvals, shorttime] = CEDS64ReadWaveS( fhand1, m, maxpoints, 0 );
            CEDS64SetWaveChan( fhand2, m, chandiv, 1, rate );
            CEDS64WriteWave( fhand2, m, shortvals, shorttime );
        case 2 % Event Fall
            [evread, evtimes] = CEDS64ReadEvents( fhand1, m, maxpoints, 0 );
            CEDS64SetEventChan( fhand2, m, rate, 2 );
            CEDS64WriteEvents( fhand2, m, evtimes );
        case 3 % Event Rise
            [evread, evtimes] = CEDS64ReadEvents( fhand1, m, maxpoints, 0 );
            CEDS64SetEventChan( fhand2, m, rate, 3 );
            CEDS64WriteEvents( fhand2, m, evtimes );
        case 4 % Event Both.
            [levread, levtimes, levinit] = CEDS64ReadLevels(fhand1, m, maxpoints, 0);
            CEDS64SetLevelChan( fhand2, m, rate );
            CEDS64SetInitLevel( fhand2, m, levinit );
            CEDS64WriteLevels( fhand2, m, levtimes );
        case 5 % Marker
            [markerread, markervals] = CEDS64ReadMarkers( fhand1, m, maxpoints, 0 );
            CEDS64SetMarkerChan( fhand2, m, rate, 5 );
            CEDS64WriteMarkers( fhand2, m, markervals );
        case 6 % Wave Mark
            [ iOk, Rows, Cols ] = CEDS64GetExtMarkInfo( fhand1, m );
            [wmarkerread, wmarkervals] = CEDS64ReadExtMarks( fhand1, m, maxpoints, 0 );
            CEDS64SetExtMarkChan(fhand2, m, rate, 6, Rows, Cols, chandiv);
            CEDS64WriteExtMarks( fhand2, m, wmarkervals);
        case 7 % Real Mark
            [ iOk, Rows, Cols ] = CEDS64GetExtMarkInfo( fhand1, m );
            [rmarkerread, rmarkervals] = CEDS64ReadExtMarks( fhand1, m, maxpoints, 0 );
            CEDS64SetExtMarkChan( fhand2, m, rate, 7, Rows, Cols, -1);
            CEDS64WriteExtMarks( fhand2, m, rmarkervals);
        case 8 % Text Mark
            [ iOk, Rows, Cols ] = CEDS64GetExtMarkInfo( fhand1, m );
            [tmarkerread, tmarkervals] = CEDS64ReadExtMarks( fhand1, m, maxpoints, 0 );
            CEDS64SetExtMarkChan( fhand2, m, rate, 8, Rows, Cols, -1 );
            CEDS64WriteExtMarks( fhand2, m, tmarkervals);
        case 9 % Realwave
            [floatread, floatvals, floattime] = CEDS64ReadWaveF( fhand1, m, maxpoints, 0 );
            CEDS64SetWaveChan( fhand2, m, chandiv, 9, rate );
            CEDS64WriteWave( fhand2, m, floatvals, floattime );
    end
    % copy units, comments, offsets etc.
    if (chan > 0)
        [ iOk, sComment ] = CEDS64ChanComment( fhand1, m );
        [ iOk ] = CEDS64ChanComment( fhand2, m, sComment );
        [ iOk, dOffset ] = CEDS64ChanOffset( fhand1, m );
        [ iOk ] = CEDS64ChanOffset( fhand2, m, dOffset );
        [ iOk, dScale ] = CEDS64ChanScale( fhand1, m );
        [ iOk ] = CEDS64ChanScale( fhand2, m, dScale );
        [ iOk, dTitle ] = CEDS64ChanTitle( fhand1, m );
        [ iOk ] = CEDS64ChanTitle( fhand2, m, dTitle );
        [ iOk, sUnits ] = CEDS64ChanUnits( fhand1, m );
        [ iOk ] = CEDS64ChanUnits( fhand2, m, sUnits );
    end
end
% close both files
CEDS64CloseAll();
% unload ceds64int.dll
unloadlibrary ceds64int;