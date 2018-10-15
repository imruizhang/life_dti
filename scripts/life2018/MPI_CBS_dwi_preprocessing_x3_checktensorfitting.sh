#!/bin/bash

list="/data/pt_life_dti/output/DTI_x3_existing_subjects.txt"
reports_dir="/data/pt_life_dti/output"
results_dir="/data/pt_life_dti/mri"

echo "SIC" "total_vol" "diff_directions" "b0s" > $reports_dir/check_tensorfitting.txt

for subj in `cat ${list}`
do

echo $subj

cd $results_dir/$subj/check

#total objects recognised by Lipsia, usually 61 because Lipsia drops b0s, only the 1st b0 remains
all_vol=$(grep -e "diffusion objects with" log_x3.txt | head -1 | awk '{ print $1}')

#total diffusion directions in the header
diff_num=$(grep -e "diffusion objects with" log_x3.txt | head -1 | awk '{ print $5}')

#total b0s, should be 1 if it is correct
b0s=$(grep -e "diffusion objects with" log_x3.txt | head -1 | awk '{ print $8}')

echo $subj $all_vol $diff_num $b0s >> $reports_dir/check_tensorfitting.txt

done