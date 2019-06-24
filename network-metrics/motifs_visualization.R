library(ggplot2)
library(directlabels)

# motif conductances visualization #
conductances_case118 = read.csv("conductances_case118.csv", row.names = 1)
colnames(conductances_case118) = c(1:dim(conductances_case118)[2])

# find which motif's conductances always equals to 0 #
row_sum_motifs = rowSums(conductances_case118)
motifs_with_zero_conductances = which(row_sum_motifs == 0)

new_conductances_case118 = conductances_case118[-motifs_with_zero_conductances,] # m5, m8, m9, m10

new_conductances_case118_df = data.frame(Motifs = factor(rep(rownames(new_conductances_case118),each = dim(conductances_case118)[2])),
                                         conductances = c(as.numeric(new_conductances_case118[1,]),
                                                          as.numeric(new_conductances_case118[2,]),
                                                          as.numeric(new_conductances_case118[3,]),
                                                          as.numeric(new_conductances_case118[4,])),
                                         sigma = rep(c(1:dim(conductances_case118)[2]),4))
p1= ggplot(data = new_conductances_case118_df, aes(x=sigma, y =conductances ,group=Motifs, color = Motifs))+geom_line(size=1,aes(linetype  = Motifs))

p2= p1+ scale_color_manual(values=c("#009E73", "red", "#E69F00", "blue"))+theme_light(base_size = 20)+
  scale_x_continuous("Sets",trans='log2') +scale_y_continuous("Motif conductance",breaks=seq(0,1,0.1),limits = c(0, 1),labels = seq(0,1,0.1))+
  ggtitle("Case118 IEEE: Observation (weighted motif adjacency matrix)")+theme(plot.title = element_text(hjust = 0.5))


# visualization: 3-node motifs (directed) - regular for all nodes # # columns from m1 to m16
reg_3_node_motifs = matrix(NA, nrow = 101, ncol = 16)
for (i in c(2:102)) {
  sim_tmp_graph  = simplify(output_graph_under_attack_f(case_118_network = input_graph, initial_status_row = 2, sequence_row = i))
  reg_3_node_motifs[i-1,] = triad_census(sim_tmp_graph)
}

# visualization: 3-node motifs (undirected) - regular for all nodes #
reg_3_node_motifs_undirected = matrix(NA, nrow = 101, ncol = 2) # columns from m1 to m2 #
for (i in c(2:102)) {
  sim_tmp_graph  = simplify(output_graph_under_attack_f(case_118_network = input_graph, initial_status_row = 2, sequence_row = i))
  sim_tmp_graph = as.undirected(sim_tmp_graph)
  reg_3_node_motifs_undirected[i-1,] = motifs(sim_tmp_graph, size = 3)[c(3:4)]
}

# visualization: 4-node motifs (undirected) - regular for all nodes #
reg_4_node_motifs_undirected = matrix(NA, nrow = 101, ncol = 6) # columns from m1 to m6 #
for (i in c(2:102)) {
  sim_tmp_graph  = simplify(output_graph_under_attack_f(case_118_network = input_graph, initial_status_row = 2, sequence_row = i))
  sim_tmp_graph = as.undirected(sim_tmp_graph)
  reg_4_node_motifs_undirected[i-1,] = motifs(sim_tmp_graph, size = 4)[c(5,7,8,9,10,11)]
}

# visualization: the size of maximum clique (undirected) - regular for all nodes #
size_max_clique_undirected = matrix(NA, nrow = 101, ncol = 1) # only one column #
for (i in c(2:102)) {
  sim_tmp_graph  = simplify(output_graph_under_attack_f(case_118_network = input_graph, initial_status_row = 2, sequence_row = i))
  sim_tmp_graph = as.undirected(sim_tmp_graph)
  size_max_clique_undirected[i-1,1] = clique_num(sim_tmp_graph)
}

# visualization: 3-node motifs for bus, load, generator, generator&load (directed) #
bus_3_node_motifs_mat = matrix(NA, nrow = 101, ncol = 16)
load_3_node_motifs_mat = matrix(NA, nrow = 101, ncol = 16)
generator_3_node_motifs_mat = matrix(NA, nrow = 101, ncol = 16)
gl_3_node_motifs_mat = matrix(NA, nrow = 101, ncol = 16)
for (ii in c(2:102)) {
  sim_tmp_graph  = simplify(output_graph_under_attack_f(case_118_network = input_graph, initial_status_row = 2, sequence_row = ii))
  motifs_matrix = matrix(NA, nrow = length(V(sim_tmp_graph)), ncol = 16)
  rownames(motifs_matrix) = vertex_attr(sim_tmp_graph)$name
  for (i in 1:length(V(sim_tmp_graph))) {
    
    subGraph = graph.neighborhood(sim_tmp_graph, order = 1, V(sim_tmp_graph)$name[i], mode = 'all')[[1]]
    allMotifs = triad_census(subGraph)
    removeNode = delete_vertices(subGraph, V(sim_tmp_graph)$name[i])
    single_node_Motifs = allMotifs - triad_census(removeNode)
    motifs_matrix[i,] = single_node_Motifs
  }
  
  sum(is.na(motifs_matrix)) == 0
  
  diff_types_motifs_matrix = matrix(0, nrow = 4, ncol = 16)
  for (j in c(1:4)) {
    if(sum(vertex_attr(sim_tmp_graph)$feature == j) > 0){
      tmp_node_feature_label = which(vertex_attr(sim_tmp_graph)$feature == j)
      diff_types_motifs_matrix[j,] = colSums(motifs_matrix[tmp_node_feature_label,, drop = FALSE])}
  }
  rownames(diff_types_motifs_matrix) = c("Bus","Load","Generator","Generator_and_Load")
  bus_3_node_motifs_mat[ii-1,] = diff_types_motifs_matrix[1,]
  load_3_node_motifs_mat[ii-1,] = diff_types_motifs_matrix[2,]
  generator_3_node_motifs_mat[ii-1,] = diff_types_motifs_matrix[3,]
  gl_3_node_motifs_mat[ii-1,] = diff_types_motifs_matrix[4,]
}

