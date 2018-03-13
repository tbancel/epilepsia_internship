clc; clear;
load('20141203_Mark_GAERS_Neuron_1047.mat')
signal = EEG.values;
dt = EEG.interval;
timevector = EEG.timevector;

ts = timeseries(signal, timevector);
% signalAnalyzer;
