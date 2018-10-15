#!/bin/bash

#set FSL environment!
#for visually checking the brain mask on DTI images

list="/data/pt_life_dti/scripts/subjectlist_dti_2523"
results_dir="/data/pt_life_dti/mri"
reports_dir="/data/pt_life_dti/output"


mkdir -p $reports_dir/check_slices_t1_fa_md
rm -f $reports_dir/check_slices_t1_fa_md/quality_check_index.html

for subj in `cat ${list}`

do

echo "-----------------------------------"
echo "Creating slices check of ${subj}"
echo "-----------------------------------"

echo $subj
cd $results_dir/$subj
#make the slices of T1 brain images
if [ -f ${subj}_t1_pl.v ]; then
    for i in 50 60 70 80 90 100 110 120
    do
    echo $i

    slicer -L -e 0.0001 ${subj}_t1_pl.nii.gz -z -$i $reports_dir/check_slices_t1_fa_md/t1.$i.png
    done

    cd $reports_dir/check_slices_t1_fa_md

    ${FSLDIR}/bin/pngappend t1.50.png + t1.60.png + t1.70.png + t1.80.png + t1.90.png + t1.100.png + t1.110.png + t1.120.png $subj.t1.png
    rm -f t1*.png
    echo '<a href="'$subj'.t1.png"><img src="'$subj'.t1.png" >' $subj.t1.png'</a><br>' >> $reports_dir/check_slices_t1_fa_md/quality_check_index.html

    echo "slices t1 check done"
else
    echo "no T1"
fi


# #make the slices of eddy corrected data
# cd $results_dir/$subj
# if [ -f ${subj}_diff_ec.eddy_outlier_free_data.nii.gz ]; then
#     for j in 10 15 20 25 30 35 40 45 50 55
#     do
#     echo $j
# 
#     slicer -L -e 0.0001 ${subj}_diff_ec.eddy_outlier_free_data.nii.gz -z -$j $reports_dir/check_slices_eddy/ecc$j.png
#     done
#     cd $reports_dir/check_slices_eddy
# 
#     ${FSLDIR}/bin/pngappend ecc10.png + ecc15.png + ecc20.png + ecc25.png + ecc30.png + ecc35.png + ecc40.png + ecc45.png + ecc50.png + ecc55.png $subj.eddy.png
#     rm -f ecc*.png
#     echo '<a href="'$subj'.eddy.png"><img src="'$subj'.eddy.png" >' $subj.eddy.png'</a><br>' >> $reports_dir/check_slices_eddy/quality_check_index.html
# 
#     echo "slices eddy check done"
# else
#     echo "no eddy file"
# fi


#make the slices of FA images
cd $results_dir/$subj
if [ -f ${subj}_fa.nii.gz ]; then
    for k in 50 60 70 80 90 100 110 120
    do
    echo $k

    slicer -L -e 0.0001 ${subj}_fa.nii.gz -z -$k $reports_dir/check_slices_t1_fa_md/fa$k.png
    done

    cd $reports_dir/check_slices_t1_fa_md

    ${FSLDIR}/bin/pngappend fa50.png + fa60.png + fa70.png + fa80.png + fa90.png + fa100.png + fa110.png + fa120.png $subj.fa.png
    rm -f fa*.png
    echo '<a href="'$subj'.fa.png"><img src="'$subj'.fa.png" >' $subj.fa.png'</a><br>' >> $reports_dir/check_slices_t1_fa_md/quality_check_index.html

    echo "slices FA check done"
else
    echo "no FA"
fi

cd $results_dir/$subj
#make the slices of FA images
if [ -f ${subj}_fa.nii.gz ]; then
    for l in 50 60 70 80 90 100 110 120
    do
    echo $l

    slicer -L -e 0.0001 ${subj}_md.nii.gz -z -$l $reports_dir/check_slices_t1_fa_md/md$l.png
    done

    cd $reports_dir/check_slices_t1_fa_md

    ${FSLDIR}/bin/pngappend md50.png + md60.png + md70.png + md80.png + md90.png + md100.png + md110.png + md120.png $subj.md.png
    rm -f md*.png
    echo '<a href="'$subj'.md.png"><img src="'$subj'.md.png" >' $subj.md.png'</a><br>' >> $reports_dir/check_slices_t1_fa_md/quality_check_index.html

    echo "slices MD check done"
else
    echo "no MD"
fi


done

