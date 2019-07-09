# prepare works #
library(igraph)
input_graph = read.graph("118_graph.gml",format=c("gml")) # 118_graph.gml is built based on graph.dot/graph.svg #
new_case118_result1 = read.csv("result-1.csv")[,-2]

output_graph_under_attack_f = function(case_118_network = input_graph, initial_status_row = 1, sequence_row){
  
  # 1, import graph.dot graph #
  case_118_network_name_is_label = case_118_network # corresponding to input_graph
  V(case_118_network_name_is_label)$name = V(case_118_network_name_is_label)$label
  edgelist_with_label = get.edgelist(case_118_network_name_is_label)
  edgelist_with_label_branch = cbind(edgelist_with_label, edge_attr(case_118_network_name_is_label)$label)
  colnames(edgelist_with_label_branch) = c("From_Bus","To_Bus","Branch")
  edgelist_with_label_branch = cbind(edgelist_with_label_branch, paste("F_",edgelist_with_label_branch[,3],sep = ""))
  colnames(edgelist_with_label_branch) = c("From_Bus","To_Bus","Branch","F_Branch")
  
  # 2, import initial status from result-1.tsv when sequence = 0 #
  casestudy_dataset_seq0 = casestudy_dataset[initial_status_row,] # where casestudy_dataset is result-1.tsv; corresponding to initial_status
  casestudy_dataset_seq0_Flow_direction_info = casestudy_dataset_seq0[which(colnames(casestudy_dataset)=="F_1"):which(colnames(casestudy_dataset)=="F_186")] # len is 186
  initial_direction_sign = sign(casestudy_dataset_seq0_Flow_direction_info)
  
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
  F_sign_seq_under_attack = sign(casestudy_dataset[sequence_row,c(which(colnames(casestudy_dataset) == "F_1") : which(colnames(casestudy_dataset) == "F_186"))])
  
  # 8, obtain the nodes' labels with b_ is false when sequence = 19
  result_seq_under_attack_nodes_info = casestudy_dataset[sequence_row,c(which(colnames(casestudy_dataset) == "b_1") : which(colnames(casestudy_dataset) == "b_118"))]
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
  
  # Firstly, find the edges with F_ = 0 when sequence = 17(under attack) - stage 1#
  edges_with_zero_flow_label = comb_seq0_seq_under_attack_stage1[which(comb_seq0_seq_under_attack_stage1$F_sign_seq_under_attack_mapping == 0),"Branch_f"] 
  
  # Secondly, remove the rows with F_ = 0 when sequence = 17 - generate comb_seq0_seq_under_attack_stage2 #
  comb_seq0_seq_under_attack_stage2 = comb_seq0_seq_under_attack_stage1[-which(comb_seq0_seq_under_attack_stage1$F_sign_seq_under_attack_mapping == 0),]
  rownames(comb_seq0_seq_under_attack_stage2) = c(1:dim(comb_seq0_seq_under_attack_stage2)[1])
  
  # Thirdly, calcualte the difference between seq17 and initial which try to find the which edges change the direction - generage comb_seq0_seq_under_attack_stage3 #
  comb_seq0_seq_under_attack_stage3 = comb_seq0_seq_under_attack_stage2
  comb_seq0_seq_under_attack_stage3$diff = comb_seq0_seq_under_attack_stage3$F_sign_seq_under_attack_mapping - comb_seq0_seq_under_attack_stage3$F_Sig_zero
  
  # Fourthly, find out the edges with direction changed - generate comb_seq0_seq_under_attack_stage4 #
  #-------------fixed already-----------------------------------#
  # Debug for comb_seq0_seq_under_attack_stage4 - 06/21 08:33am #
  # if there is not edge direction changed i.e., all diff =0 #
  # add condition - whether all difference equal to 0 i.e., not edge direction changed#
  if(!all(comb_seq0_seq_under_attack_stage3$diff == 0)){ #do not consider the flow which equals to 0 at sequence = 0 (07/01 - find bug)
    
    # bug 07/01, if there only exist one edge has difference #
    if (sum(which(comb_seq0_seq_under_attack_stage3$diff==0)*1)>0){
      comb_seq0_seq_under_attack_stage4 = comb_seq0_seq_under_attack_stage3[-which(comb_seq0_seq_under_attack_stage3$diff==0),]
      rownames(comb_seq0_seq_under_attack_stage4) = c(1:dim(comb_seq0_seq_under_attack_stage4)[1])}else
      {comb_seq0_seq_under_attack_stage4 = comb_seq0_seq_under_attack_stage3}
    
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
    if(sum((comb_seq0_seq_under_attack_stage4$F_Sig_zero != 0)*1)!=0){
      rownames(df_with_edge_changed_with_F_signotzero) = c(1:dim(df_with_edge_changed_with_F_signotzero)[1])} #
    
    # 12, remove direction changed edges from initial_graph_edgelist_with_Branch_f - generate edgelist_change_stage1 #
    edgelist_change_stage1_label = (!duplicated(rbind(initial_graph_edgelist_with_Branch_f, as.matrix(df_with_edge_changed_with_F_signotzero)), fromLast = T))[1:dim(initial_graph_edgelist_with_Branch_f)[1]]
    edgelist_change_stage1 = initial_graph_edgelist_with_Branch_f[edgelist_change_stage1_label,]
    
    # 13, combine delted verion above i.e., stage 1, with comb_seq0_seq_under_attack_stage5 # 
    final_bus_fromto_Branch_f = rbind(edgelist_change_stage1, as.matrix(comb_seq0_seq_under_attack_stage5[,c("From_Bus", "To_Bus","Branch_f")]))
    
    # 14, remove the edges with F_  = 0 when sequence = 17 #
    final_verion_edgelist_with_Branch_f = final_bus_fromto_Branch_f[(!final_bus_fromto_Branch_f[,3] %in% edges_with_zero_flow_label),]
    
    # 15, create igraph graphs from data frames # find bug 07/01
    if(sum((dim(final_verion_edgelist_with_Branch_f)[1]*1))>0){
      final_verion_graph = graph_from_data_frame(as.data.frame(final_verion_edgelist_with_Branch_f[,c(1:3)]), directed=TRUE, vertices=V(seq_zero_case118_ieee_network)$name)}else{
        final_verion_graph = graph_from_data_frame(as.data.frame(t(unlist(final_verion_edgelist_with_Branch_f)))[,c(1:3)], directed=TRUE, vertices=V(seq_zero_case118_ieee_network)$name)}
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
    
    # fixed (already) for colnames can not work for dataframe with only one row - 06/23 #
    if(!is.null(dim(final_verion_edgelist_with_Branch_f))){
      colnames(final_verion_edgelist_with_Branch_f) = c("From_Bus", "To_Bus","Branch_f")}
    else{
      final_verion_edgelist_with_Branch_f = data.frame(t(unlist(final_verion_edgelist_with_Branch_f)))
      colnames(final_verion_edgelist_with_Branch_f) = c("From_Bus", "To_Bus","Branch_f")
    }
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
    sequnce_under_attack_Flow_info = casestudy_dataset[sequence_row,c(which(colnames(casestudy_dataset) == "F_1") : which(colnames(casestudy_dataset) == "F_186"))]
    tmp_weight_label = names(sequnce_under_attack_Flow_info) %in% edge_attr(final_version_graph_after_delete_false_nodes)$Branch_F[mm]
    edge_attr(final_version_graph_after_delete_false_nodes)$weight[mm] = abs(as.numeric(sequnce_under_attack_Flow_info[tmp_weight_label]))
  }
  
  len_Branch_F = length(edge_attr(final_version_graph_after_delete_false_nodes)$Branch_F)
  
  start_ratio_label = which(colnames(casestudy_dataset)=="F_1")
  end_ratio_label = which(colnames(casestudy_dataset)=="F_186")
  flow_ratio_vector = vector(length = len_Branch_F)
  
  for (i in c(1:len_Branch_F)) {
    Flow_part = casestudy_dataset[1, which(colnames(casestudy_dataset)=="F_1"):which(colnames(casestudy_dataset)=="F_186")]
    tmp_ratio_label = colnames(casestudy_dataset)[c(start_ratio_label:end_ratio_label)] %in% edge_attr(final_version_graph_after_delete_false_nodes)$Branch_F[i]
    if(sum(tmp_ratio_label)>0){
      flow_ratio_vector[i] = edge_attr(final_version_graph_after_delete_false_nodes)$weight[i]/as.numeric(Flow_part[tmp_ratio_label])
    }
  }
  
  edge_attr(final_version_graph_after_delete_false_nodes)$ratio_weight = flow_ratio_vector
  
  return(final_version_graph_after_delete_false_nodes) # the output graph with parallel edges
}

