


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


LMAX_parts = function(trial){
  
  fifo = trial
  
  t = 1
  LS_max = apply(fifo, 1, sum)[-c(1,nrow(fifo))]
  
  L_DS =  L_S = L_G = L_CAS = matrix(NA, ncol = ncol(fifo), nrow = (nrow(fifo) - 2))
  
  for(i in 1:(nrow(fifo) - 2)){
    
    t = t + 1
    
    aa = fifo[t,]
    bb = fifo[(t+1),]
    
    
    for(j in 1:length(aa)){
      
      if(aa[j] == 0 & bb[j] == 0){
        
        L_DS[i,j]  = 0
        L_S[i,j] = 0
        L_CAS[i,j] = 0
        L_G[i,j] = 0
        
      }else if(aa[j] == 0 & bb[j] > 0){
        L_S[i,j] = as.numeric(bb[j])
        L_DS[i,j] = 0
        L_G[i,j] = as.numeric(bb[j])
        L_CAS[i,j] = 0
        
      }else if(aa[j] >0 & bb[j] == 0){
        
        L_DS[i,j]  = as.numeric(aa[j])
        L_CAS[i,j] = 0
        L_G[i,j] = 0
        L_S[i,j] = as.numeric(bb[j])
        
      }else if(aa[j] >0 & bb[j] > 0 ){
        
        if(aa[j] == bb[j]){
          L_DS[i,j] = 0
          L_S[i,j]  = as.numeric(bb[j])
          L_G[i,j]  = 0
          L_CAS[i,j] = 0
          
        }else if(aa[j] < bb[j]){
          L_DS[i,j]  = 0
          L_CAS[i,j] = 0
          L_G[i,j] = as.numeric(bb[j]) - as.numeric(aa[j])
          L_S[i,j] = as.numeric(bb[j])
          
        }else if (aa[j]> bb[j]){
          L_DS[i,j] = 0
          L_CAS[i,j] = as.numeric(aa[j]) - as.numeric(bb[j])
          L_G[i,j] = 0
          L_S[i,j] = as.numeric(bb[j])
        }
        
        
      }
      
      
    }
    
    
    
  }
  
  
  L_S = as.data.frame(L_S)
  L_S$tot = apply(L_S, 1, sum)
  
  L_DS = as.data.frame(L_DS)
  L_DS$tot = apply(L_DS, 1, sum)
  
  L_G = as.data.frame(L_G)
  L_G$tot = apply(L_G, 1, sum)
  
  L_CAS = as.data.frame(L_CAS)
  L_CAS$tot = apply(L_CAS, 1, sum)
  
  
  nmn = cbind(L_S$tot, L_DS$tot, L_CAS$tot, L_G$tot,LS_max)
  mopo = cbind(L_S$tot, L_DS$tot, L_CAS$tot, L_G$tot)
  dmopo = mopo[,1] + mopo[,2] + mopo[,3] - mopo[,4]
  
  resultsN = data.frame(nmn, dmopo)
  colnames(resultsN) = c("L_SERV", "L_DSHD", "L_CAS", "L_GAIN", "LMAX", "CHK_LMAX")
  return(resultsN)
  
}


##############################################################################################################################################
# Decomposotion #

for(i in 1:100){
  
  
setwd("C:/Users/doforib/Desktop/test_folder/dataset")
  

daata = import(paste0("result-",i,".tsv"), format = "csv")


dataa_L   = daata[which(colnames(daata)=="L_1"):which(colnames(daata)=="L_118")] 


res2_pad = LMAX_parts(dataa_L)

setwd("C:/Users/doforib/Desktop/test_folder/results")

write.csv(res2_pad, paste0("L_Decomp-",i,".csv"))


}


##############################################################################################################################################
# Plotting #

# Overlaying lines #

setwd("C:/Users/doforib/Desktop/test_folder/results")

#----------------------------#
#=== All plots one-by-one ===#
#----------------------------#


