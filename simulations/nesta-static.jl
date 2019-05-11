# Set working directory.

if isdefined(Main, :SIIP_TDAPS_DIR)
    cd(SIIP_TDAPS_DIR)
end


# Set-up packages and paths.

THE_ENV = "powermodels.env"
include("setup-powermodels.jl")


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

    case_soln = run_dc_opf(case_data, IpoptSolver())
    @info string(" . . . DC ", case_soln["status"])
    push!(nesta_summary, (
        case_data,
        case_soln["data"]["name"],
        case_soln["data"]["bus_count"],
        case_soln["data"]["branch_count"],
        "DCPF",
        case_soln["solver"],
        case_soln["status"],
    ))

    case_soln = run_dc_opf(case_data, IpoptSolver())
    @info string(" . . . DC ", case_soln["status"])
    push!(nesta_summary, (
        case_data,
        case_soln["data"]["name"],
        case_soln["data"]["bus_count"],
        case_soln["data"]["branch_count"],
        "ACPF",
        case_soln["solver"],
        case_soln["status"],
    ))

end


# Record the results.

print(nesta_summary)

CSV.write("nesta-static.tsv", nesta_summary, delim="\t")
