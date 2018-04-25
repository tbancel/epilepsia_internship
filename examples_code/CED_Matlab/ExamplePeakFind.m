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

% This function opens a file and reads the data from a waveform channel as 32-bit floats. Then iterates through the data looking for local minima and maxima. It does not alter the orignal data.
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
fhand1 = CEDS64Open( 'C:\Spike7\data\Demo.smr' );
if (fhand1 <= 0); unloadlibrary ceds64int; return; end

[ iOk, TimeDate ] = CEDS64TimeDate( fhand1 );
if iOk < 0, CEDS64ErrorMessage(iOk), return; end
[ TimeBase ] = CEDS64TimeBase( fhand1 );
if iOk < 0, CEDS64ErrorMessage(iOk), return; end
[ Rate ] = CEDS64IdealRate( fhand1, 1 );
[ Div ] = CEDS64ChanDiv( fhand1, 1 );

% get waveform data from channel 1
[ fRead, fVals, fTime ] = CEDS64ReadWaveF( fhand1, 1, 100000, 0 );

L = length(fVals);
W = 20;
iPeak = 1;
iTrough = 1;
for m=1:L
    fPlot(m,2) = fVals(m);
    fPlot(m,1) = m*(TimeBase*Div);
    fint = fVals(max(m-W,1):min(m+W,L));
    if (fVals(m) == max(fint))
        Peaks(iPeak, 1) = m*(TimeBase*Div);
        Peaks(iPeak, 2) = fVals(m);
        iPeak = iPeak +1;
    else if (fVals(m) == min(fint))
        Trough(iTrough, 1) = m*(TimeBase*Div);
        Trough(iTrough, 2) = fVals(m);
        iTrough = iTrough +1;
        end
    end
end

plot(fPlot(:,1),fPlot(:,2),'-',Peaks(:,1),Peaks(:,2),'-',Trough(:,1),Trough(:,2),'-')
    
% close all the files
CEDS64CloseAll();
% unload ceds64int.dll
unloadlibrary ceds64int;