par(mfrow = c(1,1))

################
# Single plots #
################

i = 1
res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))

plot(res2_pad$LMAX, type = "l", col = "red", ylab = "TL", ylim = c(0,45),xlab = "# of nodes removed")         

for(i in 2:100){
  
  res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))
  
  lines(res2_pad$LMAX, type = "l", col = "red")
  
}


i = 1
res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))

plot(res2_pad$L_SERV, type = "l", col = "blue", ylab = "LS", ylim = c(0,45),xlab = "# of nodes removed")

for(i in 2:100){
  
  res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))
  
  lines(res2_pad$L_SERV, type = "l", col = "blue")
  
}


i = 1
res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))

plot(res2_pad$L_DSHD, type = "l", col = "orange", ylab = "LDSHD", ylim = c(0,5),xlab = "# of nodes removed")

for(i in 2:100){
  
  res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))
  
  lines(res2_pad$L_DSHD, type = "l", col = "orange")
  
}


i = 1
res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))

plot(res2_pad$L_CAS, type = "l", col = "green", ylab = "L_CAS", ylim = c(0,6.1),xlab = "# of nodes removed")

for(i in 2:100){
  
  res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))
  
  lines(res2_pad$L_CAS, type = "l", col = "green")
  
}


i = 1
res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))

plot(res2_pad$L_GAIN, type = "l", col = "black", ylab = "L_G", ylim = c(0,3.5),xlab = "# of nodes removed")

for(i in 2:100){
  
  res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))
  
  lines(res2_pad$L_GAIN, type = "l", col = "black")
  
}



###############
# Joint plots #
###############

i = 1
res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))

plot(res2_pad$LMAX, type = "l", col = "red", ylim =  c(0,45), ylab = "Load value",xlab = "# of nodes removed")

for(i in 2:100){
  
  res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))
  
  lines(res2_pad$LMAX, type = "l", col = "red")
  
}


i = 1
res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))

lines(res2_pad$L_SERV, type = "l", col = "blue")

for(i in 2:100){
  
  res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))
  
  lines(res2_pad$L_SERV, type = "l", col = "blue")
  
}


i = 1
res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))

lines(res2_pad$L_DSHD, type = "l", col = "orange")

for(i in 2:100){
  
  res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))
  
  lines(res2_pad$L_SERV, type = "l", col = "blue")
  
}


i = 1
res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))

lines(res2_pad$L_CAS, type = "l", col = "green")

for(i in 2:100){
  
  res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))
  
  lines(res2_pad$L_CAS, type = "l", col = "green")
  
}


i = 1
res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))

lines(res2_pad$L_GAIN, type = "l", col = "black")

for(i in 2:100){
  
  res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))
  
  lines(res2_pad$L_GAIN, type = "l", col = "black")
  
}


legend("topright", bty = "n", inset = 0.005,
       c("TL", "LS", "LDSHD", "L_CAS", "L_G"),
       cex = 0.95, col=c("red", "blue", "orange", "green","black")) 

#==============================================================================================================================#
#------------------------------------------------------------------------------------------------------------------------------#
#==============================================================================================================================#

#-----------------------------#
#=== All plots on one plot ===#
#-----------------------------#

op = par(mfrow = c(2,3))

################
# Single plots #
################


i = 1
res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))

plot(res2_pad$LMAX, type = "l", col = "red", ylab = "TL", ylim = c(0,45),xlab = "# of nodes removed")         

for(i in 2:100){
  
  res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))
  
  lines(res2_pad$LMAX, type = "l", col = "red")
  
}


i = 1
res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))

plot(res2_pad$L_SERV, type = "l", col = "blue", ylab = "LS", ylim = c(0,45),xlab = "# of nodes removed")

for(i in 2:100){
  
  res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))
  
  lines(res2_pad$L_SERV, type = "l", col = "blue")
  
}


i = 1
res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))

