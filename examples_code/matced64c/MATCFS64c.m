% MATCFS64c.m
% routines to access cfs files from Matlab 6.x, 7.x
% code switching originally by Mario Ringach
% by JG Colebatch v.1 32 bit Nov 2005 read only
% 12 Feb 2009 finished write routines.
% 06 Oct 2014 64 bit version
% other mods required due to Matlab using double as standard
% see CFS Filing System guide from CED Ltd  www.ced.co.uk
%
%  general usage:
%          [ret]=matcfs64c('cmd',[opt1],[opt2],[opt3]);
%  
%   varType: 2=INT2, 3=WRD2, 4=INT4, 5=RL4, 6=RL8 (may be required)
% 
% cfsOpenFile - returns cfs filehandle or error thus:
%      handle=matcfs64c('cfsOpenFile',fname,enableWrite,memoryTable);
% cfsCreateCFSFile - returns cfs filehandle or error:
%      handle=matcfs64c('cfsCreateCFSFile',fName, comment, blockSize, channels, fileVars, DSVars,(DSVAindex));
%            - do not send address of FV or DS array, just number of them
%           - DSVAindex (optional) - 0 or 1 - sets lower or upper DSVArray
% cfsSetVarDesc - sets FV or DS variable descriptions
%       - must call before calling cfsCreateCFSFile
%      matcfs64c('cfsSetVarDesc',handle, varNo, varKind, varSize, varType, units, description,(DSVAindex));
%       DSVAindex - optional 0 or 1 - sets upper part of DSVarray
% cfsSetVarVal - sets value of FV or DS variable
%       matcfs64c('cfsSetVarVal',handle,varNo,varKind,dataSection,value,(DSVAindex));
%       DSVAindex - optional 0 or 1 - sets upper part of DSVarray
% cfsSetFileChan - sets file channel variables
%      matcfs64c('cfsSetFileChan',handle, channel, chName, yUnits, xUnits, dataType, dataKind, spacing, other);
% cfsWriteData - writes a dataSection of data 0=no error
%     [errNo]=matcfs64c('cfsWriteData',handle,dataSection,startOffset,dType,array);
%      INT1 and WRD1 are not supported
% cfsInsertDS - closes current DS, sets flags  0=no error
%    [errNo]=matcfs64c('cfsInsertDS',handle,dataSection, flagSet);
% cfsRemoveDS - unlinks a dataSection
%     matcfs64c('cfsRemoveDS',handle,dataSection);
% cfsClearDS - removes DS and recovers space 0=no error
%     [errNo]=matcfs64c('cfsClearDS',handle);
% cfsSetComment - change comment (max 72 characters)
%     matcfs64c('cfsSetComment', handle, comment);
% cfsCloseFile - closes file and returns 0 if successful, thus: 
%     ret= matcfs64c('cfsCloseFile', handle);
% cfsGetGenInfo - returns time and date of file creation, plus comment
%      [time,date,comment]=matcfs64c('cfsGetGenInfo',handle);
% cfsGetFileInfo - returns no. of: chan,fileVars, DSVars and dataSections
%   [channels,fileVars,DSVars,dataSections]=matcfs64c('cfsGetFileInfo',handle);                                                
% cfsGetVarDesc- reads file variables and datasection variables
%   [varSize,varType,varUnits,varDesc]=matcfs64c('cfsGetVarDesc',handle,varNo,varKind);
% cfsGetVarVal - gets value of file or DSect variable
%   [varValue]=matcfs64c('cfsGetVarVal',handle,varNo,varKind,dataSection,varType);
%                         n.b. must specify varType
% cfsGetFileChan - gets constant information for each channel
%    [channelName,yUnits,xUnits,dataType,dataKind,spacing,other]=matcfs64c('cfsGetFileChan',handle,channel);
% cfsGetDSChan - reads channel information for specific channel and datasection
%    [startOffset,points,yScale,yOffset,xScale,xOffset]=matcfs64c('cfsGetDSChan',handle,channel,dataSection);
% cfsGetChanData- gets channel data points
%    [chanData]=matcfs64c('cfsGetChanData',handle,channel,dataSection,firstElement,numElements,varType);
%                             note: 0 for numElements is not supported
% cfsGetDSSize - disk space required
%    [size]=matcfs64c('cfsGetDSSize',handle,dataSection);
% cfsReadData - returns data (channels intermixed)
%   [data]= matcfs64c('cfsReadData',handle,dataSection,startOffset,points,
%        dataType, (no of chan));  
%                           (no of chan) optional, if set points=pts per chan
% cfsDSFlagValue returns value corresponding to flag
%       [value]=matcfs64c('cfsDSFlagValue',nflag);
% cfsDSFlags reads flags set
%       [flagSet]=matcfs64c('cfsDSFlags', handle, dSect, setit);  % setit = 0 to read
%       [flagSet]=matcfs64c('cfsDSFlags', handle, dSect, setit, flagSet); % = 1 to write - returns value
% cfsCommitCFSFile - writes headers to disk
%       [ret]=matcfs64c('cfsCommitCFSFile',handle);
% cfsFileError
%       [errStatus,handleNo,procNo,errNo]=matcfs64c('cfsFileError');
%           errStatus = 1 if error,since last call, 0 if not
%           handleNo,procNo,errNo - see CFS manual
% cfsFileSize returns file size in bytes
%       size=matcfs64c('cfsFileSize',fhandle);