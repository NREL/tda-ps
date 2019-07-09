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



# ------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------ #
# combine dataset #
casestudy_3_node_motifs_d = read.csv("casestudy_3_node_motifs_d.csv",row.names = 1)
casestudy_3_node_motifs_undirected = read.csv("casestudy_3_node_motifs_undirected.csv",row.names = 1)
casestudy_4_node_motifs_undirected = read.csv("casestudy_4_node_motifs_undirected.csv",row.names = 1)
casestudy_size_max_clique_undirected = read.csv("casestudy_size_max_clique_undirected.csv",row.names = 1)
casestudy_bus_3_node_motifs_mat = read.csv("casestudy_bus_3_node_motifs_mat.csv",row.names = 1)
casestudy_load_3_node_motifs_mat = read.csv("casestudy_load_3_node_motifs_mat.csv",row.names = 1)
casestudy_generator_3_node_motifs_mat = read.csv("casestudy_generator_3_node_motifs_mat.csv",row.names = 1)
casestudy_gl_3_node_motifs_mat = read.csv("casestudy_gl_3_node_motifs_mat.csv",row.names = 1)
casestudy_nianwu_percent_3_node_motifs = read.csv("casestudy_nianwu_percent_3_node_motifs.csv",row.names = 1)
casestudy_half_percent_3_node_motifs = read.csv("casestudy_half_percent_3_node_motifs.csv",row.names = 1)
casestudy_sevfif_percent_3_node_motifs = read.csv("casestudy_sevfif_percent_3_node_motifs.csv",row.names = 1)
load_entropy = read.csv("load_entropy.csv",row.names = 1)
fraction_generator_operating = read.csv("fraction_generator_operating.csv",row.names = 1)
generator_entropy = read.csv("generator_entropy.csv",row.names = 1)
fraction_load_served = read.csv("fraction_load_served.csv",row.names = 1)
casestudy_nianwu_percent_3_node_motifs[is.na(casestudy_nianwu_percent_3_node_motifs)]=0
casestudy_half_percent_3_node_motifs[is.na(casestudy_half_percent_3_node_motifs)]=0
casestudy_sevfif_percent_3_node_motifs[is.na(casestudy_sevfif_percent_3_node_motifs)]=0


comb_1 = cbind(casestudy_3_node_motifs_d,casestudy_3_node_motifs_undirected,casestudy_4_node_motifs_undirected,
               casestudy_size_max_clique_undirected,casestudy_bus_3_node_motifs_mat,casestudy_load_3_node_motifs_mat,
               casestudy_generator_3_node_motifs_mat,casestudy_gl_3_node_motifs_mat,casestudy_nianwu_percent_3_node_motifs,
               casestudy_half_percent_3_node_motifs,casestudy_sevfif_percent_3_node_motifs,load_entropy,fraction_generator_operating,generator_entropy)

text_template = c("3_m1_d","3_m2_d","3_m3_d","3_m4_d","3_m5_d","3_m6_d","3_m7_d","3_m8_d","3_m9_d","3_m10_d","3_m11_d",
                  "3_m12_d","3_m13_d")

colnames(comb_1) = c("3_m1_d","3_m2_d","3_m3_d","3_m4_d","3_m5_d","3_m6_d","3_m7_d","3_m8_d","3_m9_d","3_m10_d","3_m11_d",
                     "3_m12_d","3_m13_d","3_m1_und","3_m2_und","4_m1_und","4_m2_und","4_m3_und","4_m4_und","4_m5_und","4_m6_und","size_max_clique",
                     paste("bus_",text_template, sep=""),paste("load_",text_template, sep=""),paste("generator_",text_template, sep=""),
                     paste("generator&load_",text_template, sep=""),paste("25%_",text_template, sep=""),paste("50%_",text_template, sep=""),
                     paste("75%_",text_template, sep=""),"load_entropy","fraction_generator_operating","generator_entropy")


comb_2 = read.csv("regular_network_tda_metrics.csv",header = TRUE,row.names = 1) # for regular network
comb_3 = read.csv("multiplex_network_tda_metrics.csv",header = TRUE,row.names = 1) # for multiplex network

final_comb = cbind(comb_1,comb_2,comb_3) # 128 features
write.csv(final_comb,"new_features_combination_2.csv")
response_y = fraction_load_served
# over #



#--------------------------------------------xgboost--------------------------------------------#
x_train = as.matrix(final_comb[1:3500,])
x_test = as.matrix(final_comb[3501:5001,])
train_label = as.matrix(fraction_load_served)[1:3500]
test_label = as.matrix(fraction_load_served)[3501:5001]

library(xgboost)
library(Metrics)
param <- list(booster = "gblinear"
              , objective = "reg:linear"
              , subsample = 0.7
              , max_depth = 20
              , colsample_bytree = 0.7
              , eta = 1
              , eval_metric = 'mae'
              , base_score = 0.012 #average
              , min_child_weight = 100)

xgb = xgboost(params = param,
              data = x_train, 
              label = train_label
              , nrounds = 100
              , verbose = 1
              , print_every_n = 5
)

y_pred = predict(xgb, x_test)
mse = mean((test_label - y_pred)^2) #0.001152176 --> rmse: 3.394372%
mae = mean(abs(test_label - y_pred)) 
mape = mape(test_label, y_pred) 

importance <- xgb.importance(feature_names = colnames(final_comb), model = xgb)
print(xgb.plot.importance(importance_matrix = importance, measure = "Weight"))

#--------------------------------------------over--------------------------------------------#



#--------------------------------------------random forest--------------------------------------------#

x_train = as.matrix(final_comb[1:3500,])
x_test = as.matrix(final_comb[3501:5001,])
train_label = as.matrix(fraction_load_served)[1:3500]
test_label = as.matrix(fraction_load_served)[3501:5001]

model9<- randomForest(x_train,train_label, ntree = 300)

pred9<-predict(model9, x_test)

pred9 = as.numeric(pred9)

mean((test_label - pred9)^2) #4.88181e-05









# construct multiplex network #
# "/Users/yuzhouchen/Documents/NREL_works"
bus_thermal_match_table = read.csv("bus_thermal_match_table.csv",header = TRUE)

bus_thermal_match_table$G_label = paste("G_",bus_thermal_match_table$label,sep = "") # captial G #
bus_thermal_match_table = as.matrix(bus_thermal_match_table)

# graph with sequence = tmp/ii #
seq_tmp_graph = output_graph_under_attack_f(case_118_network = input_graph, initial_status_row = 1, sequence_row = ii)#ii
b_info = rep(NA, dim(bus_thermal_match_table)[1])

for (i in c(1:dim(bus_thermal_match_table)[1])) {
  if(sum(vertex_attr(seq_tmp_graph)$busname %in% bus_thermal_match_table[i,2])*1 > 0){
    b_info[i] = vertex_attr(seq_tmp_graph)$name[vertex_attr(seq_tmp_graph)$busname %in% bus_thermal_match_table[i,2]]
  }
}

bus_thermal_match_table_2 = cbind(bus_thermal_match_table, b_info)
bus_thermal_match_table_3 = bus_thermal_match_table[!is.na(bus_thermal_match_table_2[,5]), ]
#     generator   bus_info label G_label b_info 
#[1,] "thermal1"  "bus103" "32"  "G_32"  "b_72" 
#[2,] "thermal2"  "bus110" "29"  "G_29"  "b_66" 

seq_tmp_edgelist = cbind(get.edgelist(seq_tmp_graph),edge.attributes(seq_tmp_graph)$Branch_f, 
                         edge.attributes(seq_tmp_graph)$Branch_F,edge.attributes(seq_tmp_graph)$weight)
#     [,1]   [,2]    [,3]    [,4]    [,5]     
#[1,] "b_32" "b_114" "f_180" "F_180" "0.10065"
#[2,] "b_32" "b_113" "f_179" "F_179" "0.15684"

sender_g = 0
sender_l = 0
# sequence_row = j
if(seq_zero_edgelist[i,1] %in% bus_thermal_match_table_3[,5]){
  sender_g = sender_g+ casestudy_dataset[j,colnames(casestudy_dataset) %in% bus_thermal_match_table_3[,4][bus_thermal_match_table_3[,5] %in% seq_zero_edgelist[i,1]]]
}

label_num_sender = as.numeric(gsub("b_", "", seq_zero_edgelist[i,1]))
load_label_num_sender = paste("L_",label_num_sender,sep = "")

if(load_label_num_sender %in% colnames(casestudy_dataset)){
  sender_l = sender_l + casestudy_dataset[j,colnames(casestudy_dataset) %in% load_label_num_sender]
}

diff_sender = abs(sender_g - sender_l)



















