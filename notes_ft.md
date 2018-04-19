Notes Fieldtrip EEG:

- ft_checkconfig(cfg.source, 'dataset2files', 'yes') => returns a structure with the info of the type of the file

idem with the target, headerformat and dataformat = fcdc_buffer

hdr is a structure contaning:
- Fs
- nChans
- nSamples
- nSamplesPre
- nTrials
- orig (structure containting dataformat, dataorientiation, binaryformat, label, samplinginterval, etc.)
- chantype
- chanunit

ft_write_data(cfg.target.datafile, dat, 'header', hdr, 'dataformat', cfg.target.dataformat, 'chanindx', chanindx, 'append', false);


