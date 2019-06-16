# Set up `PowerSimulations.jl` package and directory for common use.


# Include common packages and directories.

if !isdefined(Main, :THE_ENV)
    THE_ENV = "powersimulations.env"
end

include("../powermodels/setup.jl")


# Use PowerSystems.

using PowerSystems

"""
Type alias for PowerSystems.jl.
"""
PSY = PowerSystems

"""
Folder for PowerSystems.jl.
"""
PSY_DIR = dirname(dirname(pathof(PSY)))


# Use PowerSimulations.

using PowerSimulations

"""
Type alias for PowerSimulations.jl.
"""
PSI = PowerSimulations

"""
Folder for PowerSimulations.jl.
"""
PSI_DIR = dirname(dirname(pathof(PSI)))


# Define functions.

include("access.jl")
include("io.jl"    )
include("modify.jl")
include("solve.jl" )


nothing