# below is for conductance #
for (i in c(2:102)) {
  sim_tmp_graph  = simplify(output_graph_under_attack_f(case_118_network = input_graph, initial_status_row = 2, sequence_row = i))
  tmp_adj_matrix = as.matrix(get.adjacency(sim_tmp_graph))
  tmp_weight_matrix = as_adjacency_matrix(sim_tmp_graph,attr = "weight")
  tmp_weight_matrix = as.matrix(tmp_weight_matrix)
  write.csv(tmp_adj_matrix,paste0("adj_matrix_", i-2,".csv"))
  write.csv(tmp_weight_matrix,paste0("weight_matrix_", i-2,".csv"))
}
# over #

# generate motifs names #
three_node_motifs_label_directed = vector(length = 13)
for (i in 1:13) {
  three_node_motifs_label_directed[i] = paste("m",i,sep = "")
}

three_node_motifs_label_undirected = vector(length = 2)
for (i in 1:2) {
  three_node_motifs_label_undirected[i] = paste("m",i,sep = "")
}

four_node_motifs_label_undirected = vector(length = 6)
for (i in 1:6) {
  four_node_motifs_label_undirected[i] = paste("m",i,sep = "")
}

# generate complete #


# --------------------------------------Plotting------------------------------------ #
#------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------#
# for 3-node motifs directed #
main_part_reg_3_node_motifs = reg_3_node_motifs[,c(4:16)]
colnames(main_part_reg_3_node_motifs) = three_node_motifs_label_directed
concentration_main_part_reg_3_node_motifs = main_part_reg_3_node_motifs/sum(main_part_reg_3_node_motifs[1,])
# replace NaN with 0 #
concentration_main_part_reg_3_node_motifs[is.na(concentration_main_part_reg_3_node_motifs)] = 0
# over #
reg_3_node_motifs_df = data.frame(Motifs = factor(rep(colnames(concentration_main_part_reg_3_node_motifs),each = 101)),
                                         Motifs_remaining = c(as.numeric(concentration_main_part_reg_3_node_motifs[,1]),
                                                          as.numeric(concentration_main_part_reg_3_node_motifs[,2]),
                                                          as.numeric(concentration_main_part_reg_3_node_motifs[,3]),
                                                          as.numeric(concentration_main_part_reg_3_node_motifs[,4]),
                                                          as.numeric(concentration_main_part_reg_3_node_motifs[,5]),
                                                          as.numeric(concentration_main_part_reg_3_node_motifs[,6]),
                                                          as.numeric(concentration_main_part_reg_3_node_motifs[,7]),
                                                          as.numeric(concentration_main_part_reg_3_node_motifs[,8]),
                                                          as.numeric(concentration_main_part_reg_3_node_motifs[,9]),
                                                          as.numeric(concentration_main_part_reg_3_node_motifs[,10]),
                                                          as.numeric(concentration_main_part_reg_3_node_motifs[,11]),
                                                          as.numeric(concentration_main_part_reg_3_node_motifs[,12]),
                                                          as.numeric(concentration_main_part_reg_3_node_motifs[,13])),
                                         Time = rep(c(1:101),13))
p1_0= ggplot(data = reg_3_node_motifs_df, aes(x=Time, y =Motifs_remaining ,group=Motifs, color = Motifs))+geom_line(size=2,aes(linetype  = Motifs))+
  geom_dl(aes(label = Motifs), method = list(dl.combine("first.points", "last.points"), cex = 1.5))

p2_0= p1_0+theme_light(base_size = 20)+
  scale_x_continuous("Times",trans='log2') +scale_y_continuous("Motif concentration",breaks=seq(0,1,0.1),limits = c(0, 0.5),labels = seq(0,1,0.1))+
  ggtitle("Case118 IEEE: directed 3-node motif concentrations under random attack (1)")+theme(plot.title = element_text(hjust = 0.5))+
  theme(axis.text.x = element_text(face="bold", color="black", size=20),axis.text.y = element_text(face="bold", color="black", size=20))

# for minmax scaling #
minmax_scale <- function(x) {  
  (x - min(x))/(max(x) - min(x))}

minmax_main_part_reg_3_node_motifs = apply(main_part_reg_3_node_motifs,2 ,minmax_scale)
minmax_main_part_reg_3_node_motifs[is.na(minmax_main_part_reg_3_node_motifs)] = 0

minmax_reg_3_node_motifs_df = data.frame(Motifs = factor(rep(colnames(minmax_main_part_reg_3_node_motifs),each = 101)),
                                  Motifs_remaining = c(as.numeric(minmax_main_part_reg_3_node_motifs[,1]),
                                                       as.numeric(minmax_main_part_reg_3_node_motifs[,2]),
                                                       as.numeric(minmax_main_part_reg_3_node_motifs[,3]),
                                                       as.numeric(minmax_main_part_reg_3_node_motifs[,4]),
                                                       as.numeric(minmax_main_part_reg_3_node_motifs[,5]),
                                                       as.numeric(minmax_main_part_reg_3_node_motifs[,6]),
                                                       as.numeric(minmax_main_part_reg_3_node_motifs[,7]),
                                                       as.numeric(minmax_main_part_reg_3_node_motifs[,8]),
                                                       as.numeric(minmax_main_part_reg_3_node_motifs[,9]),
                                                       as.numeric(minmax_main_part_reg_3_node_motifs[,10]),
                                                       as.numeric(minmax_main_part_reg_3_node_motifs[,11]),
                                                       as.numeric(minmax_main_part_reg_3_node_motifs[,12]),
                                                       as.numeric(minmax_main_part_reg_3_node_motifs[,13])),
                                  Time = rep(c(1:101),13))
