#!/bin/bash

#Implemented Dr. Alfred Anwander's PREPROCESSING pipeline
#@author: zhang@cbs.mpg.de

## Prerequisits: FSL enviornment
#
# Steps:
#  1. convert t1 and dwi dicom to vista and nifti


#import the path of LIPSIA
export PATH=/a/sw/misc/linux/diffusion/:$PATH

list="/data/pt_life_dti/scripts/subjectlist_dti_2523"
list_add="/data/pt_life_dti/output/list_skull_wrong"
orig_dir="/a/projects/life/patients"
results_dir="/data/pt_life_dti/mri"
reports_dir="/data/pt_life_dti/output"
restored_dir="/data/pt_life_dti/raw_restored"

# for subj in `sed -n 2501,2523p ${list}`
#for subj in `cat ${list}`
for subj in `cat ${list_add}`
# for subj in `sed -n 1p ${list_add}`

do
echo "#--------------------------------------------------------------------------#"
echo "                      Processing $subj"
echo "#--------------------------------------------------------------------------#"
echo "Copying images from raw data"
echo " -creating folders"
echo " -----------------"

cd $results_dir
# Create data folder for each subj
mkdir -p ${subj}

cd $subj
#create folders for checking and results
mkdir -p check

#####copy and convert dicom to vista#####
#clean up files created by this step
echo " -cleaning up old files"
echo "-----------------------------------------"
rm -f ${subj}_mr_diff_or.v ${subj}_mr_t1_or.v
rm -f ${subj}_t1_pl.v ${subj}_t1_np.v 
rm -f cacp.txt tt.v
rm -f ${subj}_t1_pl.nii.gz ${subj}_t1_np.nii.gz ${subj}_mr_diff_or.nii.gz

echo $subj > $results_dir/$subj/check/log_x1.txt

echo " -finding the raw data path"
echo "-----------------------------------------"
#copy the first in the list of scans found.. (supposingly they are all the same)
first_dir=$(find $orig_dir/$subj -depth -name "DICOMDIR" | sort)
set -- $first_dir
dicmdir=$1
echo $dicmdir &>> $results_dir/$subj/check/log_x1.txt
echo $dicmdir &>> $results_dir/$subj/check/images_used.txt
date=$(echo ${dicmdir:48:8})
echo $date &>> $results_dir/$subj/check/log_x1.txt

echo " -converting DICOM images"
echo "-----------------------------------------"
for (( i=1; i<20; i++)); do dictov -in $dicmdir -out ${i}_tmp.v -prec original -scans $i &>> $results_dir/$subj/check/log_x1.txt; done


echo " -renaming images"
echo " ----------------"
t1_or=$(grep MPRAGE_ADNI_32Ch_PAT2 *_tmp.v -m 1 -a | awk -F:  '{ print $1}')
cp $t1_or ${subj}_mr_t1_tmp_or.v

vconvert ${subj}_mr_t1_tmp_or.v -map linear -a 0.8 -out ${subj}_mr_t1_vc_or.v &>> $results_dir/$subj/check/log_x1.txt
visotrop ${subj}_mr_t1_vc_or.v -reso 1 -out ${subj}_mr_t1_or.v &>> $results_dir/$subj/check/log_x1.txt
rm -f ${subj}_mr_t1_tmp_or.v ${subj}_mr_t1_vc_or.v

echo " -renaming dwi images"
echo "-----------------------------------------"
diff_or=$(grep -e ep2d_diff -e MPIL_DTI *_tmp.v -m 1 -a | awk -F:  '{ print $1}')
cp $diff_or ${subj}_mr_diff_or.v &>> $results_dir/$subj/check/log_x1.txt

            
# check whether there was diffusion scans and convert it to nifti
if [ -f ${subj}_mr_diff_or.v ]; then
    echo " -converting ${subj}_mr_diff_or.v to nifti"
    echo "-----------------------------------------"
    vimage2nifti ${subj}_mr_diff_or.v ${subj}_mr_diff_or.nii.gz
    
else
    if [ -f $restored_dir/${subj}*/Scans.txt ]; then
        echo "---taking DWI scans from $restored_dir---" &>> $results_dir/$subj/check/log_x1.txt
        echo " -converting DWI images from $restored_dir" 
        echo "-----------------------------------------"
        diff_or=$(grep -e ep2d_diff -e MPIL_DTI $restored_dir/${subj}*/Scans.txt | awk '{print $1=$1*1}')
        set -- $diff_or
        dictov -in $restored_dir/${subj}*/DICOMDIR -scans $1 -prec original -out ${subj}_mr_diff_or.v &>> $results_dir/$subj/check/log_x1.txt
        vimage2nifti ${subj}_mr_diff_or.v ${subj}_mr_diff_or.nii.gz

    else

        echo "dwi missing"
        echo "-----------------------------------------"
        echo $subj >> $reports_dir/dwi_dcm_missing.txt   

    fi
fi

