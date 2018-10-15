#!/bin/bash

#@author: zhang@cbs.mpg.de
#Implemented Dr. Alfred Anwander's PREPROCESSING pipeline
## Prerequisits: FSL enviornment
#
# Steps:
#  5. tensor fitting


#import the path of LIPSIA
export PATH=/a/sw/misc/linux/diffusion/:$PATH

list="/data/pt_life_dti/scripts/subjectlist_dti_2523"
list_add="/data/pt_life_dti/output/list_skull_wrong"
results_dir="/data/pt_life_dti/mri"

# for subj in LI03970978 #`cat ${list}`
# for subj in `sed -n 1p ${list}`
# for subj in `sed -n 1,500p ${list}`
# for subj in `sed -n 501,1000p ${list}`
# for subj in `sed -n 1001,1500p ${list}`
# for subj in `sed -n 1501,2000p ${list}`
# for subj in `sed -n 2001,2523p ${list}`

for subj in `cat ${list_add}`
# for subj in `sed -n 1p ${list_add}`

do

cd $results_dir/$subj

echo "#------------------------------------------------------------------------------#"
echo "#            Preprocessing of diffusion MRI data on $subj:"
echo "#------------------------------------------------------------------------------#"

#The preprocessing of the diffusion MRI data for TBSS/VBS and tractography contains the following steps:
#dwi denosing on all images
#unring on b0 images
#motion correction and registration to the t1 anatomy (dmri_prepro.sh)
#the t1 anatomy is required in the subject folder mr*_t1_pl.v.
#fitting of a diffusion tensor and computation of FA images for quality check
#Please check the original dMRI datasets (*diff_or.nii.gz) and the postprocessing results for artefacts (using vlv, fslview or fibernavigator)
#conversion to the appropriate analysis tools : TBSS FSL-betpostx, MRTrix
  

if [ -f ${subj}_diff_ec.eddy_outlier_free_data.nii.gz ]; then

    echo " -preparing dwi data for next steps"
    echo " ----------------------------------"
    #eddy output is float format and radiological convention, needed to convert to short format.    
    fslmaths ${subj}_diff_ec.eddy_outlier_free_data.nii.gz ${subj}_diff_outlier_free_short.nii.gz -odt short
    #or vconvert subj_replace_outliers.v -map copy -out subj_test.v -repn short
    vnifti2image ${subj}_diff_outlier_free_short.nii.gz ${subj}_replace_outliers.v

    #use header from diff_or.v to replace_outliers.v
    v2anatomist.pl ${subj}_replace_outliers.v &>> $results_dir/$subj/check/log_x3.txt #separate header and image
    v2anatomist.pl ${subj}_mr_diff_or.v &>> $results_dir/$subj/check/log_x3.txt

    cp ${subj}_replace_outliers.ima ${subj}_diff_corrected.ima
    cp ${subj}_mr_diff_or.hea ${subj}_diff_corrected.hea

    anatomist2v.pl ${subj}_diff_corrected.ima ${subj}_diff_corrected.hea &>> $results_dir/$subj/check/log_x3.txt

    echo " -cleaning up"
    echo " ------------"
    rm -f *.ima *.hea
#     rm -f ${subj}_diff_outlier_free_short.nii.gz ${subj}_replace_outliers.v

    if [ -f ${subj}_t1_pl.v ]; then
        echo "#------------------------------------------------------------------------------#"
        echo "#               Motion correction and tensor fitting on $subj:"
        echo "#------------------------------------------------------------------------------#"
        # Step 2: Motion correction and registration
        # Motion correction and registration
        echo " -Motion correction using flirt ${subj} ..."
        echo " --------------------------------------------"
        vdmoco -in ${subj}_diff_corrected.v -out ${subj}_trans.v

        # %_trans_t2_t1.v: %_t2_or.v %_t1.v
        echo " -T2- and T1-weighted MR image registration ..."
        echo " ----------------------------------------------"
        vselect -in ${subj}_diff_corrected.v -type image ${subj}_diff_corrected_tmp.v &>> $results_dir/$subj/check/log_x3.txt
        vselect ${subj}_diff_corrected_tmp.v -object 0 ${subj}_diff_b0.v &>> $results_dir/$subj/check/log_x3.txt

        rm -f ${subj}_diff_corrected_tmp.v

        vconvert ${subj}_diff_b0.v -repn ubyte -map copy -out ${subj}_diff_b0_ubyte_cp.v &>> $results_dir/$subj/check/log_x3.txt
        vdreg ${subj}_diff_b0_ubyte_cp.v -ref ${subj}_t1_pl.v -cost mutualinformation -out ${subj}_trans_diff_t1_pl.v &>> $results_dir/$subj/check/log_x3.txt
#         echo "##############################" &>> $results_dir/$subj/check/log_x3.txt
#         echo "redo tensor fitting" &>> $results_dir/$subj/check/log_x3.txt
#         echo "##############################" &>> $results_dir/$subj/check/log_x3.txt
        

        # Step 3: Averaging
        echo " -Averaging ${subj}_diff.v ..."
        echo " --------------------------------"
        vscale3d -in ${subj}_t1_pl.v -xscale 0.5818181818 -yscale 0.5818181818 -zscale 0.5818181818 ${subj}_t1_pl_scale.v &>> $results_dir/$subj/check/log_x3.txt

        vattredit ${subj}_t1_pl_scale.v -name voxel -value "1.71875 1.71875 1.71875" -obj -1 -out ${subj}_t1_1.71875mm.v &>> $results_dir/$subj/check/log_x3.txt

        rm -f ${subj}_t1_pl_scale.v

        vdapplymoco -in ${subj}_diff_corrected.v -out ${subj}_diff.v -trans ${subj}_trans.v -ref ${subj}_t1_1.71875mm.v -reftrans ${subj}_trans_diff_t1_pl.v -average on &>> $results_dir/$subj/check/log_x3.txt

        echo " -Averaging ${subj}_diff_1mm.v ..." #applying motion correction at 1mm improves sampling and reduces partial voluming
        echo " ---------------------------------------"
        vdapplymoco -in ${subj}_diff_corrected.v -out ${subj}_diff_1mm.v -trans ${subj}_trans.v -ref ${subj}_t1_pl.v -reftrans ${subj}_trans_diff_t1_pl.v -average on &>> $results_dir/$subj/check/log_x3.txt


        # Step 4: Tensor model fitting and get anatomy/dwi mask
        echo " -Diffusion tensor ${subj}_dti_1_7mm.v ..."
        echo " ---------------------------------------------"
        vdtensor -in ${subj}_diff.v -mask ${subj}_t1_1.71875mm.v -select fa ${subj}_diff_tmp.v &>> $results_dir/$subj/check/log_x3.txt

        vbinarize ${subj}_diff_tmp.v -min 0.00001 ${subj}_diff_tmp2.v &>> $results_dir/$subj/check/log_x3.txt

        vconvert ${subj}_diff_tmp2.v -map linear ${subj}_diff_tmp3.v &>> $results_dir/$subj/check/log_x3.txt

        vop ${subj}_diff_tmp3.v -op mult -image ${subj}_t1_1.71875mm.v -out ${subj}_dti_1_7mm.v &>> $results_dir/$subj/check/log_x3.txt

        rm -f ${subj}_t1_1.71875mm.v ${subj}_diff_tmp*.v
        mv ${subj}_dti_1_7mm.v ${subj}_t1_1.71875mm.v

        echo " -Diffusion tensor ${subj}_dti.v ..."
        echo " ---------------------------------------"
        vdtensor -in ${subj}_diff_1mm.v -mask ${subj}_t1_pl.v -out ${subj}_dti_all.v -select all &>> $results_dir/$subj/check/log_x3.txt

        vselect -attr component_interp dti                   	   ${subj}_dti_all.v ${subj}_dti.v
        vselect -attr component_interp fractional_anisotropy 	   ${subj}_dti_all.v ${subj}_fa.v
        vselect -attr component_interp fa_rgb                	   ${subj}_dti_all.v ${subj}_fa_rgb.v
        vselect -attr component_interp fa_rgb_mask           	   ${subj}_dti_all.v ${subj}_dti_rgb.v
        vselect -attr component_interp axial_diffusivity_l1_eval_1 ${subj}_dti_all.v ${subj}_l1.v
        vselect -attr component_interp radial_diffusivity_l23      ${subj}_dti_all.v ${subj}_l23.v
        vselect -attr component_interp mean_diff                   ${subj}_dti_all.v ${subj}_md.v
        vselect -attr component_interp b0_reference                ${subj}_dti_all.v ${subj}_b0.v

        rm -f ${subj}_dti_all.v

        vdtensor -in ${subj}_diff_1mm.v -mask ${subj}_t1_pl.v -fa_min 0.05 -out ${subj}_evec.v -select evec1 &>> $results_dir/$subj/check/log_x3.txt
        vdtensor -in ${subj}_diff_1mm.v -mask ${subj}_t1_pl.v  -out trace.v -select dwi_trace &>> $results_dir/$subj/check/log_x3.txt

        gzip -f ${subj}_diff_1mm.v ${subj}_diff_corrected.v


        vimage2nifti ${subj}_fa.v ${subj}_fa.nii.gz
        vimage2nifti ${subj}_l1.v ${subj}_l1.nii.gz
        vimage2nifti ${subj}_l23.v ${subj}_l23.nii.gz
        vimage2nifti ${subj}_md.v ${subj}_md.nii.gz
        vimage2nifti ${subj}_b0.v ${subj}_b0.nii.gz
        vrgb2nifti ${subj}_evec.v ${subj}_evec.nii.gz
        vrgb2nifti ${subj}_fa_rgb.v ${subj}_fa_rgb.nii.gz
        vrgb2nifti ${subj}_dti_rgb.v ${subj}_dti_rgb.nii.gz

        # FSL MRtrix preprocessing
        mkdir -p fsl
        vd2fsl.sh ${subj}_diff.v ${subj}_t1_1.71875mm.v fsl/ &>> $results_dir/$subj/check/log_x3.txt

        # Compute fibers with MedINRIA  (/scr/arsenic1/MedINRIA_1.6/MedINRIA.sh)
        MedINRIA_1.8.sh -mod dtitrack -dts fsl/MyStudy.dts -est -track -save &>> $results_dir/$subj/check/log_x3.txt
        mv fsl/MyStudy_fibers.fib ${subj}_fibers.fib

        echo "...done"
    else
        echo "t1 brain missing" &>> $results_dir/$subj/check/log_x3.txt
        continue
    fi    
    
else
    echo "eddy corrected file missing" &>> $results_dir/$subj/check/log_x3.txt
fi


done