p1_1= ggplot(data = minmax_reg_3_node_motifs_df, aes(x=Time, y =Motifs_remaining ,group=Motifs, color = Motifs))+geom_line(size=2,aes(linetype  = Motifs))+
  geom_dl(aes(label = Motifs), method = list(dl.combine("first.points", "last.points"), cex = 1.5))

p2_1= p1_1+theme_light(base_size = 20)+
  scale_x_continuous("Times",trans='log2') +scale_y_continuous("Motif survival",breaks=seq(0,1,0.1),limits = c(0, 1),labels = seq(0,1,0.1))+
  ggtitle("Case118 IEEE: directed 3-node motif survival under random attack (2)")+theme(plot.title = element_text(hjust = 0.5))+
  theme(axis.text.x = element_text(face="bold", color="black", size=20),axis.text.y = element_text(face="bold", color="black", size=20))




#------------------------------------------------------------------------------------#
# for 3-node motifs (undirected) #
main_part_reg_3_node_motifs_undirected = reg_3_node_motifs_undirected
colnames(main_part_reg_3_node_motifs_undirected) = three_node_motifs_label_undirected
concentration_main_part_reg_3_node_motifs_undirected = main_part_reg_3_node_motifs_undirected/sum(main_part_reg_3_node_motifs_undirected[1,])
# replace NaN with 0 #
concentration_main_part_reg_3_node_motifs_undirected[is.na(concentration_main_part_reg_3_node_motifs_undirected)] = 0
# over #
reg_3_node_motifs_undirected_df = data.frame(Motifs = factor(rep(colnames(concentration_main_part_reg_3_node_motifs_undirected),each = 101)),
                                  Motifs_remaining = c(as.numeric(concentration_main_part_reg_3_node_motifs_undirected[,1]),
                                                       as.numeric(concentration_main_part_reg_3_node_motifs_undirected[,2])),
                                  Time = rep(c(1:101),2))
p1_2= ggplot(data = reg_3_node_motifs_undirected_df, aes(x=Time, y =Motifs_remaining ,group=Motifs, color = Motifs))+geom_line(size=2,aes(linetype  = Motifs))+
  geom_dl(aes(label = Motifs), method = list(dl.combine("first.points", "last.points"), cex = 1.5))

p2_2= p1_2+theme_light(base_size = 20)+
  scale_x_continuous("Times",trans='log2') +scale_y_continuous("Motif concentration",breaks=seq(0,1,0.1),limits = c(0, 1),labels = seq(0,1,0.1))+
  ggtitle("Case118 IEEE: undirected 3-node motif concentrations under random attack (1)")+theme(plot.title = element_text(hjust = 0.5))+
  theme(axis.text.x = element_text(face="bold", color="black", size=20),axis.text.y = element_text(face="bold", color="black", size=20))

# for minmax scaling #
minmax_scale <- function(x) {  
  (x - min(x))/(max(x) - min(x))}

minmax_main_part_reg_3_node_motifs_undirected = apply(main_part_reg_3_node_motifs_undirected,2 ,minmax_scale)
minmax_main_part_reg_3_node_motifs_undirected[is.na(minmax_main_part_reg_3_node_motifs_undirected)] = 0

minmax_reg_3_node_motifs_undirected_df = data.frame(Motifs = factor(rep(colnames(minmax_main_part_reg_3_node_motifs_undirected),each = 101)),
                                         Motifs_remaining = c(as.numeric(minmax_main_part_reg_3_node_motifs_undirected[,1]),
                                                              as.numeric(minmax_main_part_reg_3_node_motifs_undirected[,2])),
                                         Time = rep(c(1:101),2))
p1_3= ggplot(data = minmax_reg_3_node_motifs_undirected_df, aes(x=Time, y =Motifs_remaining ,group=Motifs, color = Motifs))+geom_line(size=2,aes(linetype  = Motifs))+
  geom_dl(aes(label = Motifs), method = list(dl.combine("first.points", "last.points"), cex = 1.5))

p2_3= p1_3+theme_light(base_size = 20)+
  scale_x_continuous("Times",trans='log2') +scale_y_continuous("Motif survival",breaks=seq(0,1,0.1),limits = c(0, 1),labels = seq(0,1,0.1))+
  ggtitle("Case118 IEEE: undirected 3-node motif survival under random attack (2)")+theme(plot.title = element_text(hjust = 0.5))+
  theme(axis.text.x = element_text(face="bold", color="black", size=20),axis.text.y = element_text(face="bold", color="black", size=20))





#------------------------------------------------------------------------------------#
# for 4-node motifs (undirected) #
colnames(reg_4_node_motifs_undirected) = four_node_motifs_label_undirected
concentration_reg_4_node_motifs_undirected = reg_4_node_motifs_undirected/sum(reg_4_node_motifs_undirected[1,])
# replace NaN with 0 #
concentration_reg_4_node_motifs_undirected[is.na(concentration_reg_4_node_motifs_undirected)] = 0
# over #
reg_4_node_motifs_undirected_df = data.frame(Motifs = factor(rep(colnames(concentration_reg_4_node_motifs_undirected),each = 101)),
                                             Motifs_remaining = c(as.numeric(concentration_reg_4_node_motifs_undirected[,1]),
                                                                  as.numeric(concentration_reg_4_node_motifs_undirected[,2]),
                                                                  as.numeric(concentration_reg_4_node_motifs_undirected[,3]),
                                                                  as.numeric(concentration_reg_4_node_motifs_undirected[,4]),
                                                                  as.numeric(concentration_reg_4_node_motifs_undirected[,5]),
                                                                  as.numeric(concentration_reg_4_node_motifs_undirected[,6])),
                                             Time = rep(c(1:101),6))
p1_4= ggplot(data = reg_4_node_motifs_undirected_df, aes(x=Time, y =Motifs_remaining ,group=Motifs, color = Motifs))+geom_line(size=2,aes(linetype  = Motifs))+
  geom_dl(aes(label = Motifs), method = list(dl.combine("first.points", "last.points"), cex = 1.5))

