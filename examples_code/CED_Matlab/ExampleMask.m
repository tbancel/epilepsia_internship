%This function opens the file created by ExampleCreateFile and reads the marker channels using random marker masks and then copies the masked channels to a new file

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

% create 8 random masks
CEDS64MaskReset();
for k=1:8
    CEDS64MaskMode(k, 0);
    newfilter = zeros(256, 4, 'uint8');
    [ iOk, mode ] = CEDS64MaskMode(k);
    if (mode ~= 0)
        warning('CEDS64MaskMode has failed');
    end
    for c=1:4
        for r=1:256
            if (r > 15 )
                newfilter(r,c) = 1;
            else
                newfilter(r,c) = 0;
            end
        end
    end
    CEDS64MaskCodes(k, newfilter);
    CEDS64MaskCol(k, mod(k,4));
    [ iOk, col ] = CEDS64MaskCol(k);
    if (col ~= mod(k,4))
        warning('CEDS64MaskCol has failed');
    end
end

CEDS64MaskMode(4, 1);
newfilter = zeros(256, 4, 'uint8');
newfilter(1+1,1) = 1;
newfilter(2+1,1) = 1;
newfilter(3+1,1) = 1;
newfilter(7+1,1) = 1;
newfilter(11+1,1) = 1;
newfilter(19+1,1) = 1;
newfilter(43+1,1) = 1;
newfilter(67+1,1) = 1;
newfilter(163+1,1) = 1;

[ iOk, Codes ] = CEDS64MaskCodes(4, newfilter);
[ iOk, Codes ] = CEDS64MaskCodes(4);

fhand1 = CEDS64Open( '..\Data\ExampleCreateFile.smrx' );
if (fhand1 <= 0); unloadlibrary ceds64int; return; end
maxchans = CEDS64MaxChan( fhand1 );

fhand2 = CEDS64Create( '..\Data\ExampleMask.smrx', maxchans, 2 );
if (fhand2 <= 0); unloadlibrary ceds64int; return; end

timebase = CEDS64TimeBase( fhand1 );
CEDS64TimeBase( fhand2, timebase );

