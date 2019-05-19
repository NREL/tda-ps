# Set up packages and directories for common use.


# Activate the environment.

using Pkg

if isdefined(Main, :THE_ENV)
    Pkg.activate(joinpath("environments", THE_ENV))
    if !isdefined(Main, :NO_INSTANTIATE)
        Pkg.instantiate()
    end
    Pkg.status()
end


# Use common packages.

using CSV
using DataFrames
using DataFramesMeta
using Distributions
using Gadfly
using Ipopt
using JuMP
using MathOptInterface
using Setfield
using StatsBase
using TimeSeries


# NESTA models.

NESTA_DIR = "../models/nesta-mirror/opf/"
NESTA_MODELS = map(x -> joinpath(NESTA_DIR, x), filter(x -> endswith(x, ".m"), readdir(NESTA_DIR)))


# The RTS-GMLC model.

RTS_GMLC_DIR = "../models/RTS-GMLC/RTS_Data/SourceData"
