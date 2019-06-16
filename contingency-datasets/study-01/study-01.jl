# Run random permutations of bus contingencies.


# Set working directory.
cd(@__DIR__)


# Set-up packages and paths.

include("../../simulations/lib/powersimulations/setup.jl")


# Select the solver amd algorithms.

the_optimizer = with_optimizer(Ipopt.Optimizer, print_level = 0)

the_algorithm = PM.DCPlosslessForm


# Iterate over models.

run_multiple_contingencies(
    (case_sys -> permutations(bus_degrees(case_sys))),
    ((i, _) -> i)                                    ,
    directory=@__DIR__                               ,
)
