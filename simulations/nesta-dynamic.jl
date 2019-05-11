# Run all of the NESTA models using `PowerSimulations.jl`.


# Set working directory.

if isdefined(Main, :SIIP_TDAPS_DIR)
    cd(SIIP_TDAPS_DIR)
end


# Set-up packages and paths.

THE_ENV = "powersimulations.env"
include("setup-powersimulations.jl")


# Select the optimizer.

the_optimizer = with_optimizer(Ipopt.Optimizer, print_level = 0)


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

    case_model = PSY.parse_file(case_data)
    case_dict = PSY.pm2ps_dict(case_model)
    for (k,l) in case_dict["load"]
        # Set to one time step.
        l["scalingfactor"] = l["scalingfactor"][1]
    end
    case_bus, case_gen, case_stor, case_branch, case_load, case_lz, case_shunts, case_service = ps_dict2ps_struct(case_dict)
    case_sys = PSY.System(case_bus, case_gen, case_load, case_branch, case_stor, 100.0)

    for alg in [PSI.CopperPlatePowerModel, PM.DCPlosslessForm]

        case_ed = PSI.EconomicDispatch(case_sys, alg; optimizer = the_optimizer)
        case_soln = solve_op_model!(case_ed)

        @info string(" . . . ", String(Symbol(alg)), " ", Symbol(case_soln.optimizer_log[:termination_status]))
        push!(nesta_summary, (
            case_data,
            basename(case_data)[1:(end-2)],
            length(case_ed.system.buses),
            length(case_ed.system.branches),
            String(Symbol(alg)),
            "Ipopt",
            Symbol(case_soln.optimizer_log[:termination_status]),
        ))

    end

end


# Record the results.

print(nesta_summary)

CSV.write("nesta-dynamic.tsv", nesta_summary, delim="\t")
