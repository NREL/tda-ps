graph_structure_under_sequence_row_attack = output_graph_under_attack_f(case_118_network = input_graph, initial_status_row = 2, sequence_row = 5)
'''
len_Branch_F = length(edge_attr(graph_structure_under_sequence_row_attack)$Branch_F)

start_ratio_label = which(colnames(new_case118_result1)=="F_1")
end_ratio_label = which(colnames(new_case118_result1)=="F_186")
flow_ratio_vector = vector(length = len_Branch_F)
  
for (i in c(1:len_Branch_F)) {
  Flow_part = new_case118_result1[1, which(colnames(new_case118_result1)=="F_1"):which(colnames(new_case118_result1)=="F_186")]
  tmp_ratio_label = colnames(new_case118_result1)[c(start_ratio_label:end_ratio_label)] %in% edge_attr(graph_structure_under_sequence_row_attack)$Branch_F[i]
  if(sum(tmp_ratio_label)>0){
    flow_ratio_vector[i] = edge_attr(graph_structure_under_sequence_row_attack)$weight[i]/as.numeric(Flow_part[tmp_ratio_label])
  }
}

edge_attr(graph_structure_under_sequence_row_attack)$ratio_weight = flow_ratio_vector
'''
quantile_weight_ratio = quantile(edge_attr(graph_structure_under_sequence_row_attack)$ratio_weight)
# now we work on < 25%, < 50%, <75% #
below_nianwu_percent_label_num = which(edge_attr(graph_structure_under_sequence_row_attack)$ratio_weight<as.numeric(quantile_weight_ratio[2]))
below_nianwu_percent_Branch_f_label = edge_attr(graph_structure_under_sequence_row_attack)$Branch_f[below_nianwu_percent_label_num]

below_nianwu_temp_graph = graph_structure_under_sequence_row_attack %>% set_edge_attr("name", value = edge_attr(graph_structure_under_sequence_row_attack)$Branch_f)
below_nianwu_temp_graph = delete_edges(below_nianwu_temp_graph, below_nianwu_percent_Branch_f_label)

nianwu_percent_3_node_motifs = matrix(NA, nrow = 101, ncol = 13)
for (i in c(2:102)) {
  tmp_graph = output_graph_under_attack_f(case_118_network = input_graph, initial_status_row = 2, sequence_row = i)
  quantile_weight_ratio = quantile(edge_attr(tmp_graph)$ratio_weight)
  
  below_nianwu_percent_label_num = which(edge_attr(tmp_graph)$ratio_weight<as.numeric(quantile_weight_ratio[2]))
  below_nianwu_percent_Branch_f_label = edge_attr(tmp_graph)$Branch_f[below_nianwu_percent_label_num]
  
  below_nianwu_temp_graph = tmp_graph %>% set_edge_attr("name", value = edge_attr(tmp_graph)$Branch_f)
  below_nianwu_temp_graph = delete_edges(below_nianwu_temp_graph, below_nianwu_percent_Branch_f_label)
  
  sim_tmp_graph  = simplify(below_nianwu_temp_graph)
  nianwu_percent_3_node_motifs[i-1,] = triad_census(sim_tmp_graph)[4:16]
}


half_percent_3_node_motifs = matrix(NA, nrow = 101, ncol = 13)
for (i in c(2:102)) {
  tmp_graph = output_graph_under_attack_f(case_118_network = input_graph, initial_status_row = 2, sequence_row = i)
  quantile_weight_ratio = quantile(edge_attr(tmp_graph)$ratio_weight)
  
  below_nianwu_percent_label_num = which(edge_attr(tmp_graph)$ratio_weight<as.numeric(quantile_weight_ratio[3]))
  below_nianwu_percent_Branch_f_label = edge_attr(tmp_graph)$Branch_f[below_nianwu_percent_label_num]
  
  below_nianwu_temp_graph = tmp_graph %>% set_edge_attr("name", value = edge_attr(tmp_graph)$Branch_f)
  below_nianwu_temp_graph = delete_edges(below_nianwu_temp_graph, below_nianwu_percent_Branch_f_label)
  
  sim_tmp_graph  = simplify(below_nianwu_temp_graph)
  half_percent_3_node_motifs[i-1,] = triad_census(sim_tmp_graph)[4:16]
}

