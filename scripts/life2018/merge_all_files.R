rm(list = ls()) 
#self created function on R-blogger
multmerge = function(mypath){
          filenames=list.files(path=mypath, full.names=TRUE)
          datalist = lapply(filenames, function(x){read.csv(file=x,header=T, sep = " ")})
          Reduce(function(x,y) {merge(x,y)}, datalist)}
          
MD = multmerge("/data/pt_life_dti/output/HP_oldLabels_mean_MD")

write.csv(MD, file = "/data/pt_life_dti/results/20180723_HP_meanMD_oldLables_2018_Lipsia_pipeline.csv", 
          row.names = F,quote = F)
