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

% This function creates a new file with one of each channel type and then fills each channel with random data.
clear;
% add path to CED code
if isempty(getenv('CEDS64ML'))
    setenv('CEDS64ML', 'C:\path\to\your\folder\CEDS64ML');
end
cedpath = getenv('CEDS64ML');
addpath(cedpath);
% load ceds64int.dll
CEDS64LoadLib( cedpath );

% uncomment 'libfunctionsview ceds64int' if you would like to see a list of 
% functions available in ceds64int.h. 
% WARNING, When using callib to call these functions you are
% directly accessing the file at a very low level, we cannot prevent you
% from doing anything unsafe. This could crash MATLAB or permenantly
% corrupt your data. We advise all except the most experiences users you
% avoid calling directly from the library and use CEDS64AbcXyz() functions
% instead.

%libfunctionsview ceds64int;

%create a file
%
fhand = CEDS64Create( '..\Data\ExampleCreateFile.smrx' );
if (fhand <= 0); CEDS64ErrorMessage(fhand); unloadlibrary ceds64int; return; end

filesize1 = CEDS64FileSize(fhand);
maxtime1 = CEDS64MaxTime(fhand);

% set and get file time base
CEDS64TimeBase( fhand, 0.00001 );
timebase = CEDS64TimeBase( fhand );

%Set and get file comments
CEDS64FileComment( fhand, 1, 'Hello' );
CEDS64FileComment( fhand, 2, 'World' );
CEDS64FileComment( fhand, 3, 'This comment' );
CEDS64FileComment( fhand, 4, 'was set using' );
CEDS64FileComment( fhand, 5, 'CEDS64FileComment' );

[ iOk, com1 ] = CEDS64FileComment( fhand, 1 );
[ iOk, com2 ] = CEDS64FileComment( fhand, 2 );
[ iOk, com3 ] = CEDS64FileComment( fhand, 3 );
[ iOk, com4 ] = CEDS64FileComment( fhand, 4 );
[ iOk, com5 ] = CEDS64FileComment( fhand, 5 );
clear iOk;

%version?
version = CEDS64Version(fhand);

CEDS64AppID( fhand, [ 2, -6, 24, -120, 720, 0, 0, -4 ] );
[ iOk, AppId ]= CEDS64AppID( fhand );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% create first event channel
eventchan = CEDS64GetFreeChan( fhand );
createret = CEDS64SetEventChan( fhand, eventchan, 1000, 2 );
if createret ~= 0, warning('event channel 1 not created correctly'); end;
CEDS64ChanTitle( fhand, eventchan, 'eventfall');
CEDS64ChanComment( fhand, eventchan, 'eventfall comment' );
CEDS64ChanUnits( fhand, eventchan, 'uV' );

% create second event channel
eventchan2 = CEDS64GetFreeChan( fhand );
createret = CEDS64SetEventChan( fhand, eventchan2, 1000, 3 );
if createret ~= 0, warning('event channel 2 not created correctly'); end;
CEDS64ChanTitle( fhand, eventchan2, 'eventrise');
CEDS64ChanComment( fhand, eventchan2, 'eventrise comment');
CEDS64ChanUnits( fhand, eventchan2, 'mV' );

% create level channel
levchan = CEDS64GetFreeChan( fhand );
createret = CEDS64SetLevelChan( fhand, levchan, 1000 );
if createret ~= 0, warning('level not created correctly'); end;
CEDS64SetInitLevel( fhand, levchan, 1 );
CEDS64ChanTitle( fhand, levchan, 'level');
CEDS64ChanComment( fhand, levchan, 'level comment');
CEDS64ChanUnits( fhand, levchan, 'V' );

% create adc channel
wavechan = CEDS64GetFreeChan( fhand );
createret = CEDS64SetWaveChan( fhand, wavechan, 100, 1, 1000 );
if createret ~= 0, warning('waveform channel not created correctly'); end;
CEDS64ChanTitle( fhand, wavechan, 'ADC');
CEDS64ChanComment( fhand, wavechan, 'ADC comment');
CEDS64ChanUnits( fhand, wavechan, 'KV' );

% create real wave channel
wavechan2 = CEDS64GetFreeChan( fhand );
createret = CEDS64SetWaveChan( fhand, wavechan2, 100, 9, 1000 );
if createret ~= 0, warning('realwave channel 1 not created correctly'); end;
CEDS64ChanTitle( fhand, wavechan2, 'realwave1');
CEDS64ChanComment( fhand, wavechan2, 'realwave1 comment');
CEDS64ChanUnits( fhand, wavechan2, 'MV' );

% create real wave channel
wavechan3 = CEDS64GetFreeChan( fhand );
createret = CEDS64SetWaveChan( fhand, wavechan3, 100, 9, 1000 );
if createret ~= 0, warning('realwave channel 2 not created correctly'); end;
CEDS64ChanTitle( fhand, wavechan3, 'realwave2');
CEDS64ChanComment( fhand, wavechan3, 'realwave2 comment');
CEDS64ChanUnits( fhand, wavechan3, 'GV' );

