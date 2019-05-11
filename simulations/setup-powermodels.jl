# Activate the environment.

using Pkg

Pkg.activate(joinpath("environments", THE_ENV))
#Pkg.instantiate()
#Pkg.build()
Pkg.status()


# Use PowerModels.

using PowerModels
PM = PowerModels
PM_DIR = dirname(dirname(pathof(PM)))