for m = 1:maxchans
    type = CEDS64ChanType( fhand1, m );
    if (type > 0)
        chandiv = CEDS64ChanDiv( fhand1, m );
        rate = CEDS64IdealRate( fhand1, m );
    end
    switch(type)
        case 0 % there is no channel with this number
        case 1 % ADC channel
        case 2 % Event Fall
        case 3 % Event Rise
        case 4 % Event Both.
        case 5 % Marker
            % read all markers
            maxTimeTicks = CEDS64ChanMaxTime( fhand1, m )+1;
            [ markerread, markervals ] = CEDS64ReadMarkers( fhand1, m, 100000, 0 );
            if (markerread >= 0)
                chan = CEDS64GetFreeChan( fhand2 );
                CEDS64SetMarkerChan( fhand2, chan, rate, 5 );
                CEDS64WriteMarkers( fhand2, chan, markervals );
            end
            % read markers with a mask
            [ iOk, Codes ] = CEDS64MaskCodes( 1 );
            [ markerread, markervals ] = CEDS64ReadMarkers( fhand1, m, 100000, 0, -1, 1 );
            if (markerread >= 0)
                chan = CEDS64GetFreeChan( fhand2 );
                CEDS64SetMarkerChan( fhand2, chan, rate, 5 );
                CEDS64WriteMarkers( fhand2, chan, markervals );
            end
            % read markers with a mask as events
            [ evread, evtimes ] = CEDS64ReadEvents( fhand1, m, 100000, 0, -1, 1 );
            if (evread >= 0)
                chan = CEDS64GetFreeChan( fhand2 );
                CEDS64SetEventChan( fhand2, chan, rate, 2 );
                CEDS64WriteEvents( fhand2, chan, evtimes );
            end
        case 6 % Wave Mark
            % read all markers
            maxTimeTicks = CEDS64ChanMaxTime( fhand1, m )+1;
            [ iOk, dOffset ] = CEDS64ChanOffset( fhand1, m );
            [ iOk, dScale ] = CEDS64ChanScale( fhand1, m );
            [ iOk, Rows, Cols ] = CEDS64GetExtMarkInfo( fhand1, m );
            [ wmarkerread, wmarkervals ] = CEDS64ReadExtMarks( fhand1, m, 100000, 0 );
            if (wmarkerread >= 0)
                chan = CEDS64GetFreeChan( fhand2 );
                CEDS64SetExtMarkChan(fhand2, chan, rate, 6, Rows, Cols, chandiv);
                CEDS64WriteExtMarks( fhand2, chan, wmarkervals);
            end
            CEDS64ChanOffset( fhand2, chan, dOffset );
            CEDS64ChanScale( fhand2, chan, dScale );
            % read markers with a mask
            [ wmarkerread, wmarkervals ] = CEDS64ReadExtMarks( fhand1, m, 100000, 0, -1, 2 );
            if (wmarkerread >= 0)
                chan = CEDS64GetFreeChan( fhand2 );
                CEDS64SetExtMarkChan(fhand2, chan, rate, 6, Rows, Cols, chandiv);
                CEDS64WriteExtMarks( fhand2, chan, wmarkervals);
            end
            CEDS64ChanOffset( fhand2, chan, dOffset );
            CEDS64ChanScale( fhand2, chan, dScale );
            % read marker after 2.5s as waveform - we only get the first one
            [ waveread, wavevals, i64Time ] = CEDS64ReadWaveF( fhand1, m, 100000, CEDS64SecsToTicks(fhand1, 2.5) );
            if (waveread >= 0)
                chan = CEDS64GetFreeChan( fhand2 );
                CEDS64SetWaveChan( fhand2, chan, chandiv, 9, rate );
                CEDS64WriteWave( fhand2, chan, wavevals, i64Time);
            end
            CEDS64ChanOffset( fhand2, chan, dOffset );
            CEDS64ChanScale( fhand2, chan, dScale );
            % read markers with a mask as waveform
            [ waveread, wavevals, i64Time ] = CEDS64ReadWaveF( fhand1, m, 100000, 0, -1, 2 );
            if (waveread >= 0)
                chan = CEDS64GetFreeChan( fhand2 );
                CEDS64SetWaveChan( fhand2, chan, chandiv, 9, rate );
                CEDS64WriteWave( fhand2, chan, wavevals, i64Time);
            end
            CEDS64ChanOffset( fhand2, chan, dOffset );
            CEDS64ChanScale( fhand2, chan, dScale );
        case 7 % Real Mark
            % read all markers
            maxTimeTicks = CEDS64ChanMaxTime( fhand1, m )+1;
            [ iOk, Rows, Cols ] = CEDS64GetExtMarkInfo( fhand1, m );
            [ rmarkerread, rmarkervals ] = CEDS64ReadExtMarks( fhand1, m, 100000, 0 );
            if (rmarkerread >= 0)
                chan = CEDS64GetFreeChan( fhand2 );
                CEDS64SetExtMarkChan( fhand2, chan, rate, 7, Rows, Cols, -1);
                CEDS64WriteExtMarks( fhand2, chan, rmarkervals);
            end
            % read markers with a mask
            [ rmarkerread, rmarkervals ] = CEDS64ReadExtMarks( fhand1, m, 100000, 0, -1, 3 );
            if (rmarkerread >= 0)
                chan = CEDS64GetFreeChan( fhand2 );
                CEDS64SetExtMarkChan( fhand2, chan, rate, 7, Rows, Cols, -1);
                CEDS64WriteExtMarks( fhand2, chan, rmarkervals);
            end
            % read markers with a mask as events
            [ evread, evtimes ] = CEDS64ReadEvents( fhand1, m, 100000, 0, -1, 3 );
            if (evread >= 0)
                chan = CEDS64GetFreeChan( fhand2 );
                CEDS64SetEventChan( fhand2, chan, rate, 2 );
                CEDS64WriteEvents( fhand2, chan, evtimes );
            end
        case 8 % Text Mark
            % read all markers
            maxTimeTicks = CEDS64ChanMaxTime( fhand1, m )+1;
            [ iOk, Rows, Cols ] = CEDS64GetExtMarkInfo( fhand1, m );
            [ tmarkerread, tmarkervals ] = CEDS64ReadExtMarks( fhand1, m, 100000, 0 );
            if (tmarkerread >= 0)
                chan = CEDS64GetFreeChan( fhand2 );
                CEDS64SetExtMarkChan( fhand2, chan, rate, 8, Rows, Cols, -1 );
                CEDS64WriteExtMarks( fhand2, chan, tmarkervals );
            end
            % read markers with a mask
            [ iOk, Codes ] = CEDS64MaskCodes( 4 );
            [ tmarkerread, tmarkervals ] = CEDS64ReadExtMarks( fhand1, m, 100000, 0, -1, 4 );
            if (tmarkerread >= 0)
                chan = CEDS64GetFreeChan( fhand2 );
                CEDS64SetExtMarkChan( fhand2, chan, rate, 8, Rows, Cols, -1 );
                CEDS64WriteExtMarks( fhand2, chan, tmarkervals );
            end
            % read markers with a mask as events
            [ evread, evtimes ] = CEDS64ReadEvents( fhand1, 8, 100000, 0, -1, 4 );
            if (evread >= 0)
                chan = CEDS64GetFreeChan( fhand2 );
                CEDS64SetEventChan( fhand2, chan, rate, 2 );
                CEDS64WriteEvents( fhand2, chan, evtimes );
            end
        case 9 % Realwave
    end
    % copy units, comments, offsets etc.
    if (type > 4 && type < 9)
        [ iOk, sComment ] = CEDS64ChanComment( fhand1, m );
        CEDS64ChanComment( fhand2, chan, sComment );
        [ iOk, sTitle ] = CEDS64ChanTitle( fhand1, m );
        CEDS64ChanTitle( fhand2, chan, sTitle );
        [ iOk, sUnits ] = CEDS64ChanUnits( fhand1, m );
        CEDS64ChanUnits( fhand2, chan, sUnits );
    end
end

unloadlibrary ceds64int;