minmax_scale = function(x) {  
  (x - min(x))/(max(x) - min(x))}


# prepare complete #

# dataset ready #
casestudy_dataset = read.csv("df_unique_less_than_95_first_20000.csv", header = TRUE, row.names = 1) # (20000, 699)
casestudy_dataset = casestudy_dataset[,-2]
# firstly, check whether there exists sequence = 0 scaling case #
check_seq_0 = which(casestudy_dataset[,1]==0) # find that, in this file, we do not have sequence = 0 case #
# add sequence = 0 case to casestudy_dataset #
casestudy_dataset = rbind(new_case118_result1[2,],casestudy_dataset) # [1] 20001   698

# transform True to TRUE and False to FALSE #

for (i in c(2:359)) {
  casestudy_dataset[c(2:20001),i] = ifelse(casestudy_dataset[c(2:20001),i]=="True",TRUE,FALSE)
}

for (i in c(2:359)) {
  casestudy_dataset[1,i] = ifelse(casestudy_dataset[1,i]=="TRUE",TRUE,FALSE)
}

mat <- sapply(casestudy_dataset[,c(2:359)], as.logical)
casestudy_dataset[,c(2:359)] = mat

# transformation complete #

# ------------------------------------------------------------------------------ #
# 3-node motifs with directed version #
casestudy_3_node_motifs_d = matrix(NA, nrow = dim(casestudy_dataset)[1], ncol = 13)
for (i in c(1:dim(casestudy_dataset)[1])) {
  # consider the case where there is no edge in the graph #
  if(sum(casestudy_dataset[i,c(which(colnames(casestudy_dataset) == "F_1") : which(colnames(casestudy_dataset) == "F_186"))])!=0){
    sim_tmp_graph  = simplify(output_graph_under_attack_f(case_118_network = input_graph, initial_status_row = 1, sequence_row = i)) # the output_graph_under_attack_f used here is from ieee118_case_study_encapsulation_func in NREL_works folder
    casestudy_3_node_motifs_d[i,] = triad_census(sim_tmp_graph)[4:16]}
  else{
    casestudy_3_node_motifs_d[i,] = 0
  }
}

