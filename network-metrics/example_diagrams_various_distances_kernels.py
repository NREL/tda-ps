import gudhi
import csv
import pandas as pd
import numpy as np
from sklearn.kernel_approximation import RBFSampler
from sklearn_tda import *
from gudhi import bottleneck_distance
# /.../NREL_works/sklearn_tda_package/example # (where the .csv stored)

#target_matrix = pd.read_csv('test_full_distance_matrix.csv',header=None) #should use gudhi's load data function
target_matrix = gudhi.read_lower_triangular_matrix_from_csv_file('test_full_distance_matrix.csv') #input distance matrix csv format and with comma
rips_complex = gudhi.RipsComplex(distance_matrix=target_matrix,max_edge_length=1)
simplex_tree = rips_complex.create_simplex_tree(max_dimension=4)
diag = simplex_tree.persistence(homology_coeff_field=2, min_persistence=0)

# transform the diag to X_arrays which shape is n*2 that is remove n*1 label column
X_arrays = np.zeros((len(diag),2),dtype=float)
for i in range(len(diag)):
    X_arrays[i,:] = np.asarray(diag[i][1])

for j in range(len(diag)):
    if X_arrays[j,1] == float("Inf"):
        X_arrays[j,1] = 1

target_matrix_compared = gudhi.read_lower_triangular_matrix_from_csv_file('test_full_distance_matrix_compared.csv') #input distance matrix csv format and with comma
rips_complex_compared = gudhi.RipsComplex(distance_matrix=target_matrix_compared,max_edge_length=1)
simplex_tree_compared = rips_complex_compared.create_simplex_tree(max_dimension=4)
diag_compared = simplex_tree_compared.persistence(homology_coeff_field=2, min_persistence=0)

X_arrays_c = np.zeros((len(diag_compared),2),dtype=float)
for i in range(len(diag_compared)):
    X_arrays_c[i,:] = np.asarray(diag_compared[i][1])

for j in range(len(diag_compared)):
    if X_arrays_c[j,1] == float("Inf"):
        X_arrays_c[j,1] = 1



X_arrays = [X_arrays]
X_arrays_c = [X_arrays_c]

def arctan(C,p):
  return lambda x: C*np.arctan(np.power(x[1], p))

PWG = PersistenceWeightedGaussianKernel(bandwidth=1., kernel_approx=None, weight=arctan(1.,1.))
X = PWG.fit(X_arrays)
Y = PWG.transform(X_arrays_c)
print("PWG kernel is " + str(Y[0][0]))

PWG = PersistenceWeightedGaussianKernel(kernel_approx=RBFSampler(gamma=1./2, n_components=100000).fit(np.ones([1,2])), weight=arctan(1.,1.))
X = PWG.fit(X_arrays)
Y = PWG.transform(X_arrays_c)
print("Approximate PWG kernel is " + str(Y[0][0]))

PSS = PersistenceScaleSpaceKernel(bandwidth=1.)
X = PSS.fit(X_arrays)
Y = PSS.transform(X_arrays_c)
print("PSS kernel is " + str(Y[0][0]))

PSS = PersistenceScaleSpaceKernel(kernel_approx=RBFSampler(gamma=1./2, n_components=100000).fit(np.ones([1,2])))
X = PSS.fit(X_arrays)
Y = PSS.transform(X_arrays_c)
print("Approximate PSS kernel is " + str(Y[0][0]))

sW = SlicedWassersteinDistance(num_directions=100)
X = sW.fit(X_arrays)
Y = sW.transform(X_arrays_c)
print("SW distance is " + str(Y[0][0]))

SW = SlicedWassersteinKernel(num_directions=100, bandwidth=1.)
X = SW.fit(X_arrays)
Y = SW.transform(X_arrays_c)
print("SW kernel is " + str(Y[0][0]))

W = BottleneckDistance(epsilon=.001)
X = W.fit(X_arrays)
Y = W.transform(X_arrays_c)
print("Bottleneck distance is " + str(Y[0][0]))

PF = PersistenceFisherKernel(bandwidth_fisher=1., bandwidth=1.)
X = PF.fit(X_arrays)
Y = PF.transform(X_arrays_c)
print("PF kernel is " + str(Y[0][0]))

PF = PersistenceFisherKernel(bandwidth_fisher=1., bandwidth=1., kernel_approx=RBFSampler(gamma=1./2, n_components=100000).fit(np.ones([1,2])))
X = PF.fit(X_arrays)
Y = PF.transform(X_arrays_c)
print("Approximate PF kernel is " + str(Y[0][0]))
