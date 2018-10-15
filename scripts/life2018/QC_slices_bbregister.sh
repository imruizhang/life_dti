#!/bin/bash

#set FSL environment!
#for visually checking the brain mask on DTI images

list="/data/pt_life_dti/scripts/subjectlist_dti_2523"
results_dir="/data/pt_life_dti/mri"
reports_dir="/data/pt_life_dti/output"


mkdir -p $reports_dir/check_slices_bbregister
rm -f $reports_dir/check_slices_bbregister/check_index.html

for subj in `cat ${list}`

do

echo "-----------------------------------"
echo "Creating slices check of ${subj}"
echo "-----------------------------------"

echo $subj
cd $results_dir/$subj/rois

#make the slices of bb brain images
if [ -f Left_Cerebral_White_Matter.nii.gz ]; then

    fslmaths Left_Cerebral_White_Matter.nii.gz -add Right_Cerebral_White_Matter.nii.gz bin_cerebral_WM.nii.gz
    
    for i in 50 60 70 80 90 100 110 120
    do
    echo $i

    slicer -L -e 0.0001 ../${subj}_fa.nii.gz bin_cerebral_WM.nii.gz -z -$i $reports_dir/check_slices_bbregister/bb.$i.png
    done

    cd $reports_dir/check_slices_bbregister

    ${FSLDIR}/bin/pngappend bb.50.png + bb.60.png + bb.70.png + bb.80.png + bb.90.png + bb.100.png + bb.110.png + bb.120.png $subj.bb.png
    rm -f bb*.png
    echo '<a href="'$subj'.bb.png"><img src="'$subj'.bb.png" >' $subj.bb.png'</a><br>' >> $reports_dir/check_slices_bbregister/check_index.html

    echo "slices bbregister check done"
else
    echo "no white matter mask"
fi



done

