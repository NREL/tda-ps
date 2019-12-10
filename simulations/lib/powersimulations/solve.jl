# Solve a model and collect results.


"""
Solve optimal power flow with an interruptible device model for loads.
"""
function SheddingOptimalPowerFlow(system::PSY.System, transmission::Type{S}; optimizer::Union{Nothing,JuMP.OptimizerFactory}=nothing, kwargs...) where {S <: PM.AbstractPowerFormulation}
    devices = Dict{Symbol, PSI.DeviceModel}(:ThermalGenerators => PSI.DeviceModel(PSY.ThermalGen, PSI.ThermalDispatch),
                                            :RenewableGenerators => PSI.DeviceModel(PSY.RenewableGen, PSI.RenewableConstantPowerFactor),
                                            :Loads => PSI.DeviceModel(PSY.PowerLoad, PSI.InterruptiblePowerLoad))
    branches = Dict{Symbol, PSI.DeviceModel}(:Lines => PSI.DeviceModel(PSY.Branch, PSI.SeriesLine))
    services = Dict{Symbol, PSI.ServiceModel}(:Reserves => PSI.ServiceModel(PSY.Reserve, PSI.AbstractReservesForm))
    return PSI.PowerOperationModel(OptimalPowerFlow ,
                                   transmission,
                                    devices,
                                    branches,
                                    services,
                                    system,
                                    optimizer = optimizer; kwargs...)
end


"""
Extract results.
"""
function device_results(case_sys, model :: JuMP.Model; name2sequence = (x -> x))
    function rename(v)
        s = string(v)
        if occursin(r"^Pel_{.*,1}$", s)
            string("L_", name2sequence(replace(s, r"^Pel_{(.*),1}$" => s"\1")))
        elseif occursin(r"^Pth_{.*,1}$", s)
            replace(s, r"^Pth_{(.*),1}$" => s"G_\1")
        elseif occursin(r"^Pre_{.*,1}$", s)
            replace(s, r"^Pre_{(.*),1}$" => s"G_\1")
        elseif occursin(r"^Phy_{.*,1}$", s)
            replace(s, r"^Phy_{(.*),1}$" => s"G_\1")
        elseif occursin(r"^1_1_p", s)
            i = parse(Int64, replace(s, r"^1_1_p\[\((.*), .*, .*\)\]$" => s"\1"))
            string("F_", case_sys.branches[i].name)
        else
            nothing
        end
    end
    result = Dict{String,Any}(
        vcat(
            map(x -> string("L_", name2sequence(x.name)) => 0.0, case_sys.loads               ),
            map(x -> string("G_",               x.name ) => 0.0, case_sys.generators.thermal  ),
            map(x -> string("G_",               x.name ) => 0.0, case_sys.generators.renewable),
            map(x -> string("G_",               x.name ) => 0.0, case_sys.generators.hydro    ),
            map(x -> string("F_",               x.name ) => 0.0, case_sys.branches            ),
        )
    )
    for v in JuMP.all_variables(model)
        vr = rename(v)
        if !isnothing(vr)
            result[vr] = round(value(v), digits=5)
        end
    end
    result
end


"""
Sort results columns.
"""
function sort_results(z)
    function compare(x, y)
        x0 = string(x)
        y0 = string(y)
        x1 = replace(x0, r"_.*$" => s"")
        y1 = replace(y0, r"_.*$" => s"")
        x1 = islowercase(x1[1]) ? uppercase(x1) : lowercase(x1)
        y1 = islowercase(y1[1]) ? uppercase(y1) : lowercase(y1)
        x2 = parse(Int64, replace(x0, r"^.*_" => s""))
        y2 = parse(Int64, replace(y0, r"^.*_" => s""))
        x1 < y1 || x1 == y1 && x2 < y2
    end
    z = DataFrame(z)
    permutecols!(z, sort(names(z), lt=compare))
end


"""
Run a branch contingency case.
"""
function run_contingency(label, case_sys, devices :: Vector{T}; name2sequence = (x -> x)) where T <: Device
    contingencies = make_contingencies!(case_sys, devices, name2sequence=name2sequence)
    case_opf = SheddingOptimalPowerFlow(case_sys, the_algorithm; optimizer=the_optimizer, parameters=false)
    case_soln = solve_op_model!(case_opf)
    status = string(case_soln.optimizer_log[:termination_status])
    if status != "LOCALLY_SOLVED"
        @info string(" . . . ", status, " (sequence ", label, ")")
    end
    hcat(
        DataFrame(Sequence=label, Status=status),
        sort_results(
            merge(
                contingencies,
                available_devices(case_sys),
                device_results(case_sys, case_opf.canonical_model.JuMPmodel, name2sequence=name2sequence)
            )
        )
    )
end


"""
Run multiple contingencies.
"""
function run_multiple_contingencies(
    iter                                                                        ,
    next_contingency                                                            ;
    directory          = "."                                                    ,
    model_indices      = isdefined(Main, :NESTA_IDXS) ? NESTA_IDXS : [22, 1, 23],
    case_number_start  = isdefined(Main, :FIRST_CASE) ? FIRST_CASE : 1          ,
    case_number_finish = isdefined(Main, :LAST_CASE ) ? LAST_CASE  : 3          ,
    step_number_finish = isdefined(Main, :MAX_STEPS ) ? MAX_STEPS  : 5          ,
    statuses           = [
                           "ALMOST_LOCALLY_SOLVED",
                           "ITERATION_LIMIT"      ,
                           "LIMITS"               ,
                           "LOCALLY_INFEASIBLE"   ,
                           "LOCALLY_SOLVED"       ,
                           "NUMERICAL_ERROR"      ,
                         ]
)
    for case_data in NESTA_MODELS[model_indices]

        # Set output folder.
        prefix = joinpath(directory, replace(basename(case_data), r"\..*$" => s""))
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
        for i in iter(case_sys_backup)
            contingency_sequence = next_contingency(i, case_sys_backup)
            the_type = typeof(contingency_sequence[1])
            while !(the_type in [Bus, Branch, Generator])
                the_type = supertype(the_type)
            end
            contingency_sequence = convert(Vector{the_type}, contingency_sequence)
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
            for step_number in 0:min(step_number_finish, length(contingency_sequence))
                @debug string(" Step ", step_number)
                result = vcat(
                    result,
                    run_contingency(
                        step_number,
                        deepcopy(case_sys_backup),
                        contingency_sequence[1:step_number]
                    )
                )
                if !(result[end, :Status] in statuses)
                    break
                end
            end

            # Write the results.
            CSV.write(joinpath(prefix, string("result-", case_number, ".tsv")), result, delim="\t")

        end

    end

end
