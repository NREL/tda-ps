# Run all of the NESTA models using `PowerSimulations.jl`.


# Set working directory.

if isdefined(Main, :TDAPS_DIR)
    cd(TDAPS_DIR)
end


# Set-up packages and paths.

THE_ENV = "powersimulations.env"
include("../../simulations/setup-powersimulations.jl")


# Select the solver amd algorithms.

the_optimizer = with_optimizer(Ipopt.Optimizer, print_level = 0)

the_algorithm = PM.DCPlosslessForm


# Represent the network as a graph.

function writegraph(filename, case_sys)
    open(filename, "w") do f
        write(f, "graph {\n")
        write(f, "  overlap=false\n")
        for bus in case_sys.buses
            write(f, "  bus", string(bus.number), " [ label=\"", bus.name, "\" ]\n")
        end
        for branch in case_sys.branches
            write(f, "  bus", string(branch.connectionpoints.from.number), " -- bus", string(branch.connectionpoints.to.number), " [ label=\"", branch.name, "\" ]\n")
        end
        for i in 1:length(case_sys.loads)
            load = case_sys.loads[i]
            write(f, "  load", string(i), " [ shape=box color=maroon label=\"", load.name, "\" ]\n")
            write(f, "  load", string(i), " -- bus", string(load.bus.number), " [ style=dotted color=maroon ]\n")
        end
        if (!isnothing(case_sys.generators.thermal))
            for i in 1:length(case_sys.generators.thermal)
                generator = case_sys.generators.thermal[i]
                write(f, "  thermal", string(i), " [ shape=diamond color=peru label=\"", generator.name, "\" ]\n")
                write(f, "  thermal", string(i), " -- bus", string(generator.bus.number), " [ style=dashed color=peru ]\n")
            end
        end
        if (!isnothing(case_sys.generators.renewable))
            for i in 1:length(case_sys.generators.renewable)
                generator = case_sys.generators.renewable[i]
                write(f, "  renewable", string(i), " [ shape=triangle color=green label=\"", generator.name, "\" ]\n")
                write(f, "  renewable", string(i), " -- bus", string(generator.bus.number), " [ style=dashed color=green ]\n")
            end
        end
        if (!isnothing(case_sys.generators.hydro))
            for i in 1:length(case_sys.generators.hydro)
                generator = case_sys.generators.hydro[i]
                write(f, "  hydro", string(i), " [ shape=invtriangle color=turquoise label=\"", generator.name, "\" ]\n")
                write(f, "  hydro", string(i), " -- bus", string(generator.bus.number), " [ style=dashed color=turquoise ]\n")
            end
        end
        write(f, "}\n")
    end
end


# Make all of the loads interruptible.

function makeinterruptible!(case_sys, sheddingcost=1999)
    for i in 1:length(case_sys.loads)
        load = case_sys.loads[i]
        case_sys.loads[i] = PSY.InterruptibleLoad(
            load.name,
            load.available,
            load.bus,
            "0", # FIXME: What is this for?
            load.maxactivepower,
            load.maxreactivepower,
            sheddingcost, # FIXME: Is this large enough?
            load.scalingfactor
        )
    end
    Nothing
end


# Solve optimal power flow with an interruptible device model for loads.

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


# Sort the buses by descending degree.

function bus_degrees(case_sys)
    z = Dict()
    for x in case_sys.branches
        z[x.connectionpoints.from] = get(z, x.connectionpoints.from, 0) + (x.available ? 1 : 0)
        z[x.connectionpoints.to  ] = get(z, x.connectionpoints.to  , 0) + (x.available ? 1 : 0)
    end
    sort(
        collect(z),
        lt=((x, y) -> x[2] < y[2]),
        rev=true
    )
end


# Create contingencies at buses.

function bus_contingencies!(case_sys, buses)
    for i in 1:length(case_sys.generators.thermal)
        generator = case_sys.generators.thermal[i]
        if generator.bus in buses
            case_sys.generators.thermal[i] = @set generator.available = false
        end
    end
    for i in 1:length(case_sys.branches)
        branch = case_sys.branches[i]
        if branch.connectionpoints.from in buses || branch.connectionpoints.to in buses
            case_sys.branches[i] = @set branch.available = false
        end
    end
    Dict{String,Any}(
        map(
            x -> string("b_", x.name) => !(x in buses),
            case_sys.buses
        )
    )
