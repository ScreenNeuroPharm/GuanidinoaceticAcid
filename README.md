GuanidinoaceticAcid

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/ScreenNeuroPharm/GuanidinoaceticAcid/blob/master/LICENSE)

> The repository contains the data and the functions needed to reproduce the analysis reported in the article "Lack of epileptogenic effects of the creatine precursor guanidinoacetic acid on neuronal cultures in vitro"


## Details
All uploaded scripts work with a .mat format. 
To reproduce our analysis is necessary to convert the ```.txt``` format file in ```.mat``` format file using the function ```TxT2Mat.m``` in the folder Conversion. 
All electrophysiological recordings are long 20 minutes and sampled at 10 KHz. 
```TxT2Mat.m``` function allows obtaining for each electrode (60) the peak train .mat file. 
Peak_train file is a sparse vector that reports the spike occur, saving the spike amplitudute.

### Code folder architecture:
- BurstAnalysis folder:
    * burstFeaturesAnalysis: functions to obtain the burst feautures
    * StringMethod: functions to detect the burst

- Conversion folder:
    * Txt2Mat: function to convert ```.txt``` format file in ```.mat``` format file

- SpikeAnalysis folder:
    * MFR: function to compute the Mean Firing Rate

- PSTH folder:
    * MAIN_psth: script computes the PSTH files from the PeakDetection MAT files
    * MainPSTHarea: Script for computing the PSTH area
    * computePSTH: Function for managing PSTH results
    * psth: Function for calculating the PSTH
    * uigetPSTHinfo2: Prompt a user-window for input information regarding the current experiment for computing PSTH


- Utilities: supplementary functions
