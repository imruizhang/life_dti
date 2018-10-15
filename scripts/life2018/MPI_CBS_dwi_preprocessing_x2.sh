#!/bin/bash

#Implemented Dr. Alfred Anwander's PREPROCESSING pipeline
## Prerequisits: FSL enviornment
#
# Steps:
#  2. denoise dwi all images
#  3. unring on dwi b0 images
#  4. eddy outlier replacement

list="/data/pt_life_dti/output/DTI_x2_not_existing_subjects.txt"
orig_dir="/a/projects/life/patients"
results_dir="/data/pt_life_dti/mri"
reports_dir="/data/pt_life_dti/output"

#path for essential software
MRTRIXDIR="/a/software/mrtrix/3.0-rc1/ubuntu-xenial-amd64/bin"

for subj in LI03970978 #`cat ${list}`

# for subj in `sed -n 1,5p ${list}`
# for subj in `sed -n 6,10p ${list}`
# for subj in `sed -n 11,14p ${list}`
# for subj in `sed -n 16,20p ${list}`
# for subj in `sed -n 21,25p ${list}`

# for subj in `sed -n 26,30p ${list}`
# for subj in `sed -n 31,35p ${list}`
# for subj in `sed -n 36,40p ${list}`
# for subj in `sed -n 41,48p ${list}`
# for subj in `sed -n 46,50p ${list}`

# for subj in `sed -n 51,55p ${list}`
# for subj in `sed -n 56,59p ${list}`

do

cd $results_dir/$subj


echo "################################################"
echo "          Processing $subj"
echo "################################################"

echo "#-------------------------------------------------------------------------------#"
echo "#                   Preprocessing of diffusion MRI data:"
echo "#-------------------------------------------------------------------------------#"

# if [ -f ${subj}_diff_ec.eddy_outlier_free_data.nii.gz ]; then
# 
#     echo "eddy already done"
#     continue
# else
    #The preprocessing of the diffusion MRI data for TBSS/VBS and tractography contains the following steps:
    #dwi denosing on all images
    #unring on b0 images
    #motion correction and registration to the t1 anatomy (dmri_prepro.sh)
    #the t1 anatomy is required in the subject folder mr*_t1_pl.v.
    #fitting of a diffusion tensor and computation of FA images for quality check
    #Please check the original dMRI datasets (*diff_or.nii.gz) and the postprocessing results for artefacts (using vlv, fslview or fibernavigator)
    #conversion to the appropriate analysis tools : TBSS FSL-betpostx, MRTrix
    if [ -f ${subj}_mr_diff_or.nii.gz ]; then

        echo " -finding the raw data path"
        echo "-----------------------------------------"
        #copy the first in the list of scans found.. (supposingly they are all the same)
        first_dir=$(find $orig_dir/$subj -depth -name "DICOMDIR" | sort)
        set -- $first_dir
        dicmdir=$1
        echo $dicmdir &> $results_dir/$subj/check/log_x2.txt
        date=$(echo ${dicmdir:48:8})
        
        echo " -copying bval & bvec"
        echo "-----------------------------------------"
        rm -f ${subj}_dwi.bvec ${subj}_dwi.bval
        
        bval_name=$(find $orig_dir/$subj/${subj}_${date}*VER1/ -name *100.bval*)
        echo $bval_name &>> $results_dir/$subj/check/log_x2.txt
        cp $bval_name $results_dir/$subj/
        gunzip $results_dir/$subj/*.bval.gz -f #$results_dir/$subj/
        mv $results_dir/$subj/*.bval $results_dir/$subj/${subj}_dwi.bval

        #
        bvec_name=$(find $orig_dir/$subj/${subj}_${date}*VER1/ -name *100.bvec*)
        echo $bvec_name &>> $results_dir/$subj/check/log_x2.txt
        cp $bvec_name $results_dir/$subj/
        gunzip -f $results_dir/$subj/*.bvec.gz
        mv $results_dir/$subj/*.bvec $results_dir/$subj/${subj}_dwi.bvec

        ######preprocessing of raw images with dwi_denoise, b0_unring, eddy######
        echo " -denosing dwi images"
        echo " --------------------"
        #MRTRIX --version 3.0-rc1
        ${MRTRIXDIR}/dwidenoise ${subj}_mr_diff_or.nii.gz ${subj}_denoised.dwi.nii.gz -noise ${subj}_noise.nii.gz -force &>> $results_dir/$subj/check/log_x2.txt
        echo " -calculating residuals"
        echo " ----------------------"
        ${MRTRIXDIR}/mrcalc ${subj}_mr_diff_or.nii.gz ${subj}_denoised.dwi.nii.gz -subtract ${subj}_res.nii.gz -force &>> $results_dir/$subj/check/log_x2.txt

        ##unring only on b0-images (split nifti-files, do only on 0,11,22,33... merge all images again in same order)
        echo " -unringing dwi images"
        echo " ---------------------"

        echo "  --split dwi images" #split the dwi scans into separate images
        mkdir -p split
        fslsplit ${subj}_denoised.dwi.nii.gz split/${subj}_ -t
        
        if [ -f split/${subj}_0066.nii.gz ]; then

            for j in 0000 0011 0022 0033 0044 0055 0066
            do

            echo "  --unringing $j"
            /data/pt_life_dti/scripts/unring.a64 split/${subj}_${j}.nii.gz split/${subj}_${j}.nii.gz &>> $results_dir/$subj/check/log_x2.txt

            done

            echo "  --merge dwi images" #merge dwi images back to one file
            fslmerge -t ${subj}_unringed.dwi.nii.gz split/*.nii.gz

            echo "  --creating brain mask using bet"

            bet split/${subj}_0000.nii.gz ${subj}_b0_brain -R -m -f 0.2

            echo "  --cleaning up"
            rm -rf split/

            echo " -motion correction and outlier replacement with eddy"
            echo " ----------------------------------------------------"

            echo "  --creating acquisition parameters file"

                printf "0 1 0 0.06" > ${subj}_acqparams_dwi.txt
                    #--> Total readout time (FSL) = (number of echoes - 1) * echo spacing = (128/2-1)*0.95ms= 60 ms
                    #data was acquired with A>>P phase encoding

            echo "  --creating index file"
            indx=""; for ((i=1; i<=67; i+=1)); do indx="$indx 1"; done; echo $indx > ${subj}_index.txt

            echo "  --running eddy"
            #eddy replaces outliers (defined as <4sd) 
            export OMP_NUM_THREADS=30
            /data/pt_life_dti/scripts/eddy_openmp --imain=${subj}_unringed.dwi.nii.gz  --mask=${subj}_b0_brain_mask.nii.gz --bvecs=${subj}_dwi.bvec --bvals=${subj}_dwi.bval --out=${subj}_diff_ec --repol --cnr_maps --residuals -v --acqp=${subj}_acqparams_dwi.txt --index=${subj}_index.txt &>> $results_dir/$subj/check/log_x2.txt
            
            echo "  --cleaning up"
            rm -f ${subj}_denoised.dwi.nii.gz ${subj}_unringed.dwi.nii.gz

            echo "...done"
        else
            echo "dwi scans not complete"
            echo $subj >> $reports_dir/dwi_not_completed.txt
        fi

    else
        echo "dwi missing"
        echo $subj >> $reports_dir/dwi_missing_part1.txt
    fi
# fi

done
