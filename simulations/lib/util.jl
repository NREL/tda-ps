# Utilities.


"""
Find a random permutation.
"""
function random_permutation(xs)
    is = randperm(length(xs))
    xs[is]
end