sevfif_percent_3_node_motifs = matrix(NA, nrow = 101, ncol = 13)
for (i in c(2:102)) {
  tmp_graph = output_graph_under_attack_f(case_118_network = input_graph, initial_status_row = 2, sequence_row = i)
  quantile_weight_ratio = quantile(edge_attr(tmp_graph)$ratio_weight)
  
  below_nianwu_percent_label_num = which(edge_attr(tmp_graph)$ratio_weight<as.numeric(quantile_weight_ratio[4]))
  below_nianwu_percent_Branch_f_label = edge_attr(tmp_graph)$Branch_f[below_nianwu_percent_label_num]
  
  below_nianwu_temp_graph = tmp_graph %>% set_edge_attr("name", value = edge_attr(tmp_graph)$Branch_f)
  below_nianwu_temp_graph = delete_edges(below_nianwu_temp_graph, below_nianwu_percent_Branch_f_label)
  
  sim_tmp_graph  = simplify(below_nianwu_temp_graph)
  sevfif_percent_3_node_motifs[i-1,] = triad_census(sim_tmp_graph)[4:16]
}

# we only simplify the graph after alpha filtering #

minmax_scale <- function(x) {  
  (x - min(x))/(max(x) - min(x))}


minmax_nianwu_percent_3_node_motifs = apply(nianwu_percent_3_node_motifs,2 ,minmax_scale)
colnames(minmax_nianwu_percent_3_node_motifs) = paste("m",1:13,sep = "")
minmax_nianwu_percent_3_node_motifs[is.na(minmax_nianwu_percent_3_node_motifs)] = 0
minmax_nianwu_percent_3_node_motifs = minmax_nianwu_percent_3_node_motifs[,-which(colSums(minmax_nianwu_percent_3_node_motifs)==0)]
minmax_nianwu_percent_3_node_motifs_df = data.frame(Motifs = factor(rep(c("LS",colnames(minmax_nianwu_percent_3_node_motifs)),each = 101)),
                                         Motifs_remaining = c(fraction_load_served,
                                                              as.numeric(minmax_nianwu_percent_3_node_motifs[,1]),
                                                              as.numeric(minmax_nianwu_percent_3_node_motifs[,2]),
                                                              as.numeric(minmax_nianwu_percent_3_node_motifs[,3]),
                                                              as.numeric(minmax_nianwu_percent_3_node_motifs[,4])),
                                         Time = rep(c(1:101),5))
p1_17= ggplot(data = minmax_nianwu_percent_3_node_motifs_df, aes(x=Time, y =Motifs_remaining ,group=Motifs, color = Motifs))+geom_line(size=2,aes(linetype  = Motifs))+
  geom_dl(aes(label = Motifs), method = list(dl.combine("first.points", "last.points"), cex = 1.5))

p2_17= p1_17+theme_light(base_size = 20)+
  scale_x_continuous("Times",trans='log2') +scale_y_continuous("Motif survival",breaks=seq(0,1,0.1),limits = c(0, 1),labels = seq(0,1,0.1))+
  ggtitle("Case118 IEEE: 25% case: directed 3-node motif survival under random attack")+theme(plot.title = element_text(hjust = 0.5))+
  theme(axis.text.x = element_text(face="bold", color="black", size=20),axis.text.y = element_text(face="bold", color="black", size=20))



