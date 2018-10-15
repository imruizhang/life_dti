#!/bin/bash

#Implemented Dr. Alfred Anwander's PREPROCESSING pipeline
## Prerequisits: FSL enviornment
#
# Steps:
#  2. denoise dwi all images
#  add calculate sum of square errors from eddy residuals map

list="/data/pt_life_dti/scripts/subjectlist_dti_2523"
orig_dir="/a/projects/life/patients"
results_dir="/data/pt_life_dti/mri"
reports_dir="/data/pt_life_dti/output"


# for subj in `cat ${list}`

# for subj in `sed -n 351,500p ${list}`
# for subj in `sed -n 851,1000p ${list}`
# for subj in `sed -n 1351,1500p ${list}`
for subj in `sed -n 1952,2000p ${list}`
do

cd $results_dir/$subj


echo "################################################"
echo "          Processing $subj"
echo "################################################"

echo "#-------------------------------------------------------------------------------#"
echo "#                   Preprocessing of diffusion MRI data:"
echo "#-------------------------------------------------------------------------------#"


if [ -f ${subj}_mr_diff_or.nii.gz ]; then

    echo "  -calculating sum of square errror maps"
    echo " ----------------------------------------------------"

    echo "  --split dwi images"
    mkdir -p split
    fslsplit ${subj}_diff_ec.eddy_residuals.nii.gz split/ -t

    for j in 0000 0011 0022 0033 0044 0055 0066
    do

        echo "  --remove $j"
        rm -f split/${j}.nii.gz

    done

    echo "  --merge b1000 without b0 images" #merge dwi images back to one file
    fslmerge -t ${subj}_diff_ec_b1000_residuals.nii.gz split/*.nii.gz
    
    echo "  --calculate sum of square errors"
    fslmaths ${subj}_diff_ec_b1000_residuals.nii.gz -sqr -Tmean ${subj}_diff_ec_sumofsquares.nii.gz #mean=sum/number of images
    
    echo "  --cleaning up"
    rm -rf split/

else
    echo "dwi missing"
fi

done