write.csv(casestudy_3_node_motifs_d, file = "casestudy_3_node_motifs_d.csv")
# over #

# 3-node motifs with undirected version and 4-node motifs (undirected) - regular for all nodes ##
casestudy_3_node_motifs_undirected = matrix(NA, nrow = dim(casestudy_dataset)[1], ncol = 2) # columns from m1 to m2 #
casestudy_4_node_motifs_undirected = matrix(NA, nrow = dim(casestudy_dataset)[1], ncol = 6) # columns from m1 to m6 #
for (i in c(1:dim(casestudy_dataset)[1])) {
  if(sum(casestudy_dataset[i,c(which(colnames(casestudy_dataset) == "F_1") : which(colnames(casestudy_dataset) == "F_186"))])!=0){
    sim_tmp_graph  = simplify(output_graph_under_attack_f(case_118_network = input_graph, initial_status_row = 1, sequence_row = i))
    sim_tmp_graph = as.undirected(sim_tmp_graph)
    print(i)
    casestudy_3_node_motifs_undirected[i,] = motifs(sim_tmp_graph, size = 3)[c(3:4)]
    casestudy_4_node_motifs_undirected[i,] = motifs(sim_tmp_graph, size = 4)[c(5,7,8,9,10,11)]}else{
      casestudy_3_node_motifs_undirected[i,]= 0
      casestudy_4_node_motifs_undirected[i,] = 0
    }
}
write.csv(casestudy_3_node_motifs_undirected, file = "casestudy_3_node_motifs_undirected.csv")
write.csv(casestudy_4_node_motifs_undirected, file = "casestudy_4_node_motifs_undirected.csv")
# over #


