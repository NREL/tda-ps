#setwd("/Users/yuzhouchen/Documents/")
data11 <- read.csv("...")

nodes_Germany<-data11[,c(2,3,4)][data11[,5]=="Germany",]
length(nodes_Germany$X)
ID_Germany<-data11[,2][data11[,5]=="Germany"]
Germany<-data11[(data11[,17] %in% ID_Germany) | (data11[,18] %in% ID_Germany)  , ] # or
Germany_data_all<-Germany[,c(16,17,18)] # 3-dimensions #1col: distance; #2col:from node; #3col: to node

#Here we consider the target network is undirected #
Germany_data_all_no_dup=unique(Germany_data_all)
Germany_data<-Germany_data_all_no_dup[,c(2,3)]   # Edge
Germany_edge=data.matrix(Germany_data)
Germany_network=graph_from_edgelist(Germany_edge,directed = F)

ed11<-c(as.vector(Germany_edge[,1]),as.vector(Germany_edge[,2]))
unique_ed11<-unique(ed11)
nodes_index=sort(unique_ed11)
m1<-max(nodes_index)
delete_nodes_index=setdiff(c(1:m1),nodes_index)
V(Germany_network)$name=V(Germany_network)

new_Germany_network=delete_vertices(Germany_network,delete_nodes_index)# no.nodes:445; no.edges 567

fraction = seq(0.01,0.1,0.01)
number = round(fraction*445) # 445 is the total number of nodes in Germany network

degree_sequence_german = sort(degree(new_Germany_network), decreasing = TRUE)

delete_nodes_index1 = as.integer(as.numeric(names(degree_sequence_german[1:number[1]])))
sub_german1  = delete_vertices(new_Germany_network, v = as.character(delete_nodes_index1))
attack_motif1 = motifs(sub_german1,size = 4)[c(5,7,8,9,10)] # actually should be [c(5,7,8,9,10,11)]; we omit 11 since we can not observe motif 6

res = matrix(NA, nrow = 10, ncol = 5)
for(i in 1:10){
  delete_nodes_index_temp = as.integer(as.numeric(names(degree_sequence_german[1:number[i]])))
  sub_german = delete_vertices(new_Germany_network, v = as.character(delete_nodes_index_temp))
  attack_motif_temp = motifs(sub_german,size = 4)[c(5,7,8,9,10)]
  res[i,] = attack_motif_temp
}
res_german = res
res_german = rbind(motifs(new_Germany_network,size = 4)[c(5,7,8,9,10)], res_german)
res_german = t(res_german) # where row represents types of motif and column represents number of attack times