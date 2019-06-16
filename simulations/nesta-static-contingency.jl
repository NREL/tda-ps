# Run all of the NESTA models using `PowerModels.jl` under contingency conditions.


# Set working directory.

cd(@__DIR__)


# Set-up packages and paths.

include("lib/powermodels/setup.jl")


# Select the solver amd algorithms.

the_solver = IpoptSolver()

algs = [
    PM.NFAPowerModel,
    PM.DCPPowerModel,
    PM.ACPPowerModel,
]

alg = algs[3]

function run_opf_custom(case_data)
    run_opf(case_data, alg, the_solver, setting=Dict("output" => Dict("branch_flows" => true)))
end


# Read the model.

case_file = NESTA_MODELS[1]
case_data_backup = PM.parse_file(case_file)


# Run the base case.

case_data_base = deepcopy(case_data_backup)
case_soln_base = run_opf_custom(case_data_base)


# Run a contingency case.

case_data_ctgy = deepcopy(case_data_backup)
case_data_ctgy["branch"]["12"]["br_status"] = 0

case_soln_ctgy = run_opf_custom(case_data_ctgy)


# Compare the results.

println(case_soln_base)

println(case_soln_ctgy)