p2_4= p1_4+theme_light(base_size = 20)+
  scale_x_continuous("Times",trans='log2') +scale_y_continuous("Motif concentration",breaks=seq(0,1,0.1),limits = c(0, 0.7),labels = seq(0,1,0.1))+
  ggtitle("Case118 IEEE: undirected 4-node motif concentrations under random attack (1)")+theme(plot.title = element_text(hjust = 0.5))+
  theme(axis.text.x = element_text(face="bold", color="black", size=20),axis.text.y = element_text(face="bold", color="black", size=20))

# for minmax scaling #
minmax_scale <- function(x) {  
  (x - min(x))/(max(x) - min(x))}

minmax_reg_4_node_motifs_undirected = apply(reg_4_node_motifs_undirected,2 ,minmax_scale)
minmax_reg_4_node_motifs_undirected[is.na(minmax_reg_4_node_motifs_undirected)] = 0

minmax_reg_4_node_motifs_undirected_df = data.frame(Motifs = factor(rep(colnames(minmax_reg_4_node_motifs_undirected),each = 101)),
                                                    Motifs_remaining = c(as.numeric(minmax_reg_4_node_motifs_undirected[,1]),
                                                                         as.numeric(minmax_reg_4_node_motifs_undirected[,2]),
                                                                         as.numeric(minmax_reg_4_node_motifs_undirected[,3]),
                                                                         as.numeric(minmax_reg_4_node_motifs_undirected[,4]),
                                                                         as.numeric(minmax_reg_4_node_motifs_undirected[,5]),
                                                                         as.numeric(minmax_reg_4_node_motifs_undirected[,6])),
                                                    Time = rep(c(1:101),6))
p1_5= ggplot(data = minmax_reg_4_node_motifs_undirected_df, aes(x=Time, y =Motifs_remaining ,group=Motifs, color = Motifs))+geom_line(size=2,aes(linetype  = Motifs))+
  geom_dl(aes(label = Motifs), method = list(dl.combine("first.points", "last.points"), cex = 1.5))

p2_5= p1_5+theme_light(base_size = 20)+
  scale_x_continuous("Times",trans='log2') +scale_y_continuous("Motif survival",breaks=seq(0,1,0.1),limits = c(0, 1),labels = seq(0,1,0.1))+
  ggtitle("Case118 IEEE: undirected 4-node motif survival under random attack (2)")+theme(plot.title = element_text(hjust = 0.5))+
  theme(axis.text.x = element_text(face="bold", color="black", size=20),axis.text.y = element_text(face="bold", color="black", size=20))



#------------------------------------------------------------------------------------#
# for the size of the maximal clique #
size_max_clique_df = data.frame(size = size_max_clique_undirected[,1], Time = c(1:101))
p1_6= ggplot(data = size_max_clique_df, aes(x=Time, y =size))+geom_line(size=2)

p2_6= p1_6+theme_light(base_size = 20)+
  scale_x_continuous("Times") +scale_y_continuous("Maximum clique size",breaks=seq(0,4,1),limits = c(0, 4),labels = seq(0,4,1))+
  ggtitle("Case118 IEEE: maximum clique size under random attack")+theme(plot.title = element_text(hjust = 0.5))+
  theme(axis.text.x = element_text(face="bold", color="black", size=20),axis.text.y = element_text(face="bold", color="black", size=20))



#------------------------------------------------------------------------------------#
# for 3-node motifs directed - BUS case #
main_part_bus_3_node_motifs_mat = bus_3_node_motifs_mat[,c(4:16)]
colnames(main_part_bus_3_node_motifs_mat) = three_node_motifs_label_directed
concentration_main_part_bus_3_node_motifs_mat = main_part_bus_3_node_motifs_mat/sum(main_part_bus_3_node_motifs_mat[1,])
# replace NaN with 0 #
concentration_main_part_bus_3_node_motifs_mat[is.na(concentration_main_part_bus_3_node_motifs_mat)] = 0
# over #
concentration_main_part_bus_3_node_motifs_mat_df = data.frame(Motifs = factor(rep(colnames(concentration_main_part_bus_3_node_motifs_mat),each = 101)),
                                  Motifs_remaining = c(as.numeric(concentration_main_part_bus_3_node_motifs_mat[,1]),
                                                       as.numeric(concentration_main_part_bus_3_node_motifs_mat[,2]),
                                                       as.numeric(concentration_main_part_bus_3_node_motifs_mat[,3]),
                                                       as.numeric(concentration_main_part_bus_3_node_motifs_mat[,4]),
                                                       as.numeric(concentration_main_part_bus_3_node_motifs_mat[,5]),
                                                       as.numeric(concentration_main_part_bus_3_node_motifs_mat[,6]),
                                                       as.numeric(concentration_main_part_bus_3_node_motifs_mat[,7]),
                                                       as.numeric(concentration_main_part_bus_3_node_motifs_mat[,8]),
                                                       as.numeric(concentration_main_part_bus_3_node_motifs_mat[,9]),
                                                       as.numeric(concentration_main_part_bus_3_node_motifs_mat[,10]),
                                                       as.numeric(concentration_main_part_bus_3_node_motifs_mat[,11]),
                                                       as.numeric(concentration_main_part_bus_3_node_motifs_mat[,12]),
                                                       as.numeric(concentration_main_part_bus_3_node_motifs_mat[,13])),
                                  Time = rep(c(1:101),13))
p1_7= ggplot(data = concentration_main_part_bus_3_node_motifs_mat_df, aes(x=Time, y =Motifs_remaining ,group=Motifs, color = Motifs))+geom_line(size=2,aes(linetype  = Motifs))+
  geom_dl(aes(label = Motifs), method = list(dl.combine("first.points", "last.points"), cex = 1.5))

