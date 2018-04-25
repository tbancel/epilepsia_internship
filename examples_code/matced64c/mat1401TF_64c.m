% mat1401TF.m
% test data tf to 1401

% 02.02.10: jgc
% 14.12.13 remove roundoff errros

datalength=100000;
U14TYPEPOWER=3;  % Power1401  
scale=32767; % results in Volts
res=matced64c('cedOpenX',0);  % v3+ can specify 1401
if (res < 0)
   disp(['1401 not opened, error number ' int2str(res)]);
   return
end %opened OK  
typeOf1401=matced64c('cedTypeOf1401');  % see below
res=matced64c('cedResetX');
res=0;
% uncomment this next line, if you get a -544 error later
% res=matced64c('cedWorkingSet',400,4000);
if (res > 0)
    disp('error with call to cedWorkingSet - try commenting it out');
    return
end   
% make data
x=1:datalength;
period=100;
z=round(scale*sin(x*2*pi/period));  % use a 16 bit range
address=1000;  % 1401 address
matced64c('cedTo1401',length(x),address,z);
% now get it back
z2=matced64c('cedToHost',length(x),address);
res=matced64c('cedCloseX');
dif=(z-z2);
error=find(dif~=0);
if (length(error) > 0)
    disp(['Differences: ' int2str(length(error)) ' max size: ' num2str(max(dif))]);
else
    disp(['No differences in ' int2str(datalength) ' data points']);
end    
