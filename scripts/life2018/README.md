## This is the preprocessing pipeline implemented Lipsia (MPI in-house tool) for LIFE data

### Preprocessing steps:
#### Note: The diffusion-weighted imaging in LIFE Study was done using the twice-refocused spin-echo

1. convert dicom to vista format, note:
	- few subjects had two visits during the study, the first one was taken
	- few subjects' data were restored from archive due to file damage
	- about 100 subjects were scanned with different protocol of DWI	
3. skull stripping
2. eddy outliers replacement
	- quality check for ghost artifact (or other errors) using sum of square errors map produced by eddy
4. motion correction 
	- all steps were done with Lipsia pipeline
2. b0 and T1 co-registration, DWI upsampled to 1mm 
5. tensor fitting
	- lipsia pipeline, included preprocessing data for tractography

	