p2_7= p1_7+theme_light(base_size = 20)+
  scale_x_continuous("Times",trans='log2') +scale_y_continuous("Motif concentration",breaks=seq(0,1,0.1),limits = c(0, 0.5),labels = seq(0,1,0.1))+
  ggtitle("Case118 IEEE: Bus: directed 3-node motif concentrations under random attack (1)")+theme(plot.title = element_text(hjust = 0.5))+
  theme(axis.text.x = element_text(face="bold", color="black", size=20),axis.text.y = element_text(face="bold", color="black", size=20))

# for minmax scaling #
minmax_scale <- function(x) {  
  (x - min(x))/(max(x) - min(x))}

minmax_main_part_bus_3_node_motifs_mat = apply(main_part_bus_3_node_motifs_mat,2 ,minmax_scale)
minmax_main_part_bus_3_node_motifs_mat[is.na(minmax_main_part_bus_3_node_motifs_mat)] = 0

minmax_main_part_bus_3_node_motifs_mat_df = data.frame(Motifs = factor(rep(colnames(minmax_main_part_bus_3_node_motifs_mat),each = 101)),
                                         Motifs_remaining = c(as.numeric(minmax_main_part_bus_3_node_motifs_mat[,1]),
                                                              as.numeric(minmax_main_part_bus_3_node_motifs_mat[,2]),
                                                              as.numeric(minmax_main_part_bus_3_node_motifs_mat[,3]),
                                                              as.numeric(minmax_main_part_bus_3_node_motifs_mat[,4]),
                                                              as.numeric(minmax_main_part_bus_3_node_motifs_mat[,5]),
                                                              as.numeric(minmax_main_part_bus_3_node_motifs_mat[,6]),
                                                              as.numeric(minmax_main_part_bus_3_node_motifs_mat[,7]),
                                                              as.numeric(minmax_main_part_bus_3_node_motifs_mat[,8]),
                                                              as.numeric(minmax_main_part_bus_3_node_motifs_mat[,9]),
                                                              as.numeric(minmax_main_part_bus_3_node_motifs_mat[,10]),
                                                              as.numeric(minmax_main_part_bus_3_node_motifs_mat[,11]),
                                                              as.numeric(minmax_main_part_bus_3_node_motifs_mat[,12]),
                                                              as.numeric(minmax_main_part_bus_3_node_motifs_mat[,13])),
                                         Time = rep(c(1:101),13))
p1_8= ggplot(data = minmax_main_part_bus_3_node_motifs_mat_df, aes(x=Time, y =Motifs_remaining ,group=Motifs, color = Motifs))+geom_line(size=2,aes(linetype  = Motifs))+
  geom_dl(aes(label = Motifs), method = list(dl.combine("first.points", "last.points"), cex = 1.5))

p2_8= p1_8+theme_light(base_size = 20)+
  scale_x_continuous("Times",trans='log2') +scale_y_continuous("Motif survival",breaks=seq(0,1,0.1),limits = c(0, 1),labels = seq(0,1,0.1))+
  ggtitle("Case118 IEEE: Bus: directed 3-node motif survival under random attack (2)")+theme(plot.title = element_text(hjust = 0.5))+
  theme(axis.text.x = element_text(face="bold", color="black", size=20),axis.text.y = element_text(face="bold", color="black", size=20))



#------------------------------------------------------------------------------------#
# for 3-node motifs directed - LOAD case #
main_part_load_3_node_motifs_mat = load_3_node_motifs_mat[,c(4:16)]
colnames(main_part_load_3_node_motifs_mat) = three_node_motifs_label_directed
concentration_main_part_load_3_node_motifs_mat = main_part_load_3_node_motifs_mat/sum(main_part_load_3_node_motifs_mat[1,])
# replace NaN with 0 #
concentration_main_part_load_3_node_motifs_mat[is.na(concentration_main_part_load_3_node_motifs_mat)] = 0
# over #
concentration_main_part_load_3_node_motifs_mat_df = data.frame(Motifs = factor(rep(colnames(concentration_main_part_load_3_node_motifs_mat),each = 101)),
                                                              Motifs_remaining = c(as.numeric(concentration_main_part_load_3_node_motifs_mat[,1]),
                                                                                   as.numeric(concentration_main_part_load_3_node_motifs_mat[,2]),
                                                                                   as.numeric(concentration_main_part_load_3_node_motifs_mat[,3]),
                                                                                   as.numeric(concentration_main_part_load_3_node_motifs_mat[,4]),
                                                                                   as.numeric(concentration_main_part_load_3_node_motifs_mat[,5]),
                                                                                   as.numeric(concentration_main_part_load_3_node_motifs_mat[,6]),
                                                                                   as.numeric(concentration_main_part_load_3_node_motifs_mat[,7]),
                                                                                   as.numeric(concentration_main_part_load_3_node_motifs_mat[,8]),
                                                                                   as.numeric(concentration_main_part_load_3_node_motifs_mat[,9]),
                                                                                   as.numeric(concentration_main_part_load_3_node_motifs_mat[,10]),
                                                                                   as.numeric(concentration_main_part_load_3_node_motifs_mat[,11]),
                                                                                   as.numeric(concentration_main_part_load_3_node_motifs_mat[,12]),
                                                                                   as.numeric(concentration_main_part_load_3_node_motifs_mat[,13])),
                                                              Time = rep(c(1:101),13))
p1_9= ggplot(data = concentration_main_part_load_3_node_motifs_mat_df, aes(x=Time, y =Motifs_remaining ,group=Motifs, color = Motifs))+geom_line(size=2,aes(linetype  = Motifs))+
  geom_dl(aes(label = Motifs), method = list(dl.combine("first.points", "last.points"), cex = 1.5))

