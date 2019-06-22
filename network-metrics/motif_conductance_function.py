import numpy as np
from numpy.linalg import matrix_power
import pickle as pkl
import networkx as nx
import scipy.sparse as sp
from scipy.sparse.linalg.eigen.arpack import eigsh
from scipy.linalg import eig, eigh
import pandas as pd



def DirectionalBreakup(A):
    res = dict()
    A[np.nonzero(A)] = 1 # https://docs.scipy.org/doc/numpy/reference/generated/numpy.nonzero.html
    B = np.logical_and(A,np.transpose(A)) *1
    U = A - B
    G = np.logical_or(A,np.transpose(A)) *1
    res['B'] = B
    res['U'] = U
    res['G'] = G
    return(res)

# test for DirectionalBreakup function #
A = np.array([[0 ,1 ,1, 1 ,0], [1 ,0 ,1 ,1 ,1], [1, 1 ,0 ,1 ,1], [1 ,1 ,1 ,0 ,1], [0 ,1, 1 ,1 ,0]])
DirectionalBreakup(A)
# test over #

def intersection(lst1, lst2):
    lst3 = [value for value in lst1 if value in lst2]
    return lst3

#---------#
def M1(A):
    C =np.multiply(np.dot(DirectionalBreakup(A)['U'],DirectionalBreakup(A)['U']),np.transpose(DirectionalBreakup(A)['U']))
    W = C + np.transpose(C)
    return(W)

#---------#
def M2(A):
    C = np.multiply(np.dot(DirectionalBreakup(A)['B'],DirectionalBreakup(A)['U']),np.transpose(DirectionalBreakup(A)['U']))+\
        np.multiply(np.dot(DirectionalBreakup(A)['U'],DirectionalBreakup(A)['B']),np.transpose(DirectionalBreakup(A)['U']))+ \
        np.multiply(np.dot(DirectionalBreakup(A)['U'], DirectionalBreakup(A)['U']),
                    DirectionalBreakup(A)['B'])
    W = C + np.transpose(C)
    return (W)

#---------#
def M3(A):
    C = np.multiply(np.dot(DirectionalBreakup(A)['B'],DirectionalBreakup(A)['B']),DirectionalBreakup(A)['U'])+\
        np.multiply(np.dot(DirectionalBreakup(A)['B'],DirectionalBreakup(A)['U']),DirectionalBreakup(A)['B'])+ \
        np.multiply(np.dot(DirectionalBreakup(A)['U'], DirectionalBreakup(A)['B']),
                    DirectionalBreakup(A)['B'])
    W = C + np.transpose(C)
    return (W)

#---------#
def M4(A):
    W = np.multiply(np.dot(DirectionalBreakup(A)['B'],DirectionalBreakup(A)['B']),DirectionalBreakup(A)['B'])
    return (W)

#---------#
def M5(A):
    T1 = np.multiply(np.dot(DirectionalBreakup(A)['U'], DirectionalBreakup(A)['U']), DirectionalBreakup(A)['U'])
    T2 = np.multiply(np.dot(np.transpose(DirectionalBreakup(A)['U']), DirectionalBreakup(A)['U']),
                     DirectionalBreakup(A)['U'])
    T3 = np.multiply(np.dot(DirectionalBreakup(A)['U'], np.transpose(DirectionalBreakup(A)['U'])),
                     DirectionalBreakup(A)['U'])
    C = T1 + T2 + T3
    W = C + np.transpose(C)
    return (W)

#---------#
def M6(A):
    C1 = np.multiply(np.dot(DirectionalBreakup(A)['U'], DirectionalBreakup(A)['B']), DirectionalBreakup(A)['U'])
    C1 = C1 + np.transpose(C1)
    C2 = np.multiply(np.dot(np.transpose(DirectionalBreakup(A)['U']), DirectionalBreakup(A)['U']),
                     DirectionalBreakup(A)['B'])
    W = C1 + C2
    return(W)