% create marker channel
markchan = CEDS64GetFreeChan( fhand );
createret = CEDS64SetMarkerChan( fhand, markchan, 1000, 5 );
if createret ~= 0, warning('marker channel not created correctly'); end;
CEDS64ChanTitle( fhand, markchan, 'markers');
CEDS64ChanComment( fhand, markchan, 'markers comment');
CEDS64ChanUnits( fhand, markchan, 'uA' );

% create textmarker channel
tmarkchan = CEDS64GetFreeChan( fhand );
createret = CEDS64SetExtMarkChan(fhand, tmarkchan, 1000, 8, 35, 1, 0);
if createret ~= 0, warning('textmarker channel not created correctly'); end;
CEDS64ChanTitle( fhand, tmarkchan, 'textmarks');
CEDS64ChanComment( fhand, tmarkchan, 'textmarks comment');
CEDS64ChanUnits( fhand, tmarkchan, 'mA' );

% create realmarker channel
rmarkchan = CEDS64GetFreeChan( fhand );
createret = CEDS64SetExtMarkChan(fhand, rmarkchan, 1000, 7, 5, 5, 0);
if createret ~= 0, warning('realmarker channel not created correctly'); end;
CEDS64ChanTitle( fhand, rmarkchan, 'realmarks');
CEDS64ChanComment( fhand, rmarkchan, 'realmarks comment');
CEDS64ChanUnits( fhand, rmarkchan, 'A' );

% create wavemarker channel
wmarkchan = CEDS64GetFreeChan( fhand );
createret = CEDS64SetExtMarkChan(fhand, wmarkchan, 1000, 6, 30, 4, 1000);
if createret ~= 0, warning('wavemarker channel not created correctly'); end;
CEDS64ChanTitle( fhand, wmarkchan, 'wavemarks');
CEDS64ChanComment( fhand, wmarkchan, 'wavemarks comment');
CEDS64ChanUnits( fhand, wmarkchan, 'KA' );
clear creatret;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% arrays of data to write to file
wavevecshort = randi([-30000, 30000],5000,1, 'int16');
wavevecdoubl = rand(5000, 1);
eventvec1 = zeros(1000, 1, 'int64');
eventvec2 = zeros(1000, 1, 'int64');
levelvec  = zeros(1000, 1, 'int64');
markerbuffer(1000, 1) =  CEDMarker();
tmarkerbuffer(1000, 1) = CEDTextMark();
rmarkerbuffer(1000, 1) = CEDRealMark();
wmarkerbuffer(1000, 1) = CEDWaveMark();

for m=1:1000    
    eventvec1(m) = CEDS64SecsToTicks( fhand, 0.001*(m*m) );
    
    eventvec2(m) = CEDS64SecsToTicks( fhand, m );
    
    levelvec(m) = CEDS64SecsToTicks( fhand, m + rand(1));
    
    markerbuffer(m).SetTime( CEDS64SecsToTicks( fhand, m ) );
    markerbuffer(m).SetCode( 1, uint8(mod(m, 256)) );
    markerbuffer(m).SetCode( 2, uint8(mod(m, 256)) );
    markerbuffer(m).SetCode( 3, uint8(mod(m, 256)) );
    markerbuffer(m).SetCode( 4, uint8(mod(m, 256)) );
    
    tmarkerbuffer(m).SetTime( CEDS64SecsToTicks( fhand, m ) );
    tmarkerbuffer(m).SetCode( 1, uint8(mod(m, 256)) );
    tmarkerbuffer(m).SetCode( 2, uint8(mod(m+1, 256)) );
    tmarkerbuffer(m).SetCode( 3, uint8(mod(m+2, 256)) );
    tmarkerbuffer(m).SetCode( 4, uint8(mod(m+3, 256)) );
    tmarkerbuffer(m).SetData( horzcat(int2str(m), ' squared is equal to ', int2str(m*m)) );
    
	rmarkerbuffer(m).SetTime( CEDS64SecsToTicks( fhand, m ) );
    rmarkerbuffer(m).SetCode( 1, uint8(mod(m, 128)) );
    rmarkerbuffer(m).SetCode( 2, uint8(mod(m, 128)) );
    rmarkerbuffer(m).SetCode( 3, uint8(mod(m, 128)) );
    rmarkerbuffer(m).SetCode( 4, uint8(mod(m, 128)) );
    rmarkerbuffer(m).SetData( rand(25, 1, 'single') );
    
    wmarkerbuffer(m).SetTime( CEDS64SecsToTicks( fhand, m ) );
    wmarkerbuffer(m).SetCode( 1, uint8(mod(m, 256)) );
    wmarkerbuffer(m).SetCode( 2, uint8(mod(m*1.23, 256)) );
    wmarkerbuffer(m).SetCode( 3, uint8(mod(m/12, 256)) );
    wmarkerbuffer(m).SetCode( 4, uint8(mod(m+666, 256)) );

    % The wavemark data is a tetrode so we need 4 columns
    t = zeros(30, 4, 'double');
    % Build our sine data in just one column
    t(:,4) = pi*(m:m+29)/7;
    % convert all of the matrix to integers
    t = int16(150*(sin(t)));
    % The same waveform, with different scalings in each column 
    t(:,1) = t(:,4) * 100;
    t(:,2) = t(:,4) * 75;
    t(:,3) = t(:,4) * 50;
    t(:,4) = t(:,4) * 25;
    wmarkerbuffer(m).SetData( t );
