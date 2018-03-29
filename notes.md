# General Remarks Lab:

> all mark's recordings are on the server
> the annoted recordings with seizure manual labelling are on Mark's desktop computer but I now have them
> the idea is to take Mark's annoted recording and make the algo run.

=> we need to import those files to matlab

1. Define a uniform spike2export structure which will be saved under the .mat file (try to do some obj programming in Matlab)
2. Define way to load the .mat file and analyze it


## How to predict crisis on a raw recording.

A recording is a .mat file containing a variable called 'data'. data is a structure with some mandatory and optional fields:

- filename : a string which identifying the recording, the date etc. (eg: 20141203_Mark_GAERS_Neuron_1047.mat)
- values (1xN vector containing the time series of the S1 EEG)
- timevector (1xN vector containing the timestamps of the)
- interval : floating number which the sampling time interval

Optional fields:
- seizure_info : a Nx2 matrix where each line represents the start and the end of a seizure
- puffs : a 1xN


## list of routines that should work :

1. Converting spike2 files into exploitable matlab structures

2. Label a row recording using several methods:

3. 

## list of availables methods

1. predict_seizures_line_length_baseline
2. predict_seizures_norm_line_length_threshold
3. predict_seizures_line_length_baseline

