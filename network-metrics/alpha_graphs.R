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

