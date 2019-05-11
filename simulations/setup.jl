# Activate the environment.

using Pkg

Pkg.activate(joinpath("environments", THE_ENV))
#Pkg.instantiate()
#Pkg.build()
Pkg.status()


# Use common packages.

using CSV
using DataFrames
using DataFramesMeta
using Gadfly
using JuMP
using Ipopt


# NESTA models.

NESTA_DIR = "../models/nesta-mirror/opf/"
NESTA_MODELS = map(x -> joinpath(NESTA_DIR, x), filter(x -> endswith(x, ".m"), readdir(NESTA_DIR)))
