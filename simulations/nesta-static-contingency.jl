# Run all of the NESTA models using `PowerModels.jl` under contingency conditions.


# Set working directory.

if isdefined(Main, :SIIP_TDAPS_DIR)
    cd(SIIP_TDAPS_DIR)
end


# Set-up packages and paths.

THE_ENV = "powermodels.env"
include("setup-powermodels.jl")


# Select the solver amd algorithms.

the_solver = IpoptSolver()

algs = [
    PM.NFAPowerModel,
    PM.DCPPowerModel,
    PM.ACPPowerModel,
]

alg = algs[3]


# Read the model.

case_file = NESTA_MODELS[1]
case_data_backup = PM.parse_file(case_file)


# Run the base case.

case_data_base = deepcopy(case_data_backup)
case_soln_base = run_opf(case_data_base, alg, the_solver)


# Run a contingency case.

case_data_ctgy = deepcopy(case_data_backup)
case_data_ctgy["branch"]["12"]["br_status"] = 0

case_soln_ctgy = run_opf(case_data_ctgy, alg, the_solver)


# Compare the results.

println(case_soln_base)

println(case_soln_ctgy)
