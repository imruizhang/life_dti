Last Update: 27/09/2018 [dd/mm/year]

# Structure of Data in *pt_life_dti*
**This is for documentation of the structures of diffusion-weighted MRI data processed from LIFE study.**


Created and maintained by **Rui Zhang**

## Two Preprocessing pipeline

### 1. following **ENIGMA** DTI-pipeline

  located in the folder: *./mri_preprocessed_ENIGMA_pipeline*, more detail see README inside the folder.
      
### 2. New 2018 pipeline with **denoise, unring and Lipsia** tool

- *./mri/*: this is the folder contains images created during preprocessing
- *./psmd/*: contains R codes and files for the potential paper (ongoing project)
- *./output/*: outputs for quality check files, raw MD values, and subject lists to indicate whether one preprocessing step was done.
- *./QC_pdfs/*: created for machine learning project (ongoing) which aims to detect artefacts automatically 
- *./raw_restored/*: this contains some participants who did not have completed DWI scans in */a/project/life/patients*
- *./scripts/*: all scripts used for preprocessing, also accessible on [github](https://github.com/imruizhang/life_dti)

### *./results/* contains files could be used in the analysis. 
  For example, MD values of each hippocampal subfields in one merged file. Naming according to ENIGMA pipeline or 2018 Lipsia pipeline

### *./test/* contains files using for testing LIFE-followup preprocessings (can be deleted)
