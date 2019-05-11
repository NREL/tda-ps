# Power System Simulations


## Setup

See [the main read-me file](../ReadMe.md) for instructions on setup up the power-system model data submodules.  These are required before running simulations.


# Simulations

Log files for all of the simulations below are archived in this folder.


### Examples

*   [example-powermodels.jl](example-powermodels.jl) uses `PowerModels.jl` for a static powerflow simulation.
*   [example-powersimulations.jl](example-powersimulations.jl) uses `PowerSimulations.jl` for a multi-timestep powerflow simulation.


### NESTA Cases

*   [nesta-static.jl](nesta-static.jl) runs all of the NESTA test cases using `PowerModels.jl` and stores a summary of results in [nesta-static.tsv](nesta-static.tsv).
*   [nesta-dynamic.jl](nesta-dynamic.jl) runs all of the NESTA test cases using `PowerSimulations.jl` and stores a summary of results in [nesta-dynamic.tsv](nesta-dynamic.tsv).


### RTS-GMLC Case

*   [rts-gmlc.jl](rts-gmlc.jl) runs the RTS-GMLC base base using `PowerSimulations.jl`
