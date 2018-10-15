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

# for subj in `sed -n 1,2p ${list}`
for subj in `cat ${list}`

do
echo "################################################"
echo "          Processing $subj"
echo "################################################"

# echo "hippocampal subfield mask via boundary based registeration" &> $results_dir/$subj/check/log_x4.txt
# echo "Registeration of hippocampal subfields to DTI"
# echo "---------------------------------------------"
# mkdir -p $results_dir/$subj/rois
# rm -f $results_dir/$subj/rois/*

# echo " - register FA to T1 FREESURFER orig.mgz using boundary based method"
# #define subjects' DIR for FREESURFER
# SUBJECTS_DIR="${free_dir}/"
# bbregister --s $subj --mov $results_dir/$subj/${subj}_fa.nii.gz --init-fsl --reg $results_dir/$subj/rois/bbregister_fa_2_orig_bbr.dat --t1 &>> $results_dir/$subj/check/log_x4.txt

# echo " - apply the inverse of the matrix from aseg.mgz to diffusion"
# mri_vol2vol --mov  $results_dir/$subj/${subj}_fa.nii.gz --targ ${free_dir}/$subj/mri/aseg.mgz --o $results_dir/$subj/rois/aseg.nii.gz --reg $results_dir/$subj/rois/bbregister_fa_2_orig_bbr.dat --inv --nearest &>> $results_dir/$subj/check/log_x4.txt
# 
# echo " - creating hippocampal subfield masks"
# # left & right hippocampus using labels
# ${FSLDIR}/bin/fslmaths $results_dir/$subj/rois/aseg.nii.gz -uthr 17 -thr 17 -bin $results_dir/$subj/rois/left_hippocampus.nii.gz
# ${FSLDIR}/bin/fslmaths $results_dir/$subj/rois/aseg.nii.gz -uthr 53 -thr 53 -bin $results_dir/$subj/rois/right_hippocampus.nii.gz

echo " - creating cerebral white matter masks"
# left & right hippocampus using labels
${FSLDIR}/bin/fslmaths $results_dir/$subj/rois/aseg.nii.gz -uthr 2 -thr 2 -bin $results_dir/$subj/rois/Left_Cerebral_White_Matter.nii.gz
${FSLDIR}/bin/fslmaths $results_dir/$subj/rois/aseg.nii.gz -uthr 41 -thr 41 -bin $results_dir/$subj/rois/Right_Cerebral_White_Matter.nii.gz



# echo " - bring hippocampus subfields to orig.mgz Fov" #the subfield mgz is in different size
# 
# if [ -f ${free_dir}/$subj/mri/lh.hippoAmygLabels-T1.v20.FSvoxelSpace.mgz ]; then
# 
#     for i in lh rh
#     do
#     echo $i
#     mri_label2vol --seg ${free_dir}/$subj/mri/$i.hippoAmygLabels-T1.v20.FS60.mgz --temp ${free_dir}/$subj/mri/orig.mgz --o $results_dir/$subj/rois/orig.$i.l2v_hippoAmygLabels.mgz --regheader ${free_dir}/$subj/mri/$i.hippoAmygLabels-T1.v20.FS60.mgz &>> $results_dir/$subj/check/log_x4.txt
# 
# 
#     echo " - apply the inverse of the matrix from $i to diffusion"
#     mri_vol2vol --mov  $results_dir/$subj/${subj}_fa.nii.gz --targ $results_dir/$subj/rois/orig.$i.l2v_hippoAmygLabels.mgz --o $results_dir/$subj/rois/orig.$i.hippoAmygLabels_2dti.nii.gz --reg $results_dir/$subj/rois/bbregister_fa_2_orig_bbr.dat --inv --nearest &>> $results_dir/$subj/check/log_x4.txt
# 
#     # rm -f $results_dir/$subj/rois/*.mgz
# 
#     echo " - creating hippocampal subfield masks"
#     #for pulling out the ROI of hippocampus using labels
#     echo "    -parasubiculum"
#     ${FSLDIR}/bin/fslmaths $results_dir/$subj/rois/orig.$i.hippoAmygLabels_2dti.nii.gz -uthr 203 -thr 203 -bin $results_dir/$subj/rois/$i.parasubiculum.nii.gz
# 
#     echo "    -presubiculum"
#     ${FSLDIR}/bin/fslmaths $results_dir/$subj/rois/orig.$i.hippoAmygLabels_2dti.nii.gz -uthr 204 -thr 204 -bin $results_dir/$subj/rois/$i.presubiculum.nii.gz
# 
#     echo "    -subiculum"
#     ${FSLDIR}/bin/fslmaths $results_dir/$subj/rois/orig.$i.hippoAmygLabels_2dti.nii.gz -uthr 205 -thr 205 -bin $results_dir/$subj/rois/$i.subiculum.nii.gz
# 
#     echo "    -CA1"
#     ${FSLDIR}/bin/fslmaths $results_dir/$subj/rois/orig.$i.hippoAmygLabels_2dti.nii.gz -uthr 206 -thr 206 -bin $results_dir/$subj/rois/$i.CA1.nii.gz
# 
#     echo "    -CA3"
#     ${FSLDIR}/bin/fslmaths $results_dir/$subj/rois/orig.$i.hippoAmygLabels_2dti.nii.gz -uthr 208 -thr 208 -bin $results_dir/$subj/rois/$i.CA3.nii.gz
# 
#     echo "    -CA4"
#     ${FSLDIR}/bin/fslmaths $results_dir/$subj/rois/orig.$i.hippoAmygLabels_2dti.nii.gz -uthr 209 -thr 209 -bin $results_dir/$subj/rois/$i.CA4.nii.gz
# 
#     echo "    -GC-DG"
#     ${FSLDIR}/bin/fslmaths $results_dir/$subj/rois/orig.$i.hippoAmygLabels_2dti.nii.gz -uthr 210 -thr 210 -bin $results_dir/$subj/rois/$i.GC-DG.nii.gz
# 
#     echo "    -HATA"
#     ${FSLDIR}/bin/fslmaths $results_dir/$subj/rois/orig.$i.hippoAmygLabels_2dti.nii.gz -uthr 211 -thr 211 -bin $results_dir/$subj/rois/$i.HATA.nii.gz
# 
#     echo "    -fimbria"
#     ${FSLDIR}/bin/fslmaths $results_dir/$subj/rois/orig.$i.hippoAmygLabels_2dti.nii.gz -uthr 212 -thr 212 -bin $results_dir/$subj/rois/$i.fimbria.nii.gz
# 
#     echo "    -mo_layer_HP"
#     ${FSLDIR}/bin/fslmaths $results_dir/$subj/rois/orig.$i.hippoAmygLabels_2dti.nii.gz -uthr 214 -thr 214 -bin $results_dir/$subj/rois/$i.mo_layer_HP.nii.gz
# 
#     echo "    -fissure"
#     ${FSLDIR}/bin/fslmaths $results_dir/$subj/rois/orig.$i.hippoAmygLabels_2dti.nii.gz -uthr 215 -thr 215 -bin $results_dir/$subj/rois/$i.fissure.nii.gz
# 
#     echo "    -HP_tail"
#     ${FSLDIR}/bin/fslmaths $results_dir/$subj/rois/orig.$i.hippoAmygLabels_2dti.nii.gz -uthr 226 -thr 226 -bin $results_dir/$subj/rois/$i.HP_tail.nii.gz
# 
#     done
# 
# else
#     echo 'Hippocampus subfield FS segmentation not done'
#     echo $subj >> $reports_dir/FS_HP_missing.txt
# fi

done