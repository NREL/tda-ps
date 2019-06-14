library(igraph)

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

# Idea from https://stackoverflow.com/questions/12374534/how-to-mine-for-motifs-in-r-with-igraph #