# calculate the sum of generators with max #
seq_minus_1_G = result_1[1, which(colnames(result_1) == "G_1"):which(colnames(result_1) == "G_54")]
sum_G_max = sum(seq_minus_1_G)

# calculate the fraction of generator operating in each sequence #
fraction_generator_operating = vector(length = dim(result_1)[1] - 1)
start_label_g = which(colnames(result_1) == "G_1")
end_label_g = which(colnames(result_1) == "G_54")

for (i in c(1:dim(result_1)[1]-1)) {
  numerator = sum(result_1[i,start_label_g:end_label_g])
  fraction_generator_operating[i] = numerator/sum_G_max
}