p2_9= p1_9+theme_light(base_size = 20)+
  scale_x_continuous("Times",trans='log2') +scale_y_continuous("Motif concentration",breaks=seq(0,1,0.1),limits = c(0, 0.6),labels = seq(0,1,0.1))+
  ggtitle("Case118 IEEE: Load: directed 3-node motif concentrations under random attack (1)")+theme(plot.title = element_text(hjust = 0.5))+
  theme(axis.text.x = element_text(face="bold", color="black", size=20),axis.text.y = element_text(face="bold", color="black", size=20))

# for minmax scaling #
minmax_scale <- function(x) {  
  (x - min(x))/(max(x) - min(x))}

minmax_main_part_load_3_node_motifs_mat = apply(main_part_load_3_node_motifs_mat,2 ,minmax_scale)
minmax_main_part_load_3_node_motifs_mat[is.na(minmax_main_part_load_3_node_motifs_mat)] = 0

minmax_main_part_load_3_node_motifs_mat_df = data.frame(Motifs = factor(rep(colnames(minmax_main_part_load_3_node_motifs_mat),each = 101)),
                                                       Motifs_remaining = c(as.numeric(minmax_main_part_load_3_node_motifs_mat[,1]),
                                                                            as.numeric(minmax_main_part_load_3_node_motifs_mat[,2]),
                                                                            as.numeric(minmax_main_part_load_3_node_motifs_mat[,3]),
                                                                            as.numeric(minmax_main_part_load_3_node_motifs_mat[,4]),
                                                                            as.numeric(minmax_main_part_load_3_node_motifs_mat[,5]),
                                                                            as.numeric(minmax_main_part_load_3_node_motifs_mat[,6]),
                                                                            as.numeric(minmax_main_part_load_3_node_motifs_mat[,7]),
                                                                            as.numeric(minmax_main_part_load_3_node_motifs_mat[,8]),
                                                                            as.numeric(minmax_main_part_load_3_node_motifs_mat[,9]),
                                                                            as.numeric(minmax_main_part_load_3_node_motifs_mat[,10]),
                                                                            as.numeric(minmax_main_part_load_3_node_motifs_mat[,11]),
                                                                            as.numeric(minmax_main_part_load_3_node_motifs_mat[,12]),
                                                                            as.numeric(minmax_main_part_load_3_node_motifs_mat[,13])),
                                                       Time = rep(c(1:101),13))
p1_10= ggplot(data = minmax_main_part_load_3_node_motifs_mat_df, aes(x=Time, y =Motifs_remaining ,group=Motifs, color = Motifs))+geom_line(size=2,aes(linetype  = Motifs))+
  geom_dl(aes(label = Motifs), method = list(dl.combine("first.points", "last.points"), cex = 1.5))

p2_10= p1_10+theme_light(base_size = 20)+
  scale_x_continuous("Times",trans='log2') +scale_y_continuous("Motif survival",breaks=seq(0,1,0.1),limits = c(0, 1),labels = seq(0,1,0.1))+
  ggtitle("Case118 IEEE: Load: directed 3-node motif survival under random attack (2)")+theme(plot.title = element_text(hjust = 0.5))+
  theme(axis.text.x = element_text(face="bold", color="black", size=20),axis.text.y = element_text(face="bold", color="black", size=20))





#------------------------------------------------------------------------------------#
# for 3-node motifs directed - GENERATOR case #
main_part_generator_3_node_motifs_mat = generator_3_node_motifs_mat[,c(4:16)]
colnames(main_part_generator_3_node_motifs_mat) = three_node_motifs_label_directed
concentration_main_part_generator_3_node_motifs_mat = main_part_generator_3_node_motifs_mat/sum(main_part_generator_3_node_motifs_mat[1,])
# replace NaN with 0 #
concentration_main_part_generator_3_node_motifs_mat[is.na(concentration_main_part_generator_3_node_motifs_mat)] = 0
# over #
concentration_main_part_generator_3_node_motifs_mat_df = data.frame(Motifs = factor(rep(colnames(concentration_main_part_generator_3_node_motifs_mat),each = 101)),
                                                               Motifs_remaining = c(as.numeric(concentration_main_part_generator_3_node_motifs_mat[,1]),
                                                                                    as.numeric(concentration_main_part_generator_3_node_motifs_mat[,2]),
                                                                                    as.numeric(concentration_main_part_generator_3_node_motifs_mat[,3]),
                                                                                    as.numeric(concentration_main_part_generator_3_node_motifs_mat[,4]),
                                                                                    as.numeric(concentration_main_part_generator_3_node_motifs_mat[,5]),
                                                                                    as.numeric(concentration_main_part_generator_3_node_motifs_mat[,6]),
                                                                                    as.numeric(concentration_main_part_generator_3_node_motifs_mat[,7]),
                                                                                    as.numeric(concentration_main_part_generator_3_node_motifs_mat[,8]),
                                                                                    as.numeric(concentration_main_part_generator_3_node_motifs_mat[,9]),
                                                                                    as.numeric(concentration_main_part_generator_3_node_motifs_mat[,10]),
                                                                                    as.numeric(concentration_main_part_generator_3_node_motifs_mat[,11]),
                                                                                    as.numeric(concentration_main_part_generator_3_node_motifs_mat[,12]),
                                                                                    as.numeric(concentration_main_part_generator_3_node_motifs_mat[,13])),
                                                               Time = rep(c(1:101),13))
p1_11= ggplot(data = concentration_main_part_generator_3_node_motifs_mat_df, aes(x=Time, y =Motifs_remaining ,group=Motifs, color = Motifs))+geom_line(size=2,aes(linetype  = Motifs))+
  geom_dl(aes(label = Motifs), method = list(dl.combine("first.points", "last.points"), cex = 1.5))

p2_11= p1_11+theme_light(base_size = 20)+
  scale_x_continuous("Times",trans='log2') +scale_y_continuous("Motif concentration",breaks=seq(0,1,0.1),limits = c(0, 0.6),labels = seq(0,1,0.1))+
  ggtitle("Case118 IEEE: Generator: directed 3-node motif concentrations under random attack (1)")+theme(plot.title = element_text(hjust = 0.5))+
  theme(axis.text.x = element_text(face="bold", color="black", size=20),axis.text.y = element_text(face="bold", color="black", size=20))

