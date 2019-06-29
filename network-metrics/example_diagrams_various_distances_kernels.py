import gudhi
import csv
import pandas as pd
import numpy as np
from sklearn.kernel_approximation import RBFSampler
from sklearn_tda import *
from gudhi import bottleneck_distance
import igraph
from igraph import *
# /.../NREL_works/sklearn_tda_package/example # (where the .csv stored)

for uu in range(101):
    #@1: weight_filename = "weight_matrix_" + str(uu) + ".csv"
    #@1: target_matrix = gudhi.read_lower_triangular_matrix_from_csv_file('weight_matrix_0.csv')
    filename = "graph_sequence_" + str(uu) +".gml"
    tmp_graph = igraph.read(filename)
    target_matrix = np.array(tmp_graph.get_adjacency("weight").data)
    rips_complex = gudhi.RipsComplex(distance_matrix=target_matrix, max_edge_length=0.1)
    simplex_tree = rips_complex.create_simplex_tree(max_dimension=1)
    diag = simplex_tree.persistence(homology_coeff_field=2, min_persistence=0)

    # transform the diag to X_arrays which shape is n*2 that is remove n*1 label column
    X_arrays = np.zeros((len(diag), 2), dtype=float)
    for i in range(len(diag)):
        X_arrays[i, :] = np.asarray(diag[i][1])

    for j in range(len(diag)):
        if X_arrays[j, 1] == float("Inf"):
            X_arrays[j, 1] = 0.1

    target_matrix_compared = gudhi.read_lower_triangular_matrix_from_csv_file(weight_filename)
    rips_complex_compared = gudhi.RipsComplex(distance_matrix=target_matrix_compared, max_edge_length=0.1)
    simplex_tree_compared = rips_complex_compared.create_simplex_tree(max_dimension=1)
    diag_compared = simplex_tree_compared.persistence(homology_coeff_field=2, min_persistence=0)

    X_arrays_compared = np.zeros((len(diag_compared), 2), dtype=float)
    for i in range(len(diag_compared)):
        X_arrays_compared[i, :] = np.asarray(diag_compared[i][1])

    for j in range(len(diag_compared)):
        if X_arrays_compared[j, 1] == float("Inf"):
            X_arrays_compared[j, 1] = 0.1

    X_arrays = [X_arrays]
    X_arrays_compared = [X_arrays_compared]

    def arctan(C, p):
        return lambda x: C * np.arctan(np.power(x[1], p))


    PWG = PersistenceWeightedGaussianKernel(bandwidth=1., kernel_approx=None, weight=arctan(1., 1.))
    X = PWG.fit(X_arrays)
    Y = PWG.transform(X_arrays_compared)
    summary_kernel_distance_result2[0,uu] = Y[0][0]


    PWG = PersistenceWeightedGaussianKernel(
        kernel_approx=RBFSampler(gamma=1. / 2, n_components=100000).fit(np.ones([1, 2])), weight=arctan(1., 1.))
    X = PWG.fit(X_arrays)
    Y = PWG.transform(X_arrays_compared)
    summary_kernel_distance_result2[1,uu] = Y[0][0]

    PSS = PersistenceScaleSpaceKernel(bandwidth=1.)
    X = PSS.fit(X_arrays)
    Y = PSS.transform(X_arrays_compared)
    summary_kernel_distance_result2[2,uu] = Y[0][0]

    PSS = PersistenceScaleSpaceKernel(kernel_approx=RBFSampler(gamma=1. / 2, n_components=100000).fit(np.ones([1, 2])))
    X = PSS.fit(X_arrays)
    Y = PSS.transform(X_arrays_compared)
    summary_kernel_distance_result2[3,uu] = Y[0][0]

    sW = SlicedWassersteinDistance(num_directions=100)
    X = sW.fit(X_arrays)
    Y = sW.transform(X_arrays_compared)
    summary_kernel_distance_result2[4,uu] = Y[0][0]

    SW = SlicedWassersteinKernel(num_directions=100, bandwidth=10)
    X = SW.fit(X_arrays)
    Y = SW.transform(X_arrays_compared)
    summary_kernel_distance_result2[5,uu] = Y[0][0]

    W = BottleneckDistance(epsilon=.001)
    X = W.fit(X_arrays)
    Y = W.transform(X_arrays_compared)
    summary_kernel_distance_result2[6,uu] = Y[0][0]


    PF = PersistenceFisherKernel(bandwidth_fisher=1., bandwidth=1.)
    X = PF.fit(X_arrays)
    Y = PF.transform(X_arrays_compared)
    summary_kernel_distance_result2[7,uu] = Y[0][0]

    PF = PersistenceFisherKernel(bandwidth_fisher=1., bandwidth=1.,
                                 kernel_approx=RBFSampler(gamma=1. / 2, n_components=100000).fit(np.ones([1, 2])))
    X = PF.fit(X_arrays)
    Y = PF.transform(X_arrays_compared)
    summary_kernel_distance_result2[8,uu] = Y[0][0]