# the size of maximum clique, node attributes, and alpha graphs #
casestudy_size_max_clique_undirected = matrix(NA, nrow = dim(casestudy_dataset)[1], ncol = 1) # only one column #
casestudy_bus_3_node_motifs_mat = matrix(NA, nrow = dim(casestudy_dataset)[1], ncol = 13)
casestudy_load_3_node_motifs_mat = matrix(NA, nrow = dim(casestudy_dataset)[1], ncol = 13)
casestudy_generator_3_node_motifs_mat = matrix(NA, nrow = dim(casestudy_dataset)[1], ncol = 13)
casestudy_gl_3_node_motifs_mat = matrix(NA, nrow = dim(casestudy_dataset)[1], ncol = 13)
casestudy_nianwu_percent_3_node_motifs = matrix(NA, nrow = dim(casestudy_dataset)[1], ncol = 13)
casestudy_half_percent_3_node_motifs = matrix(NA, nrow = dim(casestudy_dataset)[1], ncol = 13)
casestudy_sevfif_percent_3_node_motifs = matrix(NA, nrow = dim(casestudy_dataset)[1], ncol = 13)


for (ii in c(1:dim(casestudy_dataset)[1])) { #c(1:dim(casestudy_dataset)[1])
  
  if(sum(casestudy_dataset[ii,c(which(colnames(casestudy_dataset) == "F_1") : which(colnames(casestudy_dataset) == "F_186"))])!=0){
    print(ii)
    sim_tmp_graph  = output_graph_under_attack_f(case_118_network = input_graph, initial_status_row = 1, sequence_row = i)
    ####### alpha graphs ######
    
    quantile_weight_ratio = quantile(edge_attr(sim_tmp_graph)$ratio_weight)
    
    below_nianwu_percent_label_num = which(edge_attr(sim_tmp_graph)$ratio_weight<as.numeric(quantile_weight_ratio[2]))
    below_nianwu_percent_Branch_f_label = edge_attr(sim_tmp_graph)$Branch_f[below_nianwu_percent_label_num]
    
    below_nianwu_temp_graph = sim_tmp_graph %>% set_edge_attr("name", value = edge_attr(sim_tmp_graph)$Branch_f)
    below_nianwu_temp_graph = delete_edges(below_nianwu_temp_graph, below_nianwu_percent_Branch_f_label)
    
    sim_tmp_graph_nianwu  = simplify(below_nianwu_temp_graph)
    casestudy_nianwu_percent_3_node_motifs[ii,] = triad_census(sim_tmp_graph_nianwu)[4:16]
    # next #
    below_half_percent_label_num = which(edge_attr(sim_tmp_graph)$ratio_weight<as.numeric(quantile_weight_ratio[3]))
    below_half_percent_Branch_f_label = edge_attr(sim_tmp_graph)$Branch_f[below_half_percent_label_num]
    
    below_half_temp_graph = sim_tmp_graph %>% set_edge_attr("name", value = edge_attr(sim_tmp_graph)$Branch_f)
    below_half_temp_graph = delete_edges(below_half_temp_graph, below_half_percent_Branch_f_label)
    
    sim_tmp_graph_half  = simplify(below_half_temp_graph)
    casestudy_half_percent_3_node_motifs[ii,] = triad_census(sim_tmp_graph_half)[4:16]
    # next #
    below_sevfif_percent_label_num = which(edge_attr(sim_tmp_graph)$ratio_weight<as.numeric(quantile_weight_ratio[4]))
    below_sevfif_percent_Branch_f_label = edge_attr(sim_tmp_graph)$Branch_f[below_sevfif_percent_label_num]
    
    below_sevfif_temp_graph = sim_tmp_graph %>% set_edge_attr("name", value = edge_attr(sim_tmp_graph)$Branch_f)
    below_sevfif_temp_graph = delete_edges(below_sevfif_temp_graph, below_sevfif_percent_Branch_f_label)
    
    sim_tmp_graph_sevfif  = simplify(below_sevfif_temp_graph)
    casestudy_sevfif_percent_3_node_motifs[ii,] = triad_census(sim_tmp_graph_sevfif)[4:16]
    
    ##########################
    
    
    sim_tmp_graph  = simplify(sim_tmp_graph)
    write_graph(sim_tmp_graph,file=paste("directed_graph_sequence_",ii-1,".gml",sep=""),format = "gml")
    # for bus, load, generator, and generator & load #
    motifs_matrix = matrix(NA, nrow = length(V(sim_tmp_graph)), ncol = 13)
    rownames(motifs_matrix) = vertex_attr(sim_tmp_graph)$name
    for (i in 1:length(V(sim_tmp_graph))) {
      
      subGraph = graph.neighborhood(sim_tmp_graph, order = 1, V(sim_tmp_graph)$name[i], mode = 'all')[[1]]
      allMotifs = triad_census(subGraph)
      removeNode = delete_vertices(subGraph, V(sim_tmp_graph)$name[i])
      single_node_Motifs = allMotifs - triad_census(removeNode)
      motifs_matrix[i,] = single_node_Motifs[4:16]
    }
    
    sum(is.na(motifs_matrix)) == 0
    
    diff_types_motifs_matrix = matrix(0, nrow = 4, ncol = 13)
    for (j in c(1:4)) {
      if(sum(vertex_attr(sim_tmp_graph)$feature == j) > 0){
        tmp_node_feature_label = which(vertex_attr(sim_tmp_graph)$feature == j)
        diff_types_motifs_matrix[j,] = colSums(motifs_matrix[tmp_node_feature_label,, drop = FALSE])}
    }
    rownames(diff_types_motifs_matrix) = c("Bus","Load","Generator","Generator_and_Load")
    casestudy_bus_3_node_motifs_mat[ii,] = diff_types_motifs_matrix[1,]
    casestudy_load_3_node_motifs_mat[ii,] = diff_types_motifs_matrix[2,]
    casestudy_generator_3_node_motifs_mat[ii,] = diff_types_motifs_matrix[3,]
    casestudy_gl_3_node_motifs_mat[ii,] = diff_types_motifs_matrix[4,]
    
    # for maximum clique #
    sim_tmp_graph = as.undirected(sim_tmp_graph)
    write_graph(sim_tmp_graph,file=paste("undirected_graph_sequence_",ii-1,".gml",sep=""),format = "gml")
    casestudy_size_max_clique_undirected[ii,1] = clique_num(sim_tmp_graph)}else{
      casestudy_size_max_clique_undirected[ii,1] = 0
      casestudy_bus_3_node_motifs_mat[ii,] = 0
      casestudy_load_3_node_motifs_mat[ii,] = 0
      casestudy_generator_3_node_motifs_mat[ii,] = 0
      casestudy_gl_3_node_motifs_mat[ii,] = 0
      casestudy_nianwu_percent_3_node_motifs[ii,] = 0
      casestudy_half_percent_3_node_motifs[ii,] = 0
      casestudy_sevfif_percent_3_node_motifs[ii,] = 0
      
    }
}