# for minmax scaling #
minmax_scale <- function(x) {  
  (x - min(x))/(max(x) - min(x))}

minmax_main_part_generator_3_node_motifs_mat = apply(main_part_generator_3_node_motifs_mat,2 ,minmax_scale)
minmax_main_part_generator_3_node_motifs_mat[is.na(minmax_main_part_generator_3_node_motifs_mat)] = 0

minmax_main_part_generator_3_node_motifs_mat_df = data.frame(Motifs = factor(rep(colnames(minmax_main_part_generator_3_node_motifs_mat),each = 101)),
                                                        Motifs_remaining = c(as.numeric(minmax_main_part_generator_3_node_motifs_mat[,1]),
                                                                             as.numeric(minmax_main_part_generator_3_node_motifs_mat[,2]),
                                                                             as.numeric(minmax_main_part_generator_3_node_motifs_mat[,3]),
                                                                             as.numeric(minmax_main_part_generator_3_node_motifs_mat[,4]),
                                                                             as.numeric(minmax_main_part_generator_3_node_motifs_mat[,5]),
                                                                             as.numeric(minmax_main_part_generator_3_node_motifs_mat[,6]),
                                                                             as.numeric(minmax_main_part_generator_3_node_motifs_mat[,7]),
                                                                             as.numeric(minmax_main_part_generator_3_node_motifs_mat[,8]),
                                                                             as.numeric(minmax_main_part_generator_3_node_motifs_mat[,9]),
                                                                             as.numeric(minmax_main_part_generator_3_node_motifs_mat[,10]),
                                                                             as.numeric(minmax_main_part_generator_3_node_motifs_mat[,11]),
                                                                             as.numeric(minmax_main_part_generator_3_node_motifs_mat[,12]),
                                                                             as.numeric(minmax_main_part_generator_3_node_motifs_mat[,13])),
                                                        Time = rep(c(1:101),13))
p1_12= ggplot(data = minmax_main_part_generator_3_node_motifs_mat_df, aes(x=Time, y =Motifs_remaining ,group=Motifs, color = Motifs))+geom_line(size=2,aes(linetype  = Motifs))+
  geom_dl(aes(label = Motifs), method = list(dl.combine("first.points", "last.points"), cex = 1.5))

p2_12= p1_12+theme_light(base_size = 20)+
  scale_x_continuous("Times",trans='log2') +scale_y_continuous("Motif survival",breaks=seq(0,1,0.1),limits = c(0, 1),labels = seq(0,1,0.1))+
  ggtitle("Case118 IEEE: Generator: directed 3-node motif survival under random attack (2)")+theme(plot.title = element_text(hjust = 0.5))+
  theme(axis.text.x = element_text(face="bold", color="black", size=20),axis.text.y = element_text(face="bold", color="black", size=20))




#------------------------------------------------------------------------------------#
# for 3-node motifs directed - GENERATOR & LOAD case #
main_part_gl_3_node_motifs_mat = gl_3_node_motifs_mat[,c(4:16)]
colnames(main_part_gl_3_node_motifs_mat) = three_node_motifs_label_directed
concentration_main_part_gl_3_node_motifs_mat = main_part_gl_3_node_motifs_mat/sum(main_part_gl_3_node_motifs_mat[1,])
# replace NaN with 0 #
concentration_main_part_gl_3_node_motifs_mat[is.na(concentration_main_part_gl_3_node_motifs_mat)] = 0
# over #
concentration_main_part_gl_3_node_motifs_mat_df = data.frame(Motifs = factor(rep(colnames(concentration_main_part_gl_3_node_motifs_mat),each = 101)),
                                                                    Motifs_remaining = c(as.numeric(concentration_main_part_gl_3_node_motifs_mat[,1]),
                                                                                         as.numeric(concentration_main_part_gl_3_node_motifs_mat[,2]),
                                                                                         as.numeric(concentration_main_part_gl_3_node_motifs_mat[,3]),
                                                                                         as.numeric(concentration_main_part_gl_3_node_motifs_mat[,4]),
                                                                                         as.numeric(concentration_main_part_gl_3_node_motifs_mat[,5]),
                                                                                         as.numeric(concentration_main_part_gl_3_node_motifs_mat[,6]),
                                                                                         as.numeric(concentration_main_part_gl_3_node_motifs_mat[,7]),
                                                                                         as.numeric(concentration_main_part_gl_3_node_motifs_mat[,8]),
                                                                                         as.numeric(concentration_main_part_gl_3_node_motifs_mat[,9]),
                                                                                         as.numeric(concentration_main_part_gl_3_node_motifs_mat[,10]),
                                                                                         as.numeric(concentration_main_part_gl_3_node_motifs_mat[,11]),
                                                                                         as.numeric(concentration_main_part_gl_3_node_motifs_mat[,12]),
                                                                                         as.numeric(concentration_main_part_gl_3_node_motifs_mat[,13])),
                                                                    Time = rep(c(1:101),13))
p1_13= ggplot(data = concentration_main_part_gl_3_node_motifs_mat_df, aes(x=Time, y =Motifs_remaining ,group=Motifs, color = Motifs))+geom_line(size=2,aes(linetype  = Motifs))+
  geom_dl(aes(label = Motifs), method = list(dl.combine("first.points", "last.points"), cex = 1.5))

p2_13= p1_13+theme_light(base_size = 20)+
  scale_x_continuous("Times",trans='log2') +scale_y_continuous("Motif concentration",breaks=seq(0,1,0.1),limits = c(0, 0.5),labels = seq(0,1,0.1))+
  ggtitle("Case118 IEEE: Generator&Load: directed 3-node motif concentrations under random attack (1)")+theme(plot.title = element_text(hjust = 0.5))+
  theme(axis.text.x = element_text(face="bold", color="black", size=20),axis.text.y = element_text(face="bold", color="black", size=20))

