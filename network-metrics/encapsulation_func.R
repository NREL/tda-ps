# # pleae read 118_graph.gml and result.csv file before running program
#write_graph(case_118_network,"118_graph.gml", format = "gml")
#new_case118_result1 = read.csv("result-1.csv")[,-2]

input_graph = read.graph("118_graph.gml",format=c("gml")) # 118_graph.gml is built based on graph.dot/graph.svg #

output_graph_under_attack_f = function(case_118_network = input_graph, initial_status_row = 2, sequence_row){
  
  # 1, import graph.dot graph #
  case_118_network_name_is_label = case_118_network # corresponding to input_graph
  V(case_118_network_name_is_label)$name = V(case_118_network_name_is_label)$label
  edgelist_with_label = get.edgelist(case_118_network_name_is_label)
  edgelist_with_label_branch = cbind(edgelist_with_label, edge_attr(case_118_network_name_is_label)$label)
  colnames(edgelist_with_label_branch) = c("From_Bus","To_Bus","Branch")
  edgelist_with_label_branch = cbind(edgelist_with_label_branch, paste("F_",edgelist_with_label_branch[,3],sep = ""))
  colnames(edgelist_with_label_branch) = c("From_Bus","To_Bus","Branch","F_Branch")
  
  # 2, import initial status from result-1.tsv when sequence = 0 #
  new_case118_result1_seq0 = new_case118_result1[initial_status_row,] # where new_case118_result1 is result-1.tsv; corresponding to initial_status
  new_case118_result1_seq0_Flow_direction_info = new_case118_result1_seq0[which(colnames(new_case118_result1)=="F_1"):which(colnames(new_case118_result1)=="F_186")] # len is 186
  initial_direction_sign = sign(new_case118_result1_seq0_Flow_direction_info)
  
  # 3, assign the F_sign when sequence = 0 to edgelist_with_label_branch generated from graph.dot #
  sign_vector = vector(length = dim(edgelist_with_label_branch)[1])
  for (i in 1:dim(edgelist_with_label_branch)[1]) {
    sign_vector[i] = initial_direction_sign[1,
                                            paste("F_",which(names(initial_direction_sign) == edgelist_with_label_branch[i,4]),sep = "")]
  }
  
  edgelist_with_label_branch_sign = cbind(edgelist_with_label_branch, sign_vector)
  colnames(edgelist_with_label_branch_sign) = c("From_Bus","To_Bus","Branch","F_Branch","F_Sign")
  
  # 4, groundtruth initial edgelist info with branch label, bus label, and flow sign; 
  #that is change the direction with negative compared with the edgelist from graph.dot #
  edgelist_with_label_branch_sign_df = as.data.frame(edgelist_with_label_branch_sign)
  
  
  initial_from_to_bus = data.frame(From_Bus_initial = rep(0,dim(edgelist_with_label_branch)[1]),
                                   To_Bus_Initial = rep(0,dim(edgelist_with_label_branch)[1]),Branch = rep(0,dim(edgelist_with_label_branch)[1]),
                                   Branch_num = rep(0,dim(edgelist_with_label_branch)[1]),F_Sig_zero = rep(0,dim(edgelist_with_label_branch)[1]))
  zero_flow_from_to_bus = data.frame(From_Bus_initial = rep(0,4),
                                     To_Bus_Initial = rep(0,4),Branch = rep(0,4),
                                     Branch_num = rep(0,4))
  a = 1
  for (j in 1:dim(edgelist_with_label_branch)[1]) {
    if(edgelist_with_label_branch_sign_df[j,5] == 1){
      initial_from_to_bus[j,1] = edgelist_with_label_branch_sign[j,1]
      initial_from_to_bus[j,2] = edgelist_with_label_branch_sign[j,2]
      initial_from_to_bus[j,3] = edgelist_with_label_branch_sign[j,4]
      initial_from_to_bus[j,4] = edgelist_with_label_branch_sign[j,3]
      initial_from_to_bus[j,5] = edgelist_with_label_branch_sign[j,5]
    }else if(edgelist_with_label_branch_sign_df[j,5] == -1){
      initial_from_to_bus[j,1] = edgelist_with_label_branch_sign[j,2]
      initial_from_to_bus[j,2] = edgelist_with_label_branch_sign[j,1]
      initial_from_to_bus[j,3] = edgelist_with_label_branch_sign[j,4]
      initial_from_to_bus[j,4] = edgelist_with_label_branch_sign[j,3]
      initial_from_to_bus[j,5] = edgelist_with_label_branch_sign[j,5]
    }else{
      initial_from_to_bus[j,1] = edgelist_with_label_branch_sign[j,1]
      initial_from_to_bus[j,2] = edgelist_with_label_branch_sign[j,2]
      initial_from_to_bus[j,3] = edgelist_with_label_branch_sign[j,4]
      initial_from_to_bus[j,4] = edgelist_with_label_branch_sign[j,3]
      initial_from_to_bus[j,5] = edgelist_with_label_branch_sign[j,5]
      zero_flow_from_to_bus[a,1] = edgelist_with_label_branch_sign[j,1]
      zero_flow_from_to_bus[a,2] = edgelist_with_label_branch_sign[j,2]
      zero_flow_from_to_bus[a,3] = edgelist_with_label_branch_sign[j,4]
      zero_flow_from_to_bus[a,4] = edgelist_with_label_branch_sign[j,3]
      a = a+1
    }
  }
  
  
  # 5, generate seq_zero_case118_ieee_network with correct edge direction when sequence = 0 and then remove the edges with F_=0 when sequence = 0
  seq_zero_case118_ieee_network = graph_from_edgelist(as.matrix(initial_from_to_bus[,c(1:2)]))
  # IGRAPH dc75189 DN-- 118 186 --#
  seq_zero_case118_ieee_network = seq_zero_case118_ieee_network %>% set_edge_attr("name", value = initial_from_to_bus[,3])
  # delete the edges with F_ - 0 #
  seq_zero_case118_ieee_network = delete_edges(seq_zero_case118_ieee_network, zero_flow_from_to_bus[,3])
  # IGRAPH dc75189 DN-- 118 182 --#
  
  # 6, assign name, label, color, feature in case_118_network to seq_zero_case118_ieee_network
  four_attrs_case_118_network = data.frame(name = vertex_attr(case_118_network)$name,
                                           label = vertex_attr(case_118_network)$label,
                                           color = vertex_attr(case_118_network)$color,
                                           feature = vertex_attr(case_118_network)$feature)
  
  
  four_attrs_seq_zero_case118_ieee_network = data.frame(name = rep(0,length(vertex_attr(seq_zero_case118_ieee_network)$name)),
                                                       label = vertex_attr(seq_zero_case118_ieee_network)$name,
                                                       color = rep(0,length(vertex_attr(seq_zero_case118_ieee_network)$name)),
                                                       feature = rep(0,length(vertex_attr(seq_zero_case118_ieee_network)$name)))
  
  for (kk in 1:dim(four_attrs_seq_zero_case118_ieee_network)[1]) {
    tmp_label = which(vertex_attr(case_118_network)$label == vertex_attr(seq_zero_case118_ieee_network)$name[kk])
    four_attrs_seq_zero_case118_ieee_network[kk,1] = vertex_attr(case_118_network)$name[tmp_label]
    four_attrs_seq_zero_case118_ieee_network[kk,3] = vertex_attr(case_118_network)$color[tmp_label]
    four_attrs_seq_zero_case118_ieee_network[kk,4] = vertex_attr(case_118_network)$feature[tmp_label]
  }
  
  four_attrs_seq_zero_case118_ieee_network$name = four_attrs_seq_zero_case118_ieee_network$name #paste("bus",four_attrs_seq_zero_case118_ieee_network$name,sep = "")
  four_attrs_seq_zero_case118_ieee_network_dataframe = four_attrs_seq_zero_case118_ieee_network
  four_attrs_seq_zero_case118_ieee_network_mat = as.matrix(four_attrs_seq_zero_case118_ieee_network_dataframe)
  all.equal(four_attrs_seq_zero_case118_ieee_network_mat[,2],vertex_attr(seq_zero_case118_ieee_network)$name) #TRUE
  
  V(seq_zero_case118_ieee_network)$feature = as.numeric(four_attrs_seq_zero_case118_ieee_network_mat[,4])
  V(seq_zero_case118_ieee_network)$name = four_attrs_seq_zero_case118_ieee_network_mat[,1]
  V(seq_zero_case118_ieee_network)$label = four_attrs_seq_zero_case118_ieee_network_mat[,2]
  V(seq_zero_case118_ieee_network)$color = four_attrs_seq_zero_case118_ieee_network_mat[,3]
  # IGRAPH dc75189 DN-- 118 182 -- #
  
  initial_from_to_bus$F_Sig_zero = as.numeric(initial_from_to_bus$F_Sig_zero)
  initial_from_to_bus$Branch_f = paste("f_",initial_from_to_bus[,4],sep = "") 
  
  # 7, example on sequence = 17; below 19 corresponding to variable - sequence_row
  F_sign_seq_under_attack = sign(new_case118_result1[sequence_row,c(which(colnames(new_case118_result1) == "F_1") : which(colnames(new_case118_result1) == "F_186"))])
  
  # 8, obtain the nodes' labels with b_ is false when sequence = 19
  result_seq_under_attack_nodes_info = new_case118_result1[sequence_row,c(which(colnames(new_case118_result1) == "b_1") : which(colnames(new_case118_result1) == "b_118"))]
  removed_nodes_label = names(result_seq_under_attack_nodes_info)[which(result_seq_under_attack_nodes_info*1 == 0)]
  
  # rename edges' names for seq_zero_case118_ieee_network use f_ not F_#
  length(edge_attr(seq_zero_case118_ieee_network)$name)
  edge_label_num = as.numeric(gsub("F_", "", edge_attr(seq_zero_case118_ieee_network)$name)) # extract the number in edge_attr(seq_zero_case118_iee_network)$name; since i want to rebuild the f_ for edges' names
  E(seq_zero_case118_ieee_network)$name = paste("f_",edge_label_num, sep="")
  # rename complete #
  
  # 9, generage comb_seq0_seq_under_attack_stage1 which combine initial_from_to_bus and F_sign with sequence = under attack
  F_sign_seq_under_attack_mapping = vector(length = dim(initial_from_to_bus)[1])
  for (ii in 1:dim(initial_from_to_bus)[1]) {
    tmp = which(initial_from_to_bus[,3] == names(F_sign_seq_under_attack)[ii])
    F_sign_seq_under_attack_mapping[tmp] = as.numeric(F_sign_seq_under_attack[ii])
  }
  
  comb_seq0_seq_under_attack_stage1 = cbind(initial_from_to_bus, F_sign_seq_under_attack_mapping)
  
  # Firstly, find the edges with F_ = 0 when sequence = 17 - stage 1#
  edges_with_zero_flow_label = comb_seq0_seq_under_attack_stage1[which(comb_seq0_seq_under_attack_stage1$F_sign_seq_under_attack_mapping == 0),"Branch_f"] 
  
  # Secondly, remove the rows with F_ = 0 when sequence = 17 - generate comb_seq0_seq_under_attack_stage2 #
  comb_seq0_seq_under_attack_stage2 = comb_seq0_seq_under_attack_stage1[-which(comb_seq0_seq_under_attack_stage1$F_sign_seq_under_attack_mapping == 0),]
  rownames(comb_seq0_seq_under_attack_stage2) = c(1:dim(comb_seq0_seq_under_attack_stage2)[1])
  
  # Thirdly, calcualte the difference between seq17 and initial which try to find the which edges change the direction - generage comb_seq0_seq_under_attack_stage3 #
  comb_seq0_seq_under_attack_stage3 = comb_seq0_seq_under_attack_stage2
  comb_seq0_seq_under_attack_stage3$diff = comb_seq0_seq_under_attack_stage3$F_sign_seq_under_attack_mapping - comb_seq0_seq_under_attack_stage3$F_Sig_zero
  
  # Fourthly, find out the edges with direction changed - generate comb_seq0_seq_under_attack_stage4 #
  #-------------fixing now--------------------------------------#
  # Debug for comb_seq0_seq_under_attack_stage4 - 06/21 08:33am #
  # if there is not edge direction changed i.e., all diff =0 #
  # add condition - whether all difference equal to 0 i.e., not edge direction changed#
  if(!all(comb_seq0_seq_under_attack_stage3$diff == 0)){
  
  comb_seq0_seq_under_attack_stage4 = comb_seq0_seq_under_attack_stage3[-which(comb_seq0_seq_under_attack_stage3$diff==0),]
  rownames(comb_seq0_seq_under_attack_stage4) = c(1:dim(comb_seq0_seq_under_attack_stage4)[1])
  
  # Fifthly, build the updated (new when seq = 17) from_to_bus dataframe after sequence = 17 attack - generate comb_seq0_seq_under_attack_stage5 #
  comb_seq0_seq_under_attack_stage5 = data.frame(From_Bus = rep(0,dim(comb_seq0_seq_under_attack_stage4)[1]), 
                                         To_Bus = rep(0,dim(comb_seq0_seq_under_attack_stage4)[1]), Branch_F = rep(0,dim(comb_seq0_seq_under_attack_stage4)[1]), Branch_f = rep(0,dim(comb_seq0_seq_under_attack_stage4)[1]))
  
  comb_seq0_seq_under_attack_stage5$From_Bus = comb_seq0_seq_under_attack_stage4$To_Bus_Initial
  comb_seq0_seq_under_attack_stage5$To_Bus = comb_seq0_seq_under_attack_stage4$From_Bus_initial
  comb_seq0_seq_under_attack_stage5$Branch_F = comb_seq0_seq_under_attack_stage4$Branch
  comb_seq0_seq_under_attack_stage5$Branch_f = comb_seq0_seq_under_attack_stage4$Branch_f
  
  # change the label and name for seq_zero_case118_ieee_network #
  tmp_label_store = V(seq_zero_case118_ieee_network)$label
  V(seq_zero_case118_ieee_network)$label = V(seq_zero_case118_ieee_network)$name
  V(seq_zero_case118_ieee_network)$name = tmp_label_store
  # change over #
  
  # 10, create the edgelist with "edge name" for sequence = 0 from seq_zero_case118_ieee_network #
  initial_graph_edgelist_with_Branch_f = cbind(get.edgelist(seq_zero_case118_ieee_network), edge_attr(seq_zero_case118_ieee_network)$name) # - shape is  182*3
  
  # 11, find the final short version of initial from_to bus info and Branch_f WITHOUT F_Sig_zero = 0 scenario #
  label_without_f_sig_zero = which(comb_seq0_seq_under_attack_stage4$F_Sig_zero != 0 )
  df_with_edge_changed_with_F_signotzero = comb_seq0_seq_under_attack_stage4[label_without_f_sig_zero, c("From_Bus_initial", "To_Bus_Initial","Branch_f")]
  rownames(df_with_edge_changed_with_F_signotzero) = c(1:dim(df_with_edge_changed_with_F_signotzero)[1]) #
  
  # 12, remove direction changed edges from initial_graph_edgelist_with_Branch_f - generate edgelist_change_stage1 #
  edgelist_change_stage1_label = (!duplicated(rbind(initial_graph_edgelist_with_Branch_f, as.matrix(df_with_edge_changed_with_F_signotzero)), fromLast = T))[1:dim(initial_graph_edgelist_with_Branch_f)[1]]
  edgelist_change_stage1 = initial_graph_edgelist_with_Branch_f[edgelist_change_stage1_label,]
  
  # 13, combine delted verion above i.e., stage 1, with comb_seq0_seq_under_attack_stage5 # 
  final_bus_fromto_Branch_f = rbind(edgelist_change_stage1, as.matrix(comb_seq0_seq_under_attack_stage5[,c("From_Bus", "To_Bus","Branch_f")]))
  
  # 14, remove the edges with F_  = 0 when sequence = 17 #
  final_verion_edgelist_with_Branch_f = final_bus_fromto_Branch_f[(!final_bus_fromto_Branch_f[,3] %in% edges_with_zero_flow_label),]
  
  # 15, create igraph graphs from data frames #
  final_verion_graph = graph_from_data_frame(as.data.frame(final_verion_edgelist_with_Branch_f[,c(1:3)]), directed=TRUE, vertices=V(seq_zero_case118_ieee_network)$name)
}else if(all(comb_seq0_seq_under_attack_stage3$diff == 0)){
  seq_zero_case118_ieee_network = graph_from_edgelist(as.matrix(initial_from_to_bus[,c(1:2)]))
  seq_zero_case118_ieee_network = seq_zero_case118_ieee_network %>% set_edge_attr("name", value = initial_from_to_bus[,3])
  
  #------#
  # repeat 6, assign name, label, color, feature in case_118_network to seq_zero_case118_ieee_network (another version)
  four_attrs_case_118_network = data.frame(name = vertex_attr(case_118_network)$name,
                                           label = vertex_attr(case_118_network)$label,
                                           color = vertex_attr(case_118_network)$color,
                                           feature = vertex_attr(case_118_network)$feature)
  
  
  four_attrs_seq_zero_case118_ieee_network = data.frame(name = rep(0,length(vertex_attr(seq_zero_case118_ieee_network)$name)),
                                                        label = vertex_attr(seq_zero_case118_ieee_network)$name,
                                                        color = rep(0,length(vertex_attr(seq_zero_case118_ieee_network)$name)),
                                                        feature = rep(0,length(vertex_attr(seq_zero_case118_ieee_network)$name)))
  
  for (kk in 1:dim(four_attrs_seq_zero_case118_ieee_network)[1]) {
    tmp_label = which(vertex_attr(case_118_network)$label == vertex_attr(seq_zero_case118_ieee_network)$name[kk])
    four_attrs_seq_zero_case118_ieee_network[kk,1] = vertex_attr(case_118_network)$name[tmp_label]
    four_attrs_seq_zero_case118_ieee_network[kk,3] = vertex_attr(case_118_network)$color[tmp_label]
    four_attrs_seq_zero_case118_ieee_network[kk,4] = vertex_attr(case_118_network)$feature[tmp_label]
  }
  
  four_attrs_seq_zero_case118_ieee_network$name = four_attrs_seq_zero_case118_ieee_network$name #paste("bus",four_attrs_seq_zero_case118_ieee_network$name,sep = "")
  four_attrs_seq_zero_case118_ieee_network_dataframe = four_attrs_seq_zero_case118_ieee_network
  four_attrs_seq_zero_case118_ieee_network_mat = as.matrix(four_attrs_seq_zero_case118_ieee_network_dataframe)
  all.equal(four_attrs_seq_zero_case118_ieee_network_mat[,2],vertex_attr(seq_zero_case118_ieee_network)$name) #TRUE
  
  V(seq_zero_case118_ieee_network)$feature = as.numeric(four_attrs_seq_zero_case118_ieee_network_mat[,4])
  V(seq_zero_case118_ieee_network)$name = four_attrs_seq_zero_case118_ieee_network_mat[,1]
  V(seq_zero_case118_ieee_network)$label = four_attrs_seq_zero_case118_ieee_network_mat[,2]
  V(seq_zero_case118_ieee_network)$color = four_attrs_seq_zero_case118_ieee_network_mat[,3]
  # IGRAPH dc75189 DN-- 118 186 -- #
  #------#
  
  # rename edges' names for seq_zero_case118_ieee_network use f_ not F_#
  length(edge_attr(seq_zero_case118_ieee_network)$name)
  edge_label_num = as.numeric(gsub("F_", "", edge_attr(seq_zero_case118_ieee_network)$name)) # extract the number in edge_attr(seq_zero_case118_iee_network)$name; since i want to rebuild the f_ for edges' names
  E(seq_zero_case118_ieee_network)$name = paste("f_",edge_label_num, sep="")
  # rename complete #
  
  # change the name and label for seq_zero_case118_ieee_network #
  tmp_label_store = V(seq_zero_case118_ieee_network)$label
  V(seq_zero_case118_ieee_network)$label = V(seq_zero_case118_ieee_network)$name
  V(seq_zero_case118_ieee_network)$name = tmp_label_store
  # change complete #
  
  initial_graph_edgelist_with_Branch_f_case2 = cbind(get.edgelist(seq_zero_case118_ieee_network), edge_attr(seq_zero_case118_ieee_network)$name)
  final_verion_edgelist_with_Branch_f = initial_graph_edgelist_with_Branch_f_case2[(!initial_graph_edgelist_with_Branch_f_case2[,3] %in% edges_with_zero_flow_label),]
  colnames(final_verion_edgelist_with_Branch_f) = c("From_Bus", "To_Bus","Branch_f")
  final_verion_graph = graph_from_data_frame(as.data.frame(final_verion_edgelist_with_Branch_f[,c(1:3)]), directed=TRUE, vertices=V(seq_zero_case118_ieee_network)$name)
  
}
  # 16, delete the nodes with b_ = false #
  final_version_graph_after_delete_false_nodes = delete_vertices(final_verion_graph, removed_nodes_label)
  
  # 17, assign various attributes from seq_zero_case118_ieee_network to final_version_graph_after_delete_false_nodes
  vertex_attr(final_version_graph_after_delete_false_nodes)$busname = rep(NA, length(vertex_attr(final_version_graph_after_delete_false_nodes)$name))
  vertex_attr(final_version_graph_after_delete_false_nodes)$feature = rep(NA, length(vertex_attr(final_version_graph_after_delete_false_nodes)$name))
  
  for (uu in 1:length(vertex_attr(final_version_graph_after_delete_false_nodes)$name)) {
    tmp_label_ii = vertex_attr(seq_zero_case118_ieee_network)$name %in% vertex_attr(final_version_graph_after_delete_false_nodes)$name[uu]
    vertex_attr(final_version_graph_after_delete_false_nodes)$busname[uu] = vertex_attr(seq_zero_case118_ieee_network)$label[tmp_label_ii]
    vertex_attr(final_version_graph_after_delete_false_nodes)$feature[uu] = vertex_attr(seq_zero_case118_ieee_network)$feature[tmp_label_ii]
  }
  
  # assign Branch_F to final_version_graph_after_delete_false_nodes #
  edge_num_with_Branch_f = as.numeric(gsub("f_", "", edge_attr(final_version_graph_after_delete_false_nodes)$Branch_f))
  edge_attr(final_version_graph_after_delete_false_nodes)$Branch_F = paste("F_",edge_num_with_Branch_f, sep="")
  
  # assign F_ to edge weight #
  edge_attr(final_version_graph_after_delete_false_nodes)$weight = rep(NA, length(edge_attr(final_version_graph_after_delete_false_nodes)$Branch_f))
  for (mm in 1:length(edge_attr(final_version_graph_after_delete_false_nodes)$Branch_f)) {
    sequnce_under_attack_Flow_info = new_case118_result1[sequence_row,c(which(colnames(new_case118_result1) == "F_1") : which(colnames(new_case118_result1) == "F_186"))]
    tmp_weight_label = names(sequnce_under_attack_Flow_info) %in% edge_attr(final_version_graph_after_delete_false_nodes)$Branch_F[mm]
    edge_attr(final_version_graph_after_delete_false_nodes)$weight[mm] = abs(as.numeric(sequnce_under_attack_Flow_info[tmp_weight_label]))
  }
  
  return(final_version_graph_after_delete_false_nodes) # with parallel edges
}