write.csv(casestudy_size_max_clique_undirected, file = "casestudy_size_max_clique_undirected.csv")
write.csv(casestudy_bus_3_node_motifs_mat, file = "casestudy_bus_3_node_motifs_mat.csv")
write.csv(casestudy_load_3_node_motifs_mat, file = "casestudy_load_3_node_motifs_mat.csv")
write.csv(casestudy_generator_3_node_motifs_mat, file = "casestudy_generator_3_node_motifs_mat.csv")
write.csv(casestudy_gl_3_node_motifs_mat, file = "casestudy_gl_3_node_motifs_mat.csv")
write.csv(casestudy_nianwu_percent_3_node_motifs, file = "casestudy_nianwu_percent_3_node_motifs.csv")
write.csv(casestudy_half_percent_3_node_motifs, file = "casestudy_half_percent_3_node_motifs.csv")
write.csv(casestudy_sevfif_percent_3_node_motifs, file = "casestudy_sevfif_percent_3_node_motifs.csv")


# ------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------ #
# fraction of generator operating, load entropy, generator entropy #
seq_minus_1_L = new_case118_result1[1,which(colnames(new_case118_result1) == "L_1"):which(colnames(new_case118_result1) == "L_118")]
sum_L_max = sum(seq_minus_1_L)

