rm(list=ls())
library(igraph)
library(reshape2)
library(ggplot2)
library(gridExtra)
library(RColorBrewer)
library(data.table)
library(Matrix)
library(plyr)
library(gdata)
library(TDA)
library(plyr)
library(stringr)
library(dplyr)

# Both betti number.csv and Diag.csv are generated from GUDHI_betti_number_bottleneck_distance_scripts.py #

#### betti plot #######
result = read.csv("betti_number_file.csv", header = F)
colnames(result) = c("Time","B0","B1","B2","B3")
CM <- melt(result,id.vars = "Time", measure.vars = c("B0","B1","B2","B3"))
ggplot(CM, aes(x=Time, y=value, color=variable)) +scale_color_manual(values=c("black", "red", "blue","grey")) +
  geom_point()+geom_line() +geom_text(aes(label = value),vjust =-0.5,hjust=-0.5, size = 3) 

#### barcode plot ######
par(mfrow=c(1,2))
plot.diagram(Diag) # where Diag is the output of simplex_tree.persistence function from Python #
plot.diagram(Diag,barcode = T)