#-------------------------------------------------------------------------------------#
minmax_half_percent_3_node_motifs = apply(half_percent_3_node_motifs,2 ,minmax_scale)
colnames(minmax_half_percent_3_node_motifs) = paste("m",1:13,sep = "")
minmax_half_percent_3_node_motifs[is.na(minmax_half_percent_3_node_motifs)] = 0
minmax_half_percent_3_node_motifs = minmax_half_percent_3_node_motifs[,-which(colSums(minmax_half_percent_3_node_motifs)==0)]
minmax_half_percent_3_node_motifs_df = data.frame(Motifs = factor(rep(c("LS",colnames(minmax_half_percent_3_node_motifs)),each = 101)),
                                                    Motifs_remaining = c(fraction_load_served,
                                                                         as.numeric(minmax_half_percent_3_node_motifs[,1]),
                                                                         as.numeric(minmax_half_percent_3_node_motifs[,2]),
                                                                         as.numeric(minmax_half_percent_3_node_motifs[,3]),
                                                                         as.numeric(minmax_half_percent_3_node_motifs[,4])),
                                                    Time = rep(c(1:101),5))
p1_18= ggplot(data = minmax_half_percent_3_node_motifs_df, aes(x=Time, y =Motifs_remaining ,group=Motifs, color = Motifs))+geom_line(size=2,aes(linetype  = Motifs))+
  geom_dl(aes(label = Motifs), method = list(dl.combine("first.points", "last.points"), cex = 1.5))

p2_18= p1_18+theme_light(base_size = 20)+
  scale_x_continuous("Times",trans='log2') +scale_y_continuous("Motif survival",breaks=seq(0,1,0.1),limits = c(0, 1),labels = seq(0,1,0.1))+
  ggtitle("Case118 IEEE: 50% case: directed 3-node motif survival under random attack")+theme(plot.title = element_text(hjust = 0.5))+
  theme(axis.text.x = element_text(face="bold", color="black", size=20),axis.text.y = element_text(face="bold", color="black", size=20))



#-------------------------------------------------------------------------------------#
minmax_sevfif_percent_3_node_motifs = apply(sevfif_percent_3_node_motifs,2 ,minmax_scale)
colnames(minmax_sevfif_percent_3_node_motifs) = paste("m",1:13,sep = "")
minmax_sevfif_percent_3_node_motifs[is.na(minmax_sevfif_percent_3_node_motifs)] = 0
minmax_sevfif_percent_3_node_motifs = minmax_sevfif_percent_3_node_motifs[,-which(colSums(minmax_sevfif_percent_3_node_motifs)==0)]
minmax_sevfif_percent_3_node_motifs_df = data.frame(Motifs = factor(rep(c("LS",colnames(minmax_sevfif_percent_3_node_motifs)),each = 101)),
                                                  Motifs_remaining = c(fraction_load_served,
                                                                       as.numeric(minmax_sevfif_percent_3_node_motifs[,1]),
                                                                       as.numeric(minmax_sevfif_percent_3_node_motifs[,2]),
                                                                       as.numeric(minmax_sevfif_percent_3_node_motifs[,3]),
                                                                       as.numeric(minmax_sevfif_percent_3_node_motifs[,4])),
                                                  Time = rep(c(1:101),5))
p1_19= ggplot(data = minmax_sevfif_percent_3_node_motifs_df, aes(x=Time, y =Motifs_remaining ,group=Motifs, color = Motifs))+geom_line(size=2,aes(linetype  = Motifs))+
  geom_dl(aes(label = Motifs), method = list(dl.combine("first.points", "last.points"), cex = 1.5))

p2_19= p1_18+theme_light(base_size = 20)+
  scale_x_continuous("Times",trans='log2') +scale_y_continuous("Motif survival",breaks=seq(0,1,0.1),limits = c(0, 1),labels = seq(0,1,0.1))+
  ggtitle("Case118 IEEE: 75% case: directed 3-node motif survival under random attack")+theme(plot.title = element_text(hjust = 0.5))+
  theme(axis.text.x = element_text(face="bold", color="black", size=20),axis.text.y = element_text(face="bold", color="black", size=20))
