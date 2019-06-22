import gudhi
import csv
import pandas as pd
import numpy as np

#target_matrix = pd.read_csv('test_full_distance_matrix.csv',header=None) #should use gudhi's load data function
target_matrix = gudhi.read_lower_triangular_matrix_from_csv_file('test_full_distance_matrix.csv') #input distance matrix csv format and with comma
#print(target_matrix)
rips_complex = gudhi.RipsComplex(distance_matrix=target_matrix,max_edge_length=1)

simplex_tree = rips_complex.create_simplex_tree(max_dimension=4)
result_str = 'Rips complex is of dimension ' + repr(simplex_tree.dimension()) + ' - ' + \
    repr(simplex_tree.num_simplices()) + ' simplices - ' + \
    repr(simplex_tree.num_vertices()) + ' vertices.'
print(result_str)
fmt = '%s -> %.2f'
for filtered_value in simplex_tree.get_filtration():
    print(fmt % tuple(filtered_value))
diag = simplex_tree.persistence(homology_coeff_field=2, min_persistence=0)
print(diag)
print(np.shape(diag)) # when change the option - max_edge_length in function RipsConplex, the dimension of diagram would not change
# print(type(diag)) #: list
diag_array = np.array(diag)
combination_birth_t = list()
combination_death_t = list()
for i in range(len(diag)):
    combination_birth_t.append(diag_array[:,1][i][0])
    combination_death_t.append(diag_array[:, 1][i][1])

combination_birth_death_t = combination_birth_t + combination_death_t
combination_birth_death_t = np.unique(combination_birth_death_t)

tmp = np.zeros(shape=(len(diag),3))
tmp[:,0] = diag_array[:,0]
for j in range(len(diag)):
    tmp[j,1] = combination_birth_t[j]
    tmp[j,2] = combination_death_t[j]

column_names = ['Time','Betti_0','Betti_1','Betti_2','Betti_3'] # here, we work on 4-dimensions
betti = np.zeros(shape=(len(combination_birth_death_t),5),dtype=float)
betti[:,0] = np.array(combination_birth_death_t)

for ii in range(len(tmp)):
    targetBettiCol = tmp[ii,0] + 1
    targetBettiCol = int(targetBettiCol)
    birthID = np.where(betti[:,0] == tmp[ii,1])
    birthID = int(np.array(birthID))
    deathID = np.where(betti[:,0] == tmp[ii,2])
    deathID = int(np.array(deathID))

    if tmp[ii,2]==float('Inf'):
        new_deathID = deathID+1
        betti[birthID:new_deathID,targetBettiCol] = betti[birthID:new_deathID,targetBettiCol]+1
    else:
        betti[birthID:deathID, targetBettiCol] = betti[birthID:deathID, targetBettiCol] + 1

print(betti) # complete and consistent dim is (258,5)

betti_output = pd.DataFrame(betti,columns=column_names)
print(betti_output)

# Since GUDHI do not provide the wasserstein distance calculation, therefore we need to transform to TDA package in R #
# Firstly, save tmp file i.e., output diagram as .csv file. For example: #
np.savetxt('diag_output_matrix.csv', tmp, delimiter=',')
#--#

# bottleneck distance (not Wasserstein distance - it could be accessed through TDA package in R) #
#gudhi.bottleneck_distance(diag1, diag2, 0.1)

'''
# calculate the betti number command #
print(simplex_tree.betti_numbers())
print(simplex_tree.persistent_betti_numbers(0, 1)) #from_value and to_value; I should use this function
'''

'''
print(simplex_tree.dimension())
print(simplex_tree.num_simplices())
print(simplex_tree.num_vertices())
print(simplex_tree.persistent_betti_numbers(0.1,0.3))
print(int(np.array(np.where(betti[:,0]==tmp[0,1]))))
'''
plt = gudhi.plot_persistence_diagram(diag,legend=True)
plt.show()


# http://gudhi.gforge.inria.fr/python/latest/rips_complex_user.html - guideline
# http://gudhi.gforge.inria.fr/python/latest/simplex_tree_ref.html - guideline
