import numpy as np
import pandas as pd
import pandas
import igraph
from igraph import *
import os
import csv


# Here we use igraph module for motif calculation #
# Motif calculation in Python test #
'''
g = Graph.Tree(10, 2)
g = Graph.Erdos_Renyi(20,0.2,directed=True)
print(summary(g))
print(g.motifs_randesu(size=3))
print(pd.DataFrame(dataset, index=range(0,200), columns=['from', 'to']))
g = Graph.Read_Ncol('new_storj_py_v2.txt',directed=True)
motif_daily_summary_mat[1]=range(0,13) #assign value to row in matrix
matchings_indices = [ i for i, x in enumerate(unix_time_record_vector) if initial_time <= x <= 1498953600 ]#like which function in r
'''
# test over #

# Scripts for test dataset #
dataset = pd.read_csv('test_motif_dataset.csv', usecols=[1,2,3,4])
motif_daily_summary_mat = np.zeros( (310, 16) ) # since the length of motifs_randesu output is 16 (directed graph input)
amount_daily_summary_mat = np.zeros((310,1))
unix_time_record = pd.DataFrame(dataset, index=range(0,len(dataset)), columns=['time'])
unix_time_record_vector = unix_time_record['time'].values
initial_time = 1498867200

for kk in range(0,310):

    matchings_indices = [ i for i, x in enumerate(unix_time_record_vector) if initial_time <= x <= initial_time+60*60*24-1 ]
    ii = min(matchings_indices)
    jj = max(matchings_indices)+1
    subdataset = pd.DataFrame(dataset, index=range(ii,jj), columns=['from','to'])
    np.savetxt('test.txt', subdataset, delimiter=' ', fmt='%i')
    file1 = open("test.txt", "r")
    g = Graph.Read_Ncol(file1, directed=True)
    motif_daily_summary_mat[kk] =g.motifs_randesu(size=3)
    initial_time = initial_time + 60*60*24 # 60*60*24 is the time interval
    np.savetxt('motif_result.csv', motif_daily_summary_mat, delimiter=',')
    print(kk)

print(motif_daily_summary_mat)
np.savetxt('motif_result.csv', motif_daily_summary_mat, delimiter=',')