#---------#
def M7(A):
    C1 = np.multiply(np.dot(np.transpose(DirectionalBreakup(A)['U']), DirectionalBreakup(A)['B']), np.transpose(DirectionalBreakup(A)['U']))
    C1 = C1 + np.transpose(C1)
    C2 = np.multiply(np.dot(DirectionalBreakup(A)['U'], np.transpose(DirectionalBreakup(A)['U'])),
                     DirectionalBreakup(A)['B'])
    W = C1 + C2
    return (W)

#--------#
def M8(A):
    W = np.zeros(np.shape(DirectionalBreakup(A)['G']))
    N = np.shape(DirectionalBreakup(A)['G'])[1]
    for i in range(N):
        J = np.nonzero(DirectionalBreakup(A)['U'][i, :])
        for j1 in range(0, np.shape(J)[1]):
            if (j1 + 1) <= np.shape(J)[1]:
                for j2 in range((j1 + 1), np.shape(J)[1]):
                    k1 = J[0][j1]
                    k2 = J[0][j2]
                    if A[k1, k2] == 0 and A[k2, k1] == 0:
                        W[i, k1] = W[i, k1] + 1
                        W[i, k2] = W[i, k2] + 1
                        W[k1, k2] = W[k1, k2] + 1

    W= W + np.transpose(W)
    return(W)

#--------#
def M9(A):
    W = np.zeros(np.shape(DirectionalBreakup(A)['G']))
    N = np.shape(DirectionalBreakup(A)['G'])[1]
    for i in range(N):
        J1 = np.nonzero(DirectionalBreakup(A)['U'][i, :])
        J2 = np.nonzero(DirectionalBreakup(A)['U'][:,i])
        for j1 in range(0, np.shape(J1)[1]):
            for j2 in range(0, np.shape(J2)[1]):
                k1 = J1[0][j1]
                k2 = J2[0][j2]
                if A[k1,k2] == 0 and A[k2,k1]==0:
                    W[i,k1] = W[i,k1]+1
                    W[i, k2] = W[i, k2] + 1
                    W[k1, k2] = W[k1, k2] + 1

    W = W + np.transpose(W)
    return (W)

#--------#
def M10(A):
    W = M8(np.transpose(A))
    return(W)

#--------#
def M11(A):
    W = np.zeros(np.shape(DirectionalBreakup(A)['G']))
    N = np.shape(DirectionalBreakup(A)['G'])[1]
    for i in range(N):
        J1 = np.nonzero(DirectionalBreakup(A)['B'][i, :])
        J2 = np.nonzero(DirectionalBreakup(A)['U'][:, i])
        for j1 in range(0, np.shape(J1)[1]):
            for j2 in range(0, np.shape(J2)[1]):
                k1 = J1[0][j1]
                k2 = J2[0][j2]
                if A[k1, k2] == 0 and A[k2, k1] == 0:
                    W[i, k1] = W[i, k1] + 1
                    W[i, k2] = W[i, k2] + 1
                    W[k1, k2] = W[k1, k2] + 1

    W = W + np.transpose(W)
    return (W)

#--------#
def M12(A):
    W = M11(np.transpose(A))
    return(W)

#--------#
def M13(A):
    W = np.zeros(np.shape(DirectionalBreakup(A)['G']))
    N = np.shape(DirectionalBreakup(A)['G'])[1]
    for i in range(N):
        J = np.nonzero(DirectionalBreakup(A)['B'][i, :])
        for j1 in range(0, np.shape(J)[1]):
            if (j1 + 1) <= np.shape(J)[1]:
                for j2 in range((j1 + 1), np.shape(J)[1]):
                    k1 = J[0][j1]
                    k2 = J[0][j2]
                    if A[k1, k2] == 0 and A[k2, k1] == 0:
                        W[i, k1] = W[i, k1] + 1
                        W[i, k2] = W[i, k2] + 1
                        W[k1, k2] = W[k1, k2] + 1

    W= W + np.transpose(W)
    return(W)