end


function available_devices(case_sys)
    Dict{String,Any}(
        vcat(
            map(
                x -> string("g_", x.name) => x.available,
                case_sys.generators.thermal
            ),
            map(
                x -> string("f_", x.name) => x.available,
                case_sys.branches
            )
        )
    )
end


function device_limits(case_sys)
    Dict{String,Any}(
        vcat(
            map(x -> string("L_", x.name) => x.maxactivepower            , case_sys.loads             ),
            map(x -> string("G_", x.name) => x.tech.activepowerlimits.max, case_sys.generators.thermal),
            map(x -> string("F_", x.name) =>x.rate                       , case_sys.branches          ),
        )
    )
end


function device_results(case_sys, model :: JuMP.Model)
    function rename(v)
        s = string(v)
        if occursin(r"^Pel", s)
            replace(s, r"^Pel_{(.*),1}$" => s"L_\1")
        elseif occursin(r"^Pth", s)
            replace(s, r"^Pth_{(.*),1}$" => s"G_\1")
        elseif occursin(r"^1_1_p", s)
            replace(s, r"^1_1_p\[\((.*), .*, .*\)\]$" => s"F_\1")
      # elseif occursin(r"1_1_va", s)
      #     replace(s, r"^1_1_va\[(.*)\]$" => s"A_\1")
        else
            nothing
        end
    end
    result = Dict{String,Any}(
        vcat(
            map(x -> string("L_", x.name) => 0.0, case_sys.loads             ),
            map(x -> string("G_", x.name) => 0.0, case_sys.generators.thermal),
            map(x -> string("F_", x.name) => 0.0, case_sys.branches          ),
        )
    )
    for v in JuMP.all_variables(model)
        vr = rename(v)
        if !isnothing(vr)
            result[vr] = value(v)
        end
    end
    result
end


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


function collect_limits(case_sys)
    hcat(
        DataFrame(Sequence=-1, Status="LIMITS"),
        sort_results(
            merge(
                bus_contingencies!(case_sys, []),
                available_devices(case_sys),
                device_limits(case_sys)
            )
        )
    )
end


function run_contingency(label, case_sys, buses)
    contingencies = bus_contingencies!(case_sys, buses)
    case_opf = SheddingOptimalPowerFlow(case_sys, the_algorithm; optimizer=the_optimizer, parameters=false)
    case_soln = solve_op_model!(case_opf)
    status = string(case_soln.optimizer_log[:termination_status])
    if status != "LOCALLY_SOLVED"
        @info string(" . . . ", status)
    end
    hcat(
        DataFrame(Sequence=label, Status=status),
        sort_results(
            merge(
                contingencies,
                available_devices(case_sys),
                device_results(case_sys, case_opf.canonical_model.JuMPmodel)
            )
        )
    )
end


# Set up the model.

case_data = NESTA_MODELS[22]

case_model = PSY.parse_file(case_data)
case_dict = PSY.pm2ps_dict(case_model)
for (k, l) in case_dict["load"]
    # Set to one time step.
    l["scalingfactor"] = l["scalingfactor"][1]
end
case_bus, case_gen, case_stor, case_branch, case_load, case_lz, case_shunts, case_service = ps_dict2ps_struct(case_dict)
case_sys_backup = PSY.System(case_bus, case_gen, case_load, case_branch, case_stor, 100.0)
makeinterruptible!(case_sys_backup)

prefix = joinpath("..", "contingency-datasets", "study-01", "result-")

case_number_max = 5
case_number = 0
for bus_sequence in permutations(bus_degrees(case_sys_backup))

    if case_number < case_number_max
        global case_number += 1
    else
        break
    end

    @info string("Case ", case_number)

    result = collect_limits(case_sys_backup)

    for step_number in 0:length(bus_sequence)
        result =
            vcat(
                result,
                run_contingency(
                    step_number,
                    deepcopy(case_sys_backup),
                    step_number == 0 ? [] : map(x -> x[1], bus_sequence[1:step_number])
                )
            )
    end

    CSV.write(string(prefix, case_number, ".tsv"), result, delim="\t")

end
