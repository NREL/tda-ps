
rm(list = ls())

start.time = Sys.time()

###################
#=== LIBRARIES ===#
###################

library(rio)

##############################################################################################################################################


###################
#=== FUNCTION ====#
###################


LMAX_Dec2 = function(data_val){
  
  
  daata_B   = data_val[,c(3:120)] 
  daata_L   = data_val[,c(601:699)] 
  
  #############################################################################################################
  
  # Bus Info #
  Bus_Info = ifelse(daata_B == "FALSE",1,0)
  #bus_char = as.numeric(Bus_Info)
  sec1 = Bus_Info
  
  # Load Info #
  Load_Info  = matrix(0, ncol = ncol(Bus_Info), nrow = nrow(Bus_Info))
  Load_Info = as.data.frame(Load_Info)
  colnames(Load_Info) = c(paste0("L_",seq(1:ncol(Bus_Info))))
  
  Load_Info[,colnames(daata_L)] = daata_L
  Load_Info = as.data.frame(Load_Info)
  sec2 = Load_Info
  
  # Load Max #
  
  
  sec3 = Load_Info[1,]
  
  #LMAX_Mat = rbind(sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3,sec3)
  ddop = as.matrix(sec3)
  LMAX_Mat = replicate(nrow(Bus_Info),ddop,simplify = "matrix")
  LMAX_Mat = t(LMAX_Mat)
  
  # Load Directly shed #
  
  LDSHD = ifelse(sec1 == 1, LMAX_Mat, 0)
  colnames(LDSHD) = colnames(LMAX_Mat)
  
  # Load Cascd #
  
  LCAS = data.frame(matrix(0,nrow = nrow(daata_B),ncol = ncol(daata_B)))
  colnames(LCAS) = colnames(LDSHD)
  
  for(i in 1:nrow(daata_B)){
    
    LCAS[i,] = sec3 - sec2[i,] - LDSHD[i,]
    
    
  }
  
  #rowSums(LMAX_Mat)
  
  #rowSums(LDSHD) + rowSums(LCAS) + rowSums(sec2)
  
  
  
  #=== Sum of loads ===#
  
  SLMAX  = rowSums(LMAX_Mat)
  SLSVD  = rowSums(sec2)
  SLDSHD = rowSums(LDSHD)
  SLCAS  = rowSums(LCAS)
  
  
  
  #=== Sum of Loads ===#
  
  SLMAX = rowSums(LMAX_Mat)
  SLSVD = rowSums(sec2)
  SLDSHD = rowSums(LDSHD)
  SLCAS = rowSums(LCAS)
  
  
  for(i in 1:length(SLCAS)){
    
    if(SLCAS[i]<0){
      SLCAS[i] = 0
    }
  }
  
  
  #=== Deltas/Proportions ===#
  
  DLMAX  = SLMAX/SLMAX[1]
  DLSVD  = SLSVD/SLMAX[1]
  DLDSHD = SLDSHD/SLMAX[1]
  DLCAS  = SLCAS/SLMAX[1]
  
  resultsN = data.frame(SLMAX,SLSVD,SLDSHD,SLCAS,DLMAX,DLSVD,DLDSHD,DLCAS)
  
  return(resultsN)
  
  
}




############################################################################################################################3

# Decomposotion #

for(i in 1:100){
  
  
  setwd("C:/Users/Owner/Box/test_folder/study002/dataset")
  
  
  daata = import(paste0("result-",i,".tsv"), format = "csv")
  
  res2_pad = LMAX_Dec2(daata)
  
  
  setwd("C:/Users/Owner/Box/test_folder/study002/results")
  
  
  write.csv(res2_pad, paste0("L_Decomp-",i,".csv"))
  
  
}




##############################################################################################################################################


end.time = Sys.time()

time.taken = end.time - start.time



