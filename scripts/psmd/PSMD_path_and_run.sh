#!/bin/bash

#@author: zhang@cbs.mpg.de
# run under FSL enviornment
#for defining path in order to calculate PSMD and save the value in txt file

list="/data/pt_life_dti/scripts/psmd/subj_list.txt"
origdir="/data/pt_life_dti/mri"
scr_dir="/data/pt_life_dti/scripts/psmd"
outdir="/data/pt_life_dti/results/PSMD"


echo "SIC" "PSMD" > $outdir/psmd_all.txt

# for subject in `sed -n 5p ${list}`
for subject in `cat ${list}`

do 

#define input files

fa="$origdir/${subject}/${subject}_fa.nii.gz"
md="$origdir/${subject}/${subject}_md.nii.gz"

echo "----------------------------------------"
echo "Processing images of ${subject} for PSMD"
echo "----------------------------------------"

cd $origdir/$subject

if [ -f $fa ]; then
    #calculate PSMD
    sh $scr_dir/psmd.sh -f $fa -m $md -s $scr_dir/skeleton_mask.nii.gz

    #read the value from psmd report and write a final text files
    echo "Writing the result.."
    psmd=$(sed -n 2p $outdir/psmd_tmp.txt)
    echo $subject $psmd >> $outdir/psmd_all.txt
else
    echo "data missing"
fi

done