# for minmax scaling #
minmax_scale <- function(x) {  
  (x - min(x))/(max(x) - min(x))}

minmax_main_part_gl_3_node_motifs_mat = apply(main_part_gl_3_node_motifs_mat,2 ,minmax_scale)
minmax_main_part_gl_3_node_motifs_mat[is.na(minmax_main_part_gl_3_node_motifs_mat)] = 0

minmax_main_part_gl_3_node_motifs_mat_df = data.frame(Motifs = factor(rep(colnames(minmax_main_part_gl_3_node_motifs_mat),each = 101)),
                                                             Motifs_remaining = c(as.numeric(minmax_main_part_gl_3_node_motifs_mat[,1]),
                                                                                  as.numeric(minmax_main_part_gl_3_node_motifs_mat[,2]),
                                                                                  as.numeric(minmax_main_part_gl_3_node_motifs_mat[,3]),
                                                                                  as.numeric(minmax_main_part_gl_3_node_motifs_mat[,4]),
                                                                                  as.numeric(minmax_main_part_gl_3_node_motifs_mat[,5]),
                                                                                  as.numeric(minmax_main_part_gl_3_node_motifs_mat[,6]),
                                                                                  as.numeric(minmax_main_part_gl_3_node_motifs_mat[,7]),
                                                                                  as.numeric(minmax_main_part_gl_3_node_motifs_mat[,8]),
                                                                                  as.numeric(minmax_main_part_gl_3_node_motifs_mat[,9]),
                                                                                  as.numeric(minmax_main_part_gl_3_node_motifs_mat[,10]),
                                                                                  as.numeric(minmax_main_part_gl_3_node_motifs_mat[,11]),
                                                                                  as.numeric(minmax_main_part_gl_3_node_motifs_mat[,12]),
                                                                                  as.numeric(minmax_main_part_gl_3_node_motifs_mat[,13])),
                                                             Time = rep(c(1:101),13))
p1_14= ggplot(data = minmax_main_part_gl_3_node_motifs_mat_df, aes(x=Time, y =Motifs_remaining ,group=Motifs, color = Motifs))+geom_line(size=2,aes(linetype  = Motifs))+
  geom_dl(aes(label = Motifs), method = list(dl.combine("first.points", "last.points"), cex = 1.5))

p2_14= p1_14+theme_light(base_size = 20)+
  scale_x_continuous("Times",trans='log2') +scale_y_continuous("Motif survival",breaks=seq(0,1,0.1),limits = c(0, 1),labels = seq(0,1,0.1))+
  ggtitle("Case118 IEEE: Generator&Load: directed 3-node motif survival under random attack (2)")+theme(plot.title = element_text(hjust = 0.5))+
  theme(axis.text.x = element_text(face="bold", color="black", size=20),axis.text.y = element_text(face="bold", color="black", size=20))

#------------------------------------------------------------------------------------#
# motif conductance change #
summary_motif_conductance = read.csv("summary_result.csv")
summary_motif_conductance = summary_motif_conductance[-102,]

for (kk in 1:101) {
  if(summary_motif_conductance[kk]!=0){
    summary_motif_conductance[kk] = summary_motif_conductance[kk]+1
  }
}

for (uu in 1:101) {
  if(summary_motif_conductance[uu]==1){
    summary_motif_conductance[uu]=7
  }else if(summary_motif_conductance[uu]==2){
    summary_motif_conductance[uu]=11
  }else if(summary_motif_conductance[uu]==3){
    summary_motif_conductance[uu]=12
  }else if(summary_motif_conductance[uu]==4){
    summary_motif_conductance[uu]=13
  }else if(summary_motif_conductance[uu]==5){
    summary_motif_conductance[uu]= 6
  }else if(summary_motif_conductance[uu]==6){
    summary_motif_conductance[uu]=9
  }else if(summary_motif_conductance[uu]==7){
    summary_motif_conductance[uu]=10
  }else if(summary_motif_conductance[uu]==8){
    summary_motif_conductance[uu]=1
  }else if(summary_motif_conductance[uu]==9){
    summary_motif_conductance[uu]=3
  }else if(summary_motif_conductance[uu]==10){
    summary_motif_conductance[uu]=2
  }else if(summary_motif_conductance[uu]==11){
    summary_motif_conductance[uu]=5
  }else if(summary_motif_conductance[uu]==12){
    summary_motif_conductance[uu]=4
  }else if(summary_motif_conductance[uu]==13){
    summary_motif_conductance[uu]=8
  }else{
    summary_motif_conductance[uu]=0
  }
}

summary_motif_conductance_df = data.frame(Motifs = summary_motif_conductance, Time = c(1:101))
p1_15= ggplot(data = summary_motif_conductance_df, aes(x=Time, y =Motifs))+geom_line(size=2)+geom_point(size=3.5,
                                                                                                        aes(colour = "red"))

p2_15= p1_15+theme_light(base_size = 20)+
  scale_x_continuous("Times") +scale_y_continuous("Motif with lower conductance",breaks=seq(0,13,1),limits = c(0, 13),labels = seq(0,13,1))+
  ggtitle("Case118 IEEE: motif conductance under random attack")+theme(plot.title = element_text(hjust = 0.5))+
  theme(axis.text.x = element_text(face="bold", color="black", size=20),axis.text.y = element_text(face="bold", color="black", size=20),legend.title = element_blank())+ theme(legend.position="none")

#------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------#
library(gridExtra)
grid.arrange(p2_0, p2_1, p2_2, p2_3,p2_4,p2_5,p2_7,
             p2_8, p2_9,p2_10,p2_11,p2_12,p2_13,p2_14,p2_6,p2_15,ncol=2)