setwd("Documents/NREL_works/")
library(igraph)
library(RCurl)
library(sna)

# read .dot file #
# first step is put the .dot file into Gephi and export the corresponding .csv file - here is graph_118_case #
case_118_graph = read.csv("graph_118_case.csv",sep = ";", header = TRUE, row.names = 1)
# actually we do not care about overlap and fase cols/rows; so we remove them out #
case_118_graph_final_version = case_118_graph[3:dim(case_118_graph)[2],3:dim(case_118_graph)[2]]

# separate bus, load, and thermal #
# include bus_ 's rows #
bus_index = colnames(case_118_graph_final_version) %in% grep('bus', colnames(case_118_graph_final_version), value=TRUE)
bus_part = case_118_graph_final_version[bus_index,bus_index]

# include bus_ 's rows #
bus_index = colnames(case_118_graph_final_version) %in% grep('bus', colnames(case_118_graph_final_version), value=TRUE)
bus_part = case_118_graph_final_version[bus_index,bus_index]
bus_part = as.matrix(bus_part)

# include load_ 's rows #
load_index = colnames(case_118_graph_final_version) %in% grep('load', colnames(case_118_graph_final_version), value=TRUE)
load_part = case_118_graph_final_version[bus_index,load_index]
load_part = as.matrix(load_part)

# include thermal_ 's rows #
thermal_index = colnames(case_118_graph_final_version) %in% grep('thermal', colnames(case_118_graph_final_version), value=TRUE)
thermal_part = case_118_graph_final_version[thermal_index,bus_index]
thermal_part = as.matrix(thermal_part)
# separate over #

# construct ieee 118 case graph structure #
case_118_network = graph_from_adjacency_matrix(as.matrix(bus_part), mode = "directed")

# add vertex feature in this case -> 1: regular bus; 2: load; 3: thermal/generator; 4: both load and thermal/generator #
# set vertex attributes -> function in igraph: set_vertex_attr(graph, name, index = V(graph), value) #

bus_attribute = vector(length = dim(bus_part)[1])
names(bus_attribute) = colnames(bus_part)
bus_color = vector(length = dim(bus_part)[1])

for (i in 1:dim(bus_part)[1]) {
  tmp_index = rownames(bus_part)[i]
  if(sum(load_part[tmp_index,])>=1 && sum(thermal_part[,tmp_index])>=1){
    bus_attribute[i] = 4
    bus_color[i] = "blue"
  }else if(sum(load_part[tmp_index,])>=1 && sum(thermal_part[,tmp_index])==0){
    bus_attribute[i] = 2
    bus_color[i] = "red"
  }else if(sum(load_part[tmp_index,])==0 && sum(thermal_part[,tmp_index])>=1){
    bus_attribute[i] = 3
    bus_color[i] = "green"
  }else{
    bus_attribute[i] = 1
    bus_color[i] = "yellow"
  }
}

case_118_network = case_118_network %>% set_vertex_attr("label", value = bus_attribute) %>% set_vertex_attr("color", value = bus_color)
V(case_118_network)$label = as.numeric(V(case_118_network)$label) 
# To review the feature of each node use the command -> vertex_attr(case_118_network) #

# > V(case_118_network)$name could show the vertex name, therefore we can change the vertex name through this way #

bus_label_reader = read.csv("bus_label_118ieee_case.csv",header = TRUE) #important .csv file after processing
bus_label = paste("b_",bus_label_reader[,2],sep = "")

# re-set vertex label #
V(case_118_network)$label = bus_label
V(case_118_network)$feature = bus_attribute

# till now, we consider vertex label, type of vertex, and the color corresponding to type of vertex #
# visualization ieee 118 initial state power system without any node removing #
plot(case_118_network, vertex.size = 5, edge.width  = 0.1, edge.color = "black", edge.arrow.size = 0.1)

case_118_network_vertex_final = case_118_network

# now we would try to deal with edge #
# > are.connected(case_118_network,"bus1","bus71") ->>> check whether two vertices are connected #
edge_label = read.csv("edge_label.csv",header = TRUE)
edge_label[,1] = as.character(edge_label[,1])
edge_label[,2] = as.character(edge_label[,2])

# there are some scenarios i.e., multiple edges between two vertices #
# For example: bus44 -> bus47 and bus44 -> bus27
selegoG <- induced_subgraph(case_118_network,unlist(ego(case_118_network,nodes = "bus44")))
plot(selegoG,vertex.label=V(selegoG)$name) #print by bus_ !
plot(selegoG,vertex.label=V(selegoG)$label) #print by b_ !

# get edgelist from case_118_network #
edgelist_case_118 = as.data.frame(get.edgelist(case_118_network))

#----#
# this step, we assign the edge label to each edge #
assigned_edge_label = vector(length = dim(edgelist_case_118)[1])
for (i in 1:length(assigned_edge_label)) {
  tmp_edge_label = do.call(paste0, edgelist_case_118) %in% do.call(paste0, edge_label[i,1:2])
  temp_edge_label2 = which(do.call(paste0, edgelist_case_118) == do.call(paste0, edge_label[i,1:2]))
  self_edge_label = do.call(paste0, edge_label[,1:2]) %in% do.call(paste0, edgelist_case_118[temp_edge_label2,])
  #print(sum(tmp_edge_label))
  if(sum(tmp_edge_label)==1){
  assigned_edge_label[tmp_edge_label] = edge_label[self_edge_label,3]}
  else{
    assigned_edge_label[tmp_edge_label] = edge_label[self_edge_label,3]
  }
}
#----#
case_118_network <- case_118_network %>% set_edge_attr("label", value = assigned_edge_label)
# edge label assign over #

# double check edges label - correct! #
#edge_attr(case_118_network)
#cbind(get.edgelist(case_118_network),edge_attr(case_118_network)$label)
#E(case_118_network)$label
# double check over #


coords = layout_nicely(case_118_network)
plot(case_118_network, vertex.size = 5, edge.width  = 0.5, 
     edge.color = "black", edge.arrow.size = 0.08,layout = coords,edge.label.cex=.7)

# here is the final version of case118_ieee origianl graph #
# case_118_network #