#check whether t1 vista from dicom convertion exists, if not then go to the raw data restored location
if [ -f ${subj}_mr_t1_or.v ]; then
    
    echo "Preparing t1 images"
    # Compute location of midsagittal plane and ACPC coordinates
    echo " -computing location"
    echo "-----------------------------------------"
    vcacp -in ${subj}_mr_t1_or.v -template /a/sw/misc/linux/diffusion/bruker.v -out tt.v -report $results_dir/$subj/cacp.txt
    # Reorient T1 anatomie to ACPC coordinate system
    echo " -reorienting t1 images"
    echo "-----------------------------------------"
    vtal ${subj}_mr_t1_or.v ${subj}_t1_pl.v -type 0 `cat $results_dir/$subj/cacp.txt` &>> $results_dir/$subj/check/log_x1.txt
    vtal ${subj}_mr_t1_or.v ${subj}_t1_np.v -type 1 `cat $results_dir/$subj/cacp.txt` &>> $results_dir/$subj/check/log_x1.txt
    
    #if the last step was done correctly then convert the file format, otherwise use another version of vcacp to do the skull stripping
        #some subjects had bright T1 so the normal vcacp did not work properly
    if [ -f ${subj}_t1_np.v ]; then 
        # create nifit files
        echo " -converting ${subj}_t1 to nifti"
        echo "-----------------------------------------"
        vimage2nifti ${subj}_t1_pl.v ${subj}_t1_pl.nii.gz
        vimage2nifti ${subj}_t1_np.v ${subj}_t1_np.nii.gz

    else
        # Compute location of midsagittal plane and ACPC coordinates
        echo "---using vcacp.v1.6 for skull stripping---" &>> $results_dir/$subj/check/log_x1.txt
        echo " -computing location with vcacp.v1.6"
        echo "-----------------------------------------"
        vcacp.v1.6 -in ${subj}_mr_t1_or.v -template /a/sw/misc/linux/diffusion/bruker.v -out tt.v -report $results_dir/$subj/cacp.txt
        # Reorient T1 anatomie to ACPC coordinate system
        echo " -reorienting t1 images"
        echo "-----------------------------------------"
        vtal ${subj}_mr_t1_or.v ${subj}_t1_pl.v -type 0 `cut -c7- $results_dir/$subj/cacp.txt` &>> $results_dir/$subj/check/log_x1.txt
        vtal ${subj}_mr_t1_or.v ${subj}_t1_np.v -type 1 `cut -c7- $results_dir/$subj/cacp.txt` &>> $results_dir/$subj/check/log_x1.txt
        # create nifit files
        echo " -converting ${subj}_t1 to nifti"
        echo "-----------------------------------------"
        vimage2nifti ${subj}_t1_pl.v ${subj}_t1_pl.nii.gz
        vimage2nifti ${subj}_t1_np.v ${subj}_t1_np.nii.gz
    fi

