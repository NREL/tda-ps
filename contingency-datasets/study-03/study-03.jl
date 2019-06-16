# Run branch contingencies.


# Set working directory.

if isdefined(Main, :TDAPS_DIR)
    cd(TDAPS_DIR)
end


# Set-up packages and paths.

THE_ENV = "powersimulations.env"
include("../../simulations/setup-powersimulations.jl")


# Include functions.

include("../common.jl")


# Iterate over models.

case_number_start  = isdefined(Main, :FIRST_CASE) ? FIRST_CASE : 1
case_number_finish = isdefined(Main, :LAST_CASE ) ? LAST_CASE  : 5
step_number_finish = isdefined(Main, :MAX_STEPS ) ? MAX_STEPS  : 50

for case_data in NESTA_MODELS[[22, 1, 23]]

    # Set output folder.
    prefix = joinpath("..", "contingency-datasets", "study-03", replace(basename(case_data), r"\..*$" => s""))
    if !isdir(prefix)
        mkdir(prefix)
    end

    # Read and create the system model.
    case_model = PSY.parse_file(case_data)
    case_dict = PSY.pm2ps_dict(case_model)
    for (k, l) in case_dict["load"]
        # Set to one time step.
        l["scalingfactor"] = l["scalingfactor"][1]
    end
    case_bus, case_gen, case_stor, case_branch, case_load, case_lz, case_shunts, case_service = ps_dict2ps_struct(case_dict)
    case_sys_backup = PSY.System(case_bus, case_gen, case_load, case_branch, case_stor, 100.0)
    makeinterruptible!(case_sys_backup)

    # Write a description of the model.
    writesystem(prefix, case_sys_backup)
    writegraph(joinpath(prefix, "graph.dot"), case_sys_backup)

    # Run contingencies.
    case_number = 0
    while true
        branch_sequence = random_permutation(case_sys_backup.branches)
        if case_number < case_number_finish
            case_number += 1
            if case_number < case_number_start
                continue
            end
        else
            break
        end
        @info string("Case ", case_number)

        # Collect device limits.
        result = collect_limits(case_sys_backup)

        # Iterate over sequence of contingencies.
        for step_number in 0:min(step_number_finish, length(branch_sequence))
#           @info string(" Step ", step_number)
            result = vcat(
                result,
                run_contingency(
                    step_number,
                    deepcopy(case_sys_backup),
                    step_number == 0 ? [] : branch_sequence[1:step_number]
                )
            )
        end

        # Write the results.
        CSV.write(joinpath(prefix, string("result-", case_number, ".tsv")), result, delim="\t")

    end

end