end
doublevec = CEDS64SecsToTicks( fhand, eventvec1 );


clear m;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% write to the channels
% fill the first event channel
fillret = CEDS64WriteEvents( fhand, eventchan, eventvec1 );
if fillret < 0, warning('event channel 1 not filled correctly'); end;
clear eventvec1;

% fill the second event channel
fillret = CEDS64WriteEvents( fhand, eventchan2, eventvec2 );
if fillret < 0, warning('event channel 2 not filled correctly'); end;
clear eventvec2;

% fill the level channel
fillret = CEDS64WriteEvents( fhand, levchan, levelvec );
if fillret < 0, warning('level channel not filled correctly'); end;
clear levelvec;

% fill the ADC channel
sTime = CEDS64SecsToTicks( fhand, 10 ); % offset start by 10 seconds
fillret = CEDS64WriteWave( fhand, wavechan, wavevecshort, sTime );
if fillret < 0, warning('waveform channel not filled correctly'); end;
clear wavevecshort;

% fill the RealWave channel
sTime = CEDS64SecsToTicks( fhand, 20 ); % offset start by 20 seconds
fillret = CEDS64WriteWave( fhand, wavechan2, wavevecdoubl, sTime );
if fillret < 0, warning('RealWave channel 1 not filled correctly'); end;

% fill the RealWave channel
sTime = CEDS64SecsToTicks( fhand, 30 ); % offset start by 30 seconds
fillret = CEDS64WriteWave( fhand, wavechan3, wavevecdoubl, sTime);
if fillret < 0, warning('RealWave channel 1 not filled correctly'); end;
clear sTime;
clear wavevecdoubl;

%fill the marker channel
fillret = CEDS64WriteMarkers( fhand, markchan, markerbuffer );
if fillret < 0, warning('marker channel not filled correctly'); end;
clear markerbuffer;

%fill the text-marker channel
fillret = CEDS64WriteExtMarks(fhand, tmarkchan, tmarkerbuffer);
if fillret < 0, warning('text-marker channel not filled correctly'); end;
clear tmarkerbuffer;

%fill the real-marker channel
fillret = CEDS64WriteExtMarks(fhand, rmarkchan, rmarkerbuffer);
if fillret < 0, warning('real-marker channel not filled correctly'); end;
clear rmarkerbuffer;

%fill the wave-marker channel
fillret = CEDS64WriteExtMarks(fhand, wmarkchan, wmarkerbuffer);
if fillret < 0, warning('wave-marker channel not filled correctly'); end;
clear wmarkerbuffer;
clear fillret;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% edit some markers in the file
getTime = CEDS64SecsToTicks( fhand, 163.234 ); % find the 3rd point before 163.234
martime = CEDS64PrevNTime( fhand, markchan, getTime, 0, 3 );
clear getTime;
editMarker = struct(CEDMarker(int64(martime), uint32(691000), uint32(172900)));
CEDS64EditMarker( fhand, markchan, martime, editMarker );
clear martime;
clear editMarker;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% read from the file
maxTimeTicks = CEDS64MaxTime(fhand);
maxTimeSecs = CEDS64TicksToSecs(fhand, maxTimeTicks);

[evread, evtimes] = CEDS64ReadEvents( fhand, eventchan, 10000, 0 );

[evread2, evtimes2] = CEDS64ReadEvents( fhand, eventchan2, 10000, 0 );

[levread, levtimes, levinit] = CEDS64ReadLevels( fhand, levchan, 10000, 0 );

[shortread, shortvals, shorttime] = CEDS64ReadWaveS( fhand, wavechan, 10000, 0 );

[waveread, wavevals, wavetime] = CEDS64ReadWaveF( fhand, wavechan2, 10000, 0 );

[doubleread, doublevals, doubletime] = CEDS64ReadWaveF( fhand, wavechan3, 10000, 0 );

[markerread, markervals] = CEDS64ReadMarkers( fhand, markchan, 10000, 0 );

[tmarkerread, tmarkervals] = CEDS64ReadExtMarks( fhand, tmarkchan, 10000, 0 );

[rmarkerread, rmarkervals] = CEDS64ReadExtMarks( fhand, rmarkchan, 10000, 0 );

[wmarkerread, wmarkervals] = CEDS64ReadExtMarks( fhand, wmarkchan, 10000, 0 );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% close the file
CEDS64CloseAll();
% unload ceds64int.dll
unloadlibrary ceds64int;