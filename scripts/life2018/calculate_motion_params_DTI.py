# -*- coding: utf-8 -*-
"""
Created on Thu Mar  9 15:57:47 2017

@author: fbeyer
"""

#from compute_fd import compute_fd
import sys
import os
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

#FUNCTION DEFINITION
def compute_fd(motpars):

    # compute absolute displacement
    dmotpars=np.zeros(motpars.shape)
    
    dmotpars[1:,:]=np.abs(motpars[1:,:] - motpars[:-1,:])
    
    # convert rotation to displacement on a 50 mm sphere
    # mcflirt returns rotation in radians
    # from Jonathan Power:
    #The conversion is simple - you just want the length of an arc that a rotational
    # displacement causes at some radius. Circumference is pi*diameter, and we used a 50mm
    # radius. Multiply that circumference by (degrees/360) or (radians/2*pi) to get the 
    # length of the arc produced by a rotation.
    
    #SUITABLE for mcflirt-output
    #[0:3]-> rotational parameters
    #[3:6]-> translational paramters
    #SWAP ORDER FOR AFNI
    headradius=50
    disp=dmotpars.copy()
    disp[:,0:3]=np.pi*headradius*2*(disp[:,0:3]/(2*np.pi))
    
    FD=np.sum(disp,1)
    
    return FD

fname='/data/pt_life_dti/output/DTI_x2_existing_subjects.txt'
#'/data/pt_nro148/7T/DTI/all_78_DWI_subjects_9.5.txt'
#"/data/pt_nro148/3T/DTI/available_subjects_110_BL_and_FU.txt"
with open(fname, 'r') as f:
    subjects = [line.strip() for line in f]
  

#subjects=['LI00000031'] 
#subjects=['RSV002']
meanFD=np.zeros(shape=np.shape(subjects))  
maxFD=np.zeros(shape=np.shape(subjects))  

#N=68 for EDDY

i=0


for SIC in subjects:  
    print SIC
    
#    rot=np.loadtxt('/nobackup/aventurin4/LIFE/dti/%s/motion_params/ec_rot.txt' %(SIC))
#    trans=np.loadtxt('/nobackup/aventurin4/LIFE/dti/%s/motion_params/ec_trans.txt' %(SIC))  
#    N=np.shape(rot)[0]
#    mo_params_for_compute_fd=np.zeros(shape=(N,6))
#    mo_params_for_compute_fd[:,0:3]=rot
#    mo_params_for_compute_fd[:,3:6]=trans
    mo_params=np.loadtxt('/data/pt_life_dti/mri/%s/%s_diff_ec.eddy_parameters' %(SIC,SIC))
#     for DWI rotational parameters are the 4-6 columns!my_eddy_output.eddy_parameters
#    This is a text file with one row for each volume in --imain and one column for each parameter. 
#    The first six columns correspond to subject movement starting with three translations followed by three rotations. 
#    The remaining columns pertain to the EC-induced fields and the number and interpretation of them will 
#    depend of which EC model was specified.
    N=np.shape(mo_params)[0]
    mo_params_for_compute_fd=np.zeros(shape=(N,6))
    mo_params_for_compute_fd[:,0:3]=mo_params[:,3:6]
    mo_params_for_compute_fd[:,3:6]=mo_params[:,0:3]
    
    
    fd = compute_fd(mo_params_for_compute_fd)
    meanFD[i]=np.mean(fd)
    maxFD[i]=np.max(fd)
    i+=1
    np.savetxt('/data/pt_life_dti/mri/%s/check/fd.txt' %SIC, fd)
    
print i
df = pd.DataFrame(zip(subjects, meanFD, maxFD), columns = ["subject_id", "meanFD", "maxFD"])
df.to_csv('/data/pt_life_dti/output/'+"LIFE3T_DWI_motion.csv")
