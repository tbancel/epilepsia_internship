# charpier-internship

Important things to remember:
- data format to describe so that script can run
- script description and output
- fake data input to test to be commited

Main functions and scripts description:


## Automatic seizure detection (find seizures):
`label_signal_one_feature.m` (offline analysis)

## Spike and wave position detection:
`seizure_analysis_rt.m` (online) calls `script_get_sw_epoch_m1.m`

For offline computation, call this function (offline)
To compute performance of algorithm, the script calls `sw_detection_perf.m` (very important function because it defines the performance of the algorithm)

## Closed loop stimulation:
- closed_loop.m : 

- record_baseline.m : use paradigm 7 (to be described). When it starts recording, it sends a TTL pulse from the Channel 6 of the AMPI clock. This TTL pulse is received by the CED and logged into Spike2. When it ends recording, it sends a TTL pulse from the Channel 7 of the AMPI clock to the CED.

TODO: add the spike2 config file to the .git so that it can be uploaded. And the description. Two computer are used.

- stimulate_line_length.m
Needs to anticipate connection to Master8 and compensate.
Queuing lag as well.

- parameter_file (TO DO)

- epoch_starts(i-1, 1) is the array needed to know where we are in time.


## Internship report and word documents:

- [My internship report](https://docs.google.com/document/d/19hcyojKGd4uzZ_uIo5cIF0tA5ga-aji2IAOFyNr467k/edit?usp=sharing)

- Full documentation [here](https://docs.google.com/document/d/1KSDnj4kaBZcaxWJyh2HyH4MV9eeVU_yVuVEYQM3cIAU/edit?usp=sharing)

- Oral presentation presenting my work [here](https://docs.google.com/presentation/d/1XjblCYBWI6oWqX6hjk8_wT908769XpEk8OyCmXUPEms/edit?usp=sharing)


## Schéma et fichiers compilés:
- spike 2 configuration
- exemple of signal with labelled seizures
- exemple of seizure with labelled spike and wave position

