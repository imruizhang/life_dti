#!/bin/bash

#set FSL environment!
#for visually checking the quality of processed images
list="/data/pt_life_dti/scripts/subjectlist_dti_2523"
results_dir="/data/pt_life_dti/mri"
reports_dir="/data/pt_life_dti/output"

for subj in `cat ${list}`
# for subj in `sed -n 1p ${list}`

do


    mkdir -p $reports_dir/QC_errormap

    echo "-----------------------------------"
    echo "Creating slices check of ${subj}"
    echo "-----------------------------------"

    echo $subj

    cd $results_dir/$subj

    for i in 10 15 20 25 30 35 40 45 50 55
    do
    echo $i

    slicer -L -e 0.0001 ${subj}_diff_ec_sumofsquares.nii.gz -z -$i $reports_dir/QC_errormap/diff.$i.png
    done

    cd $reports_dir/QC_errormap

    ${FSLDIR}/bin/pngappend diff.10.png + diff.15.png + diff.20.png + diff.25.png + diff.30.png + diff.35.png + diff.40.png + diff.45.png + diff.50.png + diff.55.png $subj.diff.png
    rm -f diff*.png
    echo '<a href="'$subj'.diff.png"><img src="'$subj'.diff.png" >' $subj.diff.png'</a><br>' >> $reports_dir/QC_errormap/quality_check_index.html

    echo "slices diff check done"
    


done