else
    if [ -f $restored_dir/${subj}*/Scans.txt ]; then
        echo "---Taking T1 scans from $restored_dir---" &>> $results_dir/$subj/check/log_x1.txt
        echo " -converting T1 images from $restored_dir"
        echo "-----------------------------------------"
        t1_or=$(grep MPRAGE_ADNI_32Ch_PAT2 $restored_dir/${subj}*/Scans.txt | awk '{print $1=$1*1}')
        set -- $t1_or
        dictov -in $restored_dir/${subj}*/DICOMDIR -scans $1 -out ${subj}_mr_t1_tmp_or.v &>> $results_dir/$subj/check/log_x1.txt
        visotrop ${subj}_mr_t1_tmp_or.v -reso 1 -out ${subj}_mr_t1_or.v &>> $results_dir/$subj/check/log_x1.txt
        rm -f ${subj}_mr_t1_tmp_or.v
        
        echo "Preparing t1 images"
        # Compute location of midsagittal plane and ACPC coordinates
        echo " -computing location"
        echo "-----------------------------------------"
        vcacp -in ${subj}_mr_t1_or.v -template /a/sw/misc/linux/diffusion/bruker.v -out tt.v -report $results_dir/$subj/cacp.txt
        # Reorient T1 anatomie to ACPC coordinate system
        echo " -reorienting t1 images"
        echo "-----------------------------------------"
        vtal ${subj}_mr_t1_or.v ${subj}_t1_pl.v -type 0 `cat $results_dir/$subj/cacp.txt` &>> $results_dir/$subj/check/log_x1.txt
        vtal ${subj}_mr_t1_or.v ${subj}_t1_np.v -type 1 `cat $results_dir/$subj/cacp.txt` &>> $results_dir/$subj/check/log_x1.txt
        
        if [ -f ${subj}_t1_np.v ]; then
            # create nifit files
            echo " -converting ${subj}_t1 to nifti"
            echo "-----------------------------------------"
            vimage2nifti ${subj}_t1_pl.v ${subj}_t1_pl.nii.gz
            vimage2nifti ${subj}_t1_np.v ${subj}_t1_np.nii.gz
        else
            # Compute location of midsagittal plane and ACPC coordinates
            echo "---using vcacp.v1.6 for skull stripping---" &>> $results_dir/$subj/check/log_x1.txt
            echo " -computing location with vcacp.v1.6"
            echo "-----------------------------------------"
            vcacp.v1.6 -in ${subj}_mr_t1_or.v -template /a/sw/misc/linux/diffusion/bruker.v -out tt.v -report $results_dir/$subj/cacp.txt
            # Reorient T1 anatomie to ACPC coordinate system
            echo " -reorienting t1 images"
            echo "-----------------------------------------"
            vtal ${subj}_mr_t1_or.v ${subj}_t1_pl.v -type 0 `cut -c7- $results_dir/$subj/cacp.txt` &>> $results_dir/$subj/check/log_x1.txt
            vtal ${subj}_mr_t1_or.v ${subj}_t1_np.v -type 1 `cut -c7- $results_dir/$subj/cacp.txt` &>> $results_dir/$subj/check/log_x1.txt
            # create nifit files
            echo " -converting ${subj}_t1 to nifti"
            echo "-----------------------------------------"
            vimage2nifti ${subj}_t1_pl.v ${subj}_t1_pl.nii.gz
            vimage2nifti ${subj}_t1_np.v ${subj}_t1_np.nii.gz
        fi   
        
    else
        if [ -f $orig_dir/$subj/${subj}_${date}*VER1/DICOMDIR ]; then
            
            echo " -copying & converting T1 anat images"
            echo "-----------------------------------------"
            t1_or=$(grep MPRAGE_ADNI_32Ch_PAT2 *_tmp.v -m 1 -a | awk -F:  '{ print $1}')
            cp $t1_or ${subj}_mr_t1_tmp_or.v &>> $results_dir/$subj/check/log_x1.txt
            
            echo " -preparing t1 images to suitable contrast"
            echo "-----------------------------------------"
            vconvert ${subj}_mr_t1_tmp_or.v -map linear -a 0.7 -out ${subj}_mr_t1_vc_or.v &>> $results_dir/$subj/check/log_x1.txt
            visotrop ${subj}_mr_t1_vc_or.v -reso 1 -out ${subj}_mr_t1_or.v &>> $results_dir/$subj/check/log_x1.txt
            rm -f ${subj}_mr_t1_tmp_or.v ${subj}_mr_t1_vc_or.v
            
            echo "T1 brain extraction"
            # Compute location of midsagittal plane and ACPC coordinates
            echo " -computing location"
            echo "-----------------------------------------"
            vcacp -in ${subj}_mr_t1_or.v -template /a/sw/misc/linux/diffusion/bruker.v -out tt.v -report $results_dir/$subj/cacp.txt
            # Reorient T1 anatomie to ACPC coordinate system
            echo " -reorienting t1 images"
            echo "-----------------------------------------"
            vtal ${subj}_mr_t1_or.v ${subj}_t1_pl.v -type 0 `cat $results_dir/$subj/cacp.txt` &>> $results_dir/$subj/check/log_x1.txt
            vtal ${subj}_mr_t1_or.v ${subj}_t1_np.v -type 1 `cat $results_dir/$subj/cacp.txt` &>> $results_dir/$subj/check/log_x1.txt
            
            #if the last step was done correctly then convert the file format, otherwise use another version of vcacp to do the skull stripping
                #some subjects had bright T1 so the normal vcacp did not work properly
            if [ -f ${subj}_t1_np.v ]; then 
                # create nifit files
                echo " -converting ${subj}_t1 to nifti"
                echo "-----------------------------------------"
                vimage2nifti ${subj}_t1_pl.v ${subj}_t1_pl.nii.gz
                vimage2nifti ${subj}_t1_np.v ${subj}_t1_np.nii.gz

            else
                # Compute location of midsagittal plane and ACPC coordinates
                echo "---using vcacp.v1.6 for skull stripping---" &>> $results_dir/$subj/check/log_x1.txt
                echo " -computing location with vcacp.v1.6"
                echo "-----------------------------------------"
                vcacp.v1.6 -in ${subj}_mr_t1_or.v -template /a/sw/misc/linux/diffusion/bruker.v -out tt.v -report $results_dir/$subj/cacp.txt
                # Reorient T1 anatomie to ACPC coordinate system
                echo " -reorienting t1 images"
                echo "-----------------------------------------"
                vtal ${subj}_mr_t1_or.v ${subj}_t1_pl.v -type 0 `cut -c7- $results_dir/$subj/cacp.txt` &>> $results_dir/$subj/check/log_x1.txt
                vtal ${subj}_mr_t1_or.v ${subj}_t1_np.v -type 1 `cut -c7- $results_dir/$subj/cacp.txt` &>> $results_dir/$subj/check/log_x1.txt
                # create nifit files
                echo " -converting ${subj}_t1 to nifti"
                echo "-----------------------------------------"
                vimage2nifti ${subj}_t1_pl.v ${subj}_t1_pl.nii.gz
                vimage2nifti ${subj}_t1_np.v ${subj}_t1_np.nii.gz
            fi   
        else    
            echo "T1 missing"
            echo "-----------------------------------------"
            echo $subj >> $reports_dir/t1_dcm_missing.txt
        fi

    fi
fi

echo " -cleaning up"
echo "-----------------------------------------"
rm -f *_tmp.v


done
