#!/bin/bash

#@author: zhang@cbs.mpg.de

## Prerequisits: FSL and FREESURFER
#
# Steps:
#  6. coregistration of ROIs from T1 segmentation to DTI

list="/data/pt_life_dti/output/DTI_x3_existing_subjects.txt"
results_dir="/data/pt_life_dti/mri"
free_dir="/data/pt_life_freesurfer/freesurfer_all"
reports_dir="/data/pt_life_dti/output"

rm -rf $reports_dir/HP_oldLabels_mean_MD
mkdir -p $reports_dir/HP_oldLabels_mean_MD

for j in posterior_left_CA1 posterior_left_CA2_3 posterior_left_CA4_DG posterior_left_fimbria posterior_left_hippocampal_fissure posterior_Left-Hippocampus posterior_left_presubiculum posterior_left_subiculum posterior_right_CA1 posterior_right_CA2_3 posterior_right_CA4_DG posterior_right_fimbria posterior_right_hippocampal_fissure posterior_Right-Hippocampus posterior_right_presubiculum posterior_right_subiculum 
do
echo $j
echo "SIC" "meanMD_${j}" >> $reports_dir/HP_oldLabels_mean_MD/$j.txt
done

# for subj in `sed -n 2p ${list}`
for subj in `cat ${list}`

do
echo "################################################"
echo "          Processing $subj"
echo "################################################"

if [ -f ${free_dir}/$subj/mri/posterior_left_CA1.mgz ]; then

    for i in posterior_left_CA1 posterior_left_CA2_3 posterior_left_CA4_DG posterior_left_fimbria posterior_left_hippocampal_fissure posterior_Left-Hippocampus posterior_left_presubiculum posterior_left_subiculum posterior_right_CA1 posterior_right_CA2_3 posterior_right_CA4_DG posterior_right_fimbria posterior_right_hippocampal_fissure posterior_Right-Hippocampus posterior_right_presubiculum posterior_right_subiculum 
    do
    echo $i

#     echo "Registeration of hippocampal subfields to DTI"
#     echo "---------------------------------------------"
# 
#     echo " - bring hippocampus subfields to orig.mgz Fov" #the subfield mgz is in different size
#     mri_label2vol --seg ${free_dir}/$subj/mri/$i.mgz --temp ${free_dir}/$subj/mri/orig.mgz --o $results_dir/$subj/rois/orig.$i.l2v.mgz --regheader ${free_dir}/$subj/mri/$i.mgz &>> $results_dir/$subj/check/log_x4_oldLables.txt
# 
#     echo " - apply the inverse of the matrix from $i to diffusion"
#     mri_vol2vol --mov  $results_dir/$subj/${subj}_fa.nii.gz --targ $results_dir/$subj/rois/orig.$i.l2v.mgz --o $results_dir/$subj/rois/orig.$i.2dti.nii.gz --reg $results_dir/$subj/rois/bbregister_fa_2_orig_bbr.dat --inv --nearest &>> $results_dir/$subj/check/log_x4_oldLables.txt
# 
#     echo " - creating hippocampal subfield masks"    
#     fslmaths $results_dir/$subj/rois/orig.$i.2dti.nii.gz -thr 150 -bin $results_dir/$subj/rois/orig.$i.2dti.nii.gz

    echo " - extracting MD values"    
    #extract median MD of each subfield and threshold out values below 0 and above 0.002
    a="`fslstats $results_dir/$subj/${subj}_md.nii.gz -k $results_dir/$subj/rois/orig.$i.2dti.nii.gz -l 0 -u 0.002 -m`"
    echo $subj $a >> $reports_dir/HP_oldLabels_mean_MD/$i.txt

    done

else
    echo 'Hippocampus subfield FS segmentation not done'
#     echo $subj >> $reports_dir/FS_HP_oldLabels_missing.txt
fi

done