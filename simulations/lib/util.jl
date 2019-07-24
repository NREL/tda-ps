# Utilities.


"""
Find a random permutation.
"""

function random_permutation(xs :: Vector{K}) where K <: Any
    is = randperm(length(xs))
    xs[is]
end

function random_permutation(xs :: Vector{Pair{K,V}}) where K <: Any where V <: Number
    random_permutation(map(x -> x[1], xs), map(x -> x[2], xs))
end

function random_permutation(xs, ws)
    sample(xs, FrequencyWeights(ws), length(xs), replace=false, ordered=false)
end
