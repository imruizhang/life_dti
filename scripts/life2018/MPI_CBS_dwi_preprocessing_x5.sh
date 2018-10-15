#!/bin/bash

#@author: zhang@cbs.mpg.de

## Prerequisits: FSL and FREESURFER
#
# Steps:
#  6. coregistration of ROIs from T1 segmentation to DTI

list="/data/pt_life_dti/output/DTI_x3_existing_subjects.txt"
results_dir="/data/pt_life_dti/mri"
reports_dir="/data/pt_life_dti/output"

# mkdir -p $reports_dir/Hippocampus_MD
mkdir -p $reports_dir/FA

for subj in `cat ${list}`
# for subj in `sed -n 1,2p ${list}`

do
echo "################################################"
echo "          Processing $subj"
echo "################################################"

# if [ -f $results_dir/$subj/rois/orig.lh.hippoAmygLabels_2dti.nii.gz ]; then
# echo "Getting Mean MD of the subfields"
# 
# for i in lh.parasubiculum lh.presubiculum lh.subiculum lh.CA1 lh.CA3 lh.CA4 lh.GC-DG lh.HATA lh.fimbria lh.mo_layer_HP lh.fissure lh.HP_tail rh.parasubiculum rh.presubiculum rh.subiculum rh.CA1 rh.CA3 rh.CA4 rh.GC-DG rh.HATA rh.fimbria rh.mo_layer_HP rh.fissure rh.HP_tail
# do
# echo  "  --"$i
# 
# a="`fslstats $results_dir/${subj}/${subj}_md.nii.gz -k $results_dir/${subj}/rois/$i.nii.gz -m`"
# 
# echo $subj $a >> $reports_dir/Hippocampus_MD/HP_subfields_mean_md_$i.txt
# 
# done
# 
# else
#     echo 'Hippocampus subfield FS segmentation not done'
# fi

# if [ -f $results_dir/$subj/rois/aseg.nii.gz ]; then
# echo "Getting Mean MD of the hippocampus"
# 
# for i in left_hippocampus right_hippocampus
# do
# echo  "  --"$i
# 
# a="`fslstats $results_dir/${subj}/${subj}_md.nii.gz -k $results_dir/${subj}/rois/$i.nii.gz -m`"
# 
# echo $subj $a >> $reports_dir/Hippocampus_MD/HP_mean_md_$i.txt
# 
# done
# 
# else
#     echo 'FREESURFER segmentation not done'
# fi

if [ -f $results_dir/$subj/rois/aseg.nii.gz ]; then
echo "Getting Mean FA of Cerebral_White_Matter"

for i in Left_Cerebral_White_Matter Right_Cerebral_White_Matter
do
echo  "  --"$i

a="`fslstats $results_dir/${subj}/${subj}_fa.nii.gz -k $results_dir/${subj}/rois/$i.nii.gz -m`"

echo $subj $a >> $reports_dir/FA/mean_FA_$i.txt

done

else
    echo 'FREESURFER segmentation not done'
fi

done