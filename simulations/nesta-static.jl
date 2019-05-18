# Run all of the NESTA models using `PowerModels.jl`.


# Set working directory.

if isdefined(Main, :TDAPS_DIR)
    cd(TDAPS_DIR)
end


# Set-up packages and paths.

THE_ENV = "powermodels.env"
include("setup-powermodels.jl")


# Select the solver amd algorithms.

the_solver = IpoptSolver()

algs = [

    # Exact non-convex models.
    PM.ACPPowerModel,
    PM.ACRPowerModel,
    PM.ACTPowerModel,

    # Linear approximations.
    PM.NFAPowerModel,
    PM.DCPPowerModel,

    # Quadratic approximations.
    PM.DCPLLPowerModel,
    PM.LPACCPowerModel,

    # Quadratic relaxations.
    PM.SOCWRPowerModel,
    PM.QCWRPowerModel,
    PM.SOCWRConicPowerModel,
    PM.QCWRTriPowerModel,
    PM.SOCBFPowerModel,
    PM.SOCBFConicPowerModel,

    # SDP relaxations.
    PM.SDPWRMPowerModel,
    PM.SparseSDPWRMPowerModel,

][[1, 4, 5]]

println(algs)


# Create and solve the model using PowerSimulations.

nesta_summary = DataFrame(
    File=String[],
    Model=String[],
    Buses=Int64[],
    Branches=Int64[],
    Algorithm=String[],
    Solver=String[],
    Status=Symbol[],
)

for case_data in NESTA_MODELS

    @info string("Solving ", case_data, " . . .")

    for alg in algs

        case_soln = run_opf(case_data, alg, the_solver)
        @info string(" . . . ", String(Symbol(alg)), " ", case_soln["status"])

        push!(nesta_summary, (
            case_data,
            case_soln["data"]["name"],
            case_soln["data"]["bus_count"],
            case_soln["data"]["branch_count"],
            String(Symbol(alg)),
            case_soln["solver"],
            case_soln["status"],
        ))

    end

end


# Record the results.

println(nesta_summary)

CSV.write("nesta-static.tsv", nesta_summary, delim="\t")