# sequence row we focus on is from 2 to 102 #
fraction_load_served = vector(length = dim(casestudy_dataset)[1])
start_label = which(colnames(casestudy_dataset) == "L_1")
end_label = which(colnames(casestudy_dataset) == "L_118")

for (i in c(1:dim(casestudy_dataset)[1])) {
  numerator = sum(casestudy_dataset[i,start_label:end_label])
  fraction_load_served[i] = numerator/sum_L_max
}

load_entropy = rep(0,dim(casestudy_dataset)[1])
for (i in c(1:dim(casestudy_dataset)[1])) {
  for (j in c(start_label:end_label)) {
    if(casestudy_dataset[i,j]==0){
      load_entropy[i] = load_entropy[i]+0
    }else{
      l_i = abs(casestudy_dataset[i,j])/sum(abs(casestudy_dataset[i,c(start_label:end_label)]))
      load_entropy[i] = load_entropy[i] + (-l_i*log(l_i))
    }
  }
}
write.csv(fraction_load_served, file = "fraction_load_served.csv")
write.csv(load_entropy, file = "load_entropy.csv")



# sequence row we focus on is from 2 to 102 #
seq_minus_1_G = new_case118_result1[1,which(colnames(new_case118_result1) == "G_1"):which(colnames(new_case118_result1) == "G_54")]
sum_G_max = sum(seq_minus_1_G)
fraction_generator_operating = vector(length = dim(casestudy_dataset)[1])
start_label_g = which(colnames(casestudy_dataset) == "G_1")
end_label_g = which(colnames(casestudy_dataset) == "G_54")

for (i in c(1:dim(casestudy_dataset)[1])) {
  numerator = sum(casestudy_dataset[i,start_label_g:end_label_g])
  fraction_generator_operating[i] = numerator/sum_G_max
}


generator_entropy = rep(0,dim(casestudy_dataset)[1])
for (i in c(1:dim(casestudy_dataset)[1])) {
  print(i)
  for (j in c(start_label_g:end_label_g)) {
    if(casestudy_dataset[i,j]==0){
      generator_entropy[i] = generator_entropy[i]+0
    }else{
      g_i = abs(casestudy_dataset[i,j])/sum(abs(casestudy_dataset[i,c(start_label_g:end_label_g)]))
      generator_entropy[i] = generator_entropy[i] + (-g_i*log(g_i))
    }
  }
}

write.csv(fraction_generator_operating, file = "fraction_generator_operating.csv")
write.csv(generator_entropy, file = "generator_entropy.csv")
# over #
# ------------------------------------------------------------------------------ #

# dataset for TDA analysis #
for (kk in c(1:20001)) {
  if(sum(casestudy_dataset[kk,c(which(colnames(casestudy_dataset) == "F_1") : which(colnames(casestudy_dataset) == "F_186"))])!=0){
    print(kk)
    tmp_graph = output_graph_under_attack_f(case_118_network = input_graph, initial_status_row = 1, sequence_row = kk)
    tmp_graph = igraph::simplify(tmp_graph)
    tmp_graph = as.undirected(tmp_graph)
    tmp_weight_matrix = as_adjacency_matrix(tmp_graph,attr = "weight")
    tmp_weight_matrix = as.matrix(tmp_weight_matrix)
    tmp_weight_matrix = minmax_scale(tmp_weight_matrix)
    tmp_weight_matrix[tmp_weight_matrix==0] = 999
    diag(tmp_weight_matrix) = 0
    #write.table(tmp_weight_matrix,file=paste("weight_matrix_",kk-2,".csv",sep=""),sep = ";",col.names=FALSE, row.names = FALSE)
    write.csv(tmp_weight_matrix,file=paste("weight_matrix_",kk-1,".csv",sep=""))}
}