plot(res2_pad$L_DSHD, type = "l", col = "orange", ylab = "LDSHD", ylim = c(0,5),xlab = "# of nodes removed")

for(i in 2:100){
  
  res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))
  
  lines(res2_pad$L_DSHD, type = "l", col = "orange")
  
}


i = 1
res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))

plot(res2_pad$L_CAS, type = "l", col = "green", ylab = "L_CAS", ylim = c(0,6.1),xlab = "# of nodes removed")

for(i in 2:100){
  
  res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))
  
  lines(res2_pad$L_CAS, type = "l", col = "green")
  
}


i = 1
res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))

plot(res2_pad$L_GAIN, type = "l", col = "black", ylab = "L_G", ylim = c(0,3.5),xlab = "# of nodes removed")

for(i in 2:100){
  
  res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))
  
  lines(res2_pad$L_GAIN, type = "l", col = "black")
  
}



###############
# Joint plots #
###############

i = 1
res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))

plot(res2_pad$LMAX, type = "l", col = "red", ylim =  c(0,45), ylab = "Load value",xlab = "# of nodes removed")

for(i in 2:100){
  
  res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))
  
  lines(res2_pad$LMAX, type = "l", col = "red")
  
}


i = 1
res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))

lines(res2_pad$L_SERV, type = "l", col = "blue")

for(i in 2:100){
  
  res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))
  
  lines(res2_pad$L_SERV, type = "l", col = "blue")
  
}


i = 1
res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))

lines(res2_pad$L_DSHD, type = "l", col = "orange")

for(i in 2:100){
  
  res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))
  
  lines(res2_pad$L_SERV, type = "l", col = "blue")
  
}


i = 1
res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))

lines(res2_pad$L_CAS, type = "l", col = "green")

for(i in 2:100){
  
  res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))
  
  lines(res2_pad$L_CAS, type = "l", col = "green")
  
}


i = 1
res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))

lines(res2_pad$L_GAIN, type = "l", col = "black")

for(i in 2:100){
  
  res2_pad = read.csv(paste0("L_Decomp-",i,".csv"))
  
  lines(res2_pad$L_GAIN, type = "l", col = "black")
  
}


legend("topright", bty = "n", inset = 0.005,
       c("TL", "LS", "LDSHD", "L_CAS", "L_G"),
       cex = 0.95, col=c("red", "blue", "orange", "green","black")) 


par(op)


#==============================================================================================================================#
#------------------------------------------------------------------------------------------------------------------------------#
#==============================================================================================================================#



# (Functional) Box plots #
data_TL = data_LS = data_DSHD = data_CAS = data_G = matrix(NA, ncol = 100, nrow = nrow(res2_pad))

for(i in 1:100){
  
  data_TL[,i]   = (read.csv(paste0("L_Decomp-",i,".csv")))$LMAX
  data_LS[,i]   = (read.csv(paste0("L_Decomp-",i,".csv")))$L_SERV
  data_DSHD[,i] = (read.csv(paste0("L_Decomp-",i,".csv")))$L_DSHD
  data_CAS[,i]  = (read.csv(paste0("L_Decomp-",i,".csv")))$L_CAS
  data_G[,i]    = (read.csv(paste0("L_Decomp-",i,".csv")))$L_GAIN
 
}

data_TL    = as.data.frame(data_TL)
boxplot(data_TL, col = "red")

data_LS    = as.data.frame(data_LS)
boxplot(data_LS, col = "green")

data_DSHD  = as.data.frame(data_DSHD)
boxplot(data_DSHD,col = "orange")

data_CAS   = as.data.frame(data_CAS)
boxplot(data_CAS,col = "blue")

data_G     = as.data.frame(data_G)
boxplot(data_G,col = "brown")




op = par(mfrow = c(2,3))

boxplot(data_TL$V1,col="grey")
points(data_TL$V2)





par(op)


##############################################################################################################################################


end.time = Sys.time()

time.taken = end.time - start.time


