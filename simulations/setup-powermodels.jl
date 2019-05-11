# Set up `PowerModels.jl` package and directory for common use.


# Include common packages and directories.

include("setup.jl")


# Use PowerModels.

using PowerModels
PM = PowerModels
PM_DIR = dirname(dirname(pathof(PM)))
