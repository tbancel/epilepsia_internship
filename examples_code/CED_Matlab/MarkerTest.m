clear;

markerbuffer(10, 1) =  CEDMarker();
tmarkerbuffer(10, 1) = CEDTextMark();
rmarkerbuffer(10, 1) = CEDRealMark();
wmarkerbuffer(10, 1) = CEDWaveMark();

string = '1729 = 1 cubed plus 12 cubed = 10 cubed plus 9 cubed';
floats = rand(25, 6, 'single');
t = (2*pi)*(1:1200)/(30);
t = int16(15000*(sin(t)));
shorts = reshape(t,300,4);

%set data

err = markerbuffer(1).SetTime( 1 );
if (err ~= 0), warning('failed to set time for a basic marker'), end
err = markerbuffer(1).SetCode( 1, 1 );
if (err ~= 0), warning('failed to set code 1 for a basic marker'), end
err = markerbuffer(1).SetCode( 2, 2 );
if (err ~= 0), warning('failed to set code 2 for a basic marker'), end
err = markerbuffer(1).SetCode( 3, 3 );
if (err ~= 0), warning('failed to set code 3 for a basic marker'), end
err = markerbuffer(1).SetCode( 4, 4 );
if (err ~= 0), warning('failed to set code 4 for a basic marker'), end

err = markerbuffer(1).SetData( 'try to add a string' );
if (err ~= -22), warning('set data for a basic marker?!'), end
err = markerbuffer(1).SetData( 0.5772156649 );
if (err ~= -22), warning('set data for a basic marker?!'), end
err = markerbuffer(1).SetData( int16(123456) );
if (err ~= -22), warning('set data for a basic marker?!'), end
err = markerbuffer(1).SetData( rand(25, 6, 'single') );
if (err ~= -22), warning('set data for a basic marker?!'), end
err = markerbuffer(1).SetData( randi(25, 6, 'int16') );
if (err ~= -22), warning('set data for a basic marker?!'), end


tmarkerbuffer(1).SetTime( 1 );
tmarkerbuffer(1).SetCode( 1, 'hello' );
tmarkerbuffer(1).SetCode( 2, 'world' );
tmarkerbuffer(1).SetCode( 3, '#' );
tmarkerbuffer(1).SetCode( 4, '!' );
tmarkerbuffer(1).SetData( string );

rmarkerbuffer(1).SetTime( 1 );
rmarkerbuffer(1).SetCode( 1, 1729 );
rmarkerbuffer(1).SetCode( 2, -1066 );
rmarkerbuffer(1).SetCode( 3, 3.14159 );
rmarkerbuffer(1).SetCode( 4, 27182.81828 );
rmarkerbuffer(1).SetData( floats );

wmarkerbuffer(1).SetTime( 1 );
wmarkerbuffer(1).SetCode( 1, 1*2 );
wmarkerbuffer(1).SetCode( 2, 1*2*3 );
wmarkerbuffer(1).SetCode( 3, 1*2*3*4 );
wmarkerbuffer(1).SetCode( 4, 1*2*3*4*5 );
t = (2*pi)*(1:1200)/(30);
t = int16(15000*(sin(t)));
wmarkerbuffer(1).SetData( shorts );

% read data

Time = markerbuffer(1).GetTime( );
if (Time ~= 1), warning('marker time incorrect'), end
Code = markerbuffer(1).GetCode( 1 );
if (Code ~= 1), warning('marker code 1 incorrect'), end
Code = markerbuffer(1).GetCode( 2 );
if (Code ~= 2), warning('marker code 2 incorrect'), end
Code = markerbuffer(1).GetCode( 3 );
if (Code ~= 3), warning('marker code 3 incorrect'), end
Code = markerbuffer(1).GetCode( 4 );
if (Code ~= 4), warning('marker code 4 incorrect'), end
Data = markerbuffer(1).GetData(  );
if (Data ~= -22), warning('marker data incorrect'), end
[ r, c ] = markerbuffer(1).Size( );
if (r ~= 0 || c ~= 0), warning('marker data size incorrect'), end

Time = tmarkerbuffer(1).GetTime( );
if (Time ~= 1), warning('textmarker time incorrect'), end
Code = tmarkerbuffer(1).GetCode( 1 );
if (Code ~= abs('h')), warning('textmarker code 1 incorrect'), end
Code = tmarkerbuffer(1).GetCode( 2 );
if (Code ~= abs('w')), warning('textmarker code 2 incorrect'), end
Code = tmarkerbuffer(1).GetCode( 3 );
if (Code ~= abs('#')), warning('textmarker code 3 incorrect'), end
Code = tmarkerbuffer(1).GetCode( 4 );
if (Code ~= abs('!')), warning('textmarker code 4 incorrect'), end
Data = tmarkerbuffer(1).GetData(  );
if (~strcmp(Data, string)), warning('textmarker data incorrect'), end
[ r, c ] = tmarkerbuffer(1).Size( );
if (r ~= 1 || c ~= length(string)), warning('textmarker data size incorrect'), end

Time = rmarkerbuffer(1).GetTime( );
if (Time ~= 1), warning('realmarker time incorrect'), end
Code = rmarkerbuffer(1).GetCode( 1 );
if (Code ~= uint8(1729) ), warning('realmarker code 1 incorrect'), end
Code = rmarkerbuffer(1).GetCode( 2 );
if (Code ~= uint8(-1066)), warning('realmarker code 2 incorrect'), end
Code = rmarkerbuffer(1).GetCode( 3 );
if (Code ~= uint8(3.14159)), warning('realmarker code 3 incorrect'), end
Code = rmarkerbuffer(1).GetCode( 4 );
if (Code ~= uint8(27182.81828)), warning('realmarker code 4 incorrect'), end
Data = rmarkerbuffer(1).GetData(  );
if (~isequal(Data, floats)), warning('realmarker data incorrect'), end
[ r, c ] = rmarkerbuffer(1).Size( );
if (r ~= size(floats, 1) || c ~= size(floats, 2)), warning('realmarker data size incorrect'), end

Time = wmarkerbuffer(1).GetTime( );
if (Time ~= 1), warning('wavemarker time incorrect'), end
Code = wmarkerbuffer(1).GetCode( 1 );
if (Code ~= 2), warning('wavemarker code 1 incorrect'), end
Code = wmarkerbuffer(1).GetCode( 2 );
if (Code ~= 6), warning('wavemarker code 2 incorrect'), end
Code = wmarkerbuffer(1).GetCode( 3 );
if (Code ~= 24), warning('wavemarker code 3 incorrect'), end
Code = wmarkerbuffer(1).GetCode( 4 );
if (Code ~= 120), warning('wavemarker code 4 incorrect'), end
Data = wmarkerbuffer(1).GetData(  );
if (~isequal(Data, shorts)), warning('wavemarker data incorrect'), end
[ r, c ] = wmarkerbuffer(1).Size( );
if (r ~= size(shorts, 1) || c ~= size(shorts, 2)), warning('wavemarker data size incorrect'), end
