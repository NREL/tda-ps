import numpy as np
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

#--------#
def Bifan(A):
    NA = np.logical_and(np.logical_not(A)*1,np.transpose(np.logical_not(A)*1))*1
    W = np.zeros(np.shape(DirectionalBreakup(A)['G']))

    if len(np.nonzero(np.triu(NA, 1))[0]) != 0 or len(np.nonzero(np.triu(NA, 1))[1]) != 0:
        W = W + np.transpose(W)
    else:
        ai = np.nonzero(np.triu(NA, 1))[0]
        aj = np.nonzero(np.triu(NA, 1))[1]

        for ind in range(0, len(ai)):
            x = ai[ind]
            y = aj[ind]
            xout = np.nonzero(DirectionalBreakup(A)['U'][x, :])
            yout = np.nonzero(DirectionalBreakup(A)['U'][y, :])
            common = intersection(xout, yout)
            if np.ndim(common) == 1:
                nc = 0
            else:
                nc = np.shape(common)[1]
            for i in range(0, nc):
                for j in range(i+1,nc):
                    w = common[i]
                    v = common[j]
                    if NA[w, v] == 1:
                        W[x, y] = W[x, y] + 1
                        W[x, w] = W[x, w] + 1
                        W[x, v] = W[x, v] + 1
                        W[y, w] = W[y, w] + 1
                        W[y, v] = W[y, v] + 1
                        W[w, v] = W[w, v] + 1
    W = W + np.transpose(W)
    return (W)



# test for Bifan structure #
#A = np.array([[0 ,1 ,0,0,0,0], [0,0,1 ,0 ,1 ,0], [0,0,0,1,1,0], [0,0,0,0,0,0], [0,0,0 ,1, 0 ,1],[0,0,0,0,0,0]])
A = np.array([[0,1,0,1],[0,0,0,0],[0,1,0,1],[0,0,0,0]])
# test over #
