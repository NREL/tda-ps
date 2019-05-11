# Set up `PowerSimulations.jl` package and directory for common use.


# Include common packages and directories.

include("setup-powermodels.jl")


# Use PowerSystems.

using PowerSystems
PSY = PowerSystems
PSY_DIR = dirname(dirname(pathof(PSY)))


# Use PowerSimulations.

using PowerSimulations
PSI = PowerSimulations
PSI_DIR = dirname(dirname(pathof(PSI)))