def Motif_Adj_f(A,motif_type):
    if motif_type=="m1":
        W = M1(A)
        return(W)
    elif motif_type=="m2":
        W= M2(A)
        return (W)
    elif motif_type=="m3":
        W= M3(A)
        return (W)
    elif motif_type=="m4":
        W = M4(A)
        return(W)
    elif motif_type=="m5":
        W= M5(A)
        return(W)
    elif motif_type=="m6":
        W= M6(A)
        return(W)
    elif motif_type=="m7":
        W= M7(A)
        return (W)
    elif motif_type=="m8":
        W = M8(A)
        return(W)
    elif motif_type=="m9":
        W= M9(A)
        return(W)
    elif motif_type=="m10":
        W= M10(A)
        return(W)
    elif motif_type=="m11":
        W = M11(A)
        return(W)
    elif motif_type=="m12":
        W= M12(A)
        return(W)
    elif motif_type=="m13":
        W= M13(A)
        return(W)



G = pd.read_csv("A.csv",index_col=0) # here A.csv is the adjacency matrix of case118_ieee graph (without parallel edges)
A = np.array(G)
conductances_sum_mat = np.zeros((13,A.shape[0]))
min_value_sum_mat = np.zeros((13,))
motif_type = np.array(["m1","m2","m3","m4","m5","m6","m7","m8","m9","m10","m11","m12","m13"])
for ii in motif_type:
    if np.sum(Motif_Adj_f(A,ii))!=0:
        col_sum = np.sum(A, axis=0)  # column sum
        diagonal_mat = np.diag(col_sum)
        identity_mat = np.diag(np.ones((A.shape[0],), dtype=int))
        # normalize_adj #
        adj = sp.coo_matrix(Motif_Adj_f(A,ii))
        rowsum = np.array(adj.sum(1))
        d_inv_sqrt = np.power(rowsum, -0.5).flatten()
        d_inv_sqrt[np.isinf(d_inv_sqrt)] = 0.
        d_mat_inv_sqrt = sp.diags(d_inv_sqrt)
        adj_normalized = adj.dot(d_mat_inv_sqrt).transpose().dot(
            d_mat_inv_sqrt).tocoo()  # <class 'scipy.sparse.coo.coo_matrix'>
        laplacian = sp.eye(adj.shape[0]) - adj_normalized
        laplacian_numpy_form = laplacian.toarray()
        # add a diagnoal matrix to normalized laplacian matrix #
        diag = np.ones((A.shape[0],))
        diag_mat = np.diag(diag)
        diag_mat_sp = sp.csc_matrix(diag_mat)
        # complete #
        evals_all, evecs_all = eigh(laplacian_numpy_form)
        # Z = evecs_all[:, 1] * (-1)
        # find eigenvector with the second smallest eigenvalue; there are two ways to find the eigenvectors and eigenvalues: eigh and eigsh #
        output1 = eigsh(laplacian+diag_mat_sp, 3, which='SM') # k=3 rather than 2 #
        Z = output1[1][:, 2]
        f_M = np.dot(d_mat_inv_sqrt.toarray(), Z)
        # print(np.sort(np.dot(d_mat_inv_sqrt.toarray(),Z)))
        M_target = Motif_Adj_f(A,ii)
        order = np.argsort(f_M)  # [3,4,0,2,1,6,5,8,7,9]: this is the order case for food web dataset #
        C = np.zeros((len(order), len(order)), dtype=int)
        for i in order:
            for j in order:
                C[i, j] = M_target[order[i], order[j]]

        C_sums = np.sum(C, axis=1)
        volumes = np.cumsum(C_sums)
        volumes_other = np.sum(M_target) * np.ones((A.shape[0],), dtype=int) - volumes
        conductances = np.divide(np.cumsum(C_sums - 2 * np.sum(np.tril(C), axis=1)), np.minimum(volumes, volumes_other))
        # make nan equals to 1 #
        if sum(np.isnan(conductances)) > 0:
            conductances[np.isnan(conductances)] = 1

        # print(conductances)
        min_value_for_M_target = min(conductances)

        conductances_sum_mat[int("".join(filter(str.isdigit, ii)))-1, :] = conductances
        min_value_sum_mat[int("".join(filter(str.isdigit, ii)))-1] = min_value_for_M_target
    else:
        conductances_sum_mat[int("".join(filter(str.isdigit, ii)))-1, :] = np.zeros((A.shape[0],))
        min_value_sum_mat[int("".join(filter(str.isdigit, ii)))-1] = 'nan'




