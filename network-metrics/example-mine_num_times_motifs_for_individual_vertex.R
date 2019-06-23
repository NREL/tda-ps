library(igraph)

# case study #
# simplify output graph generated from encapsulation_func.R #
test_network = simplify(graph_structure_under_sequence_row_attack)
# simplify comlplete #

# create the output motifs matrix for each node(bus) #
motifs_matrix = matrix(NA, nrow = length(V(test_network)), ncol = 16)
rownames(motifs_matrix) = vertex_attr(test_network)$name

for (i in 1:length(V(test_network))) {
  
  subGraph = graph.neighborhood(test_network, order = 1, V(test_network)$name[i], mode = 'all')[[1]]
  allMotifs = triad_census(subGraph)
  removeNode = delete_vertices(subGraph, V(test_network)$name[i])
  single_node_Motifs = allMotifs - triad_census(removeNode)
  motifs_matrix[i,] = single_node_Motifs
}

sum(is.na(motifs_matrix)) == 0

diff_types_motifs_matrix = matrix(0, nrow = 4, ncol = 16)
for (j in c(1:4)) {
  if(sum(vertex_attr(test_network)$feature == j) > 0){
  tmp_node_feature_label = which(vertex_attr(test_network)$feature == j)
  diff_types_motifs_matrix[j,] = colSums(motifs_matrix[tmp_node_feature_label,, drop = FALSE])}
}

rownames(diff_types_motifs_matrix) = c("Bus","Load","Generator","Generator_and_Load")






'''
# test (dataset here is directed graph, but we can also apply it to undirected graph) #
# Below procedure is to calculate -> the number of times that node "one" appears in all 3-node motifs #
testGraph = barabasi.game(10, 
m = 5,
power = 0.6, 
out.pref = TRUE,
zero.appeal = 0.5,
directed = TRUE)

plot(testGraph,vertex.size = 20, edge.width  =2, edge.arrow.size = 0.5, edge.color = "black")

# Label nodes to more easily keep track during subsets/deletions
V(testGraph)$name = c('one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten')

subGraph = graph.neighborhood(testGraph, order = 1, V(testGraph)[1], mode = 'all')[[1]]
allMotifs = triad.census(subGraph)
removeNode = delete.vertices(subGraph, 'one')
node1Motifs = allMotifs - triad.census(removeNode) # the length of output here is 16
final_node1Motifs = node1Motifs[c(3,5,6:16)] # the length of final version is 13
# test over #
'''



