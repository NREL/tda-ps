# load package #
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

# Diag1, Diag2 generated from python code #

bk_dis0 <- bottleneck(Diag1, Diag2,dimension = 0)
bk_dis1 <- bottleneck(Diag1, Diag2,dimension = 1)
bk_dis2 <- bottleneck(Diag1, Diag2,dimension = 2)
bk_dis3 <- bottleneck(Diag1, Diag2,dimension = 3)

w_dis0 <- wasserstein(Diag1, Diag2, p = 1, dimension = 0)
w_dis1 <- wasserstein(Diag1, Diag2, p = 1, dimension = 1)
w_dis2 <- wasserstein(Diag1, Diag2, p = 1, dimension = 2)
w_dis3 <- wasserstein(Diag1, Diag2, p = 1, dimension = 3)



