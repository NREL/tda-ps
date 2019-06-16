# Set up packages and directories for common use.


# Activate the environment.

using Pkg

if isdefined(Main, :THE_ENV)
    Pkg.activate(joinpath(@__DIR__, "../environments", THE_ENV))
    if !isdefined(Main, :NO_INSTANTIATE)
        Pkg.instantiate()
    end
    Pkg.status()
end


# Use common packages.

using Combinatorics
using CSV
using DataFrames
using DataFramesMeta
using Distributions
using Ipopt
using JuMP
using MathOptInterface
using Random
using Setfield
using StatsBase
using TimeSeries

using Cairo
using Fontconfig
using Gadfly


# Metadata for models.

include("util.jl"    )
include("nesta.jl"   )
include("rts-gmlc.jl")


nothing
