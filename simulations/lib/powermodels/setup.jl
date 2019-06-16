# Set up `PowerModels.jl` package and directory for common use.


# Include common packages and directories.

if !isdefined(Main, :THE_ENV)
    THE_ENV = "powermodels.env"
end

include("../setup.jl")


# Use PowerModels.

using PowerModels

"""
Type alias for PowerModels.jl.
"""
PM = PowerModels

"""
Folder for PowerModels.jl.
"""
PM_DIR = dirname(dirname(pathof(PM)))


nothing
