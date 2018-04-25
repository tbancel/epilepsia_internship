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

% This function opens a file and reads the data from a waveform channel as 32-bit floats. Then applies a MATLAB Fourier transform to the data and plots it in MATLAB. It does not alter the orignal data.
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

% get waveform data from channel 1
[ fRead, fVals, fTime ] = CEDS64ReadWaveF( fhand1, 1, 100000, 0 );
Freq = CEDS64IdealRate( fhand1, 1 );

% do the Fourier transform
NFFT = 2^nextpow2(fRead);
FFTVals = fft(fVals, NFFT)/fRead;
f = Freq/2*linspace(0, 1, NFFT/2 + 1);

% plot the frequency spectrum in MATLAB
plot(f,2*abs(FFTVals(1:NFFT/2+1)));
xlabel('Frequency (Hz)');
ylabel('abs(f)');

% close all the files
CEDS64CloseAll();
% unload ceds64int.dll
unloadlibrary ceds64int;