# through using simplify function, we can not only remove the duplicated edges but merge the weights #
# here is directed verion #
graph_structure_under_sequence_row_attack = simplify(output_graph_under_attack_f(case_118_network = input_graph, initial_status_row = 2, sequence_row = 5))
graph_structure_under_sequence_row_attack_directed = graph_structure_under_sequence_row_attack
# here is undirected version #
graph_structure_under_sequence_row_attack_undirected = as.undirected(graph_structure_under_sequence_row_attack)

'''
# extract weight matrix from target graph #
# weight matrix for the graph when sequence = 0 #
# seq_zero_case118_ieee_network generated from encapsulation_fun.R does not include the weight attribute #
# now we need to assign for it #
edge_num_with_name = as.numeric(gsub("f_", "", edge_attr(seq_zero_case118_ieee_network)$name))
edge_attr(seq_zero_case118_ieee_network)$Branch_F = paste("F_",edge_num_with_name, sep="")
Flow_values_seq0 = new_case118_result1_seq0[which(colnames(new_case118_result1)=="F_1"):which(colnames(new_case118_result1)=="F_186")]
weight_vector = vector(length = length(edge_attr(seq_zero_case118_ieee_network)$Branch_F))

for (qq in 1:length(edge_attr(seq_zero_case118_ieee_network)$Branch_F)) {
  
  tmp_F_label = which((edge_attr(seq_zero_case118_ieee_network)$Branch_F %in% names(Flow_values_seq0)[qq])*1 == 1)
  weight_vector[tmp_F_label] = abs(as.numeric(Flow_values_seq0[qq]))
  
}
edge_attr(seq_zero_case118_ieee_network)$weight = weight_vector

weight_matrix = as_adjacency_matrix(seq_zero_case118_ieee_network,attr = "weight")
weight_matrix = as.matrix(weight_matrix)
write.csv(weight_matrix,"weight_matrix.csv")
'''

