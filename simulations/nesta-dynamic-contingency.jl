# Run all of the NESTA models using `PowerSimulations.jl`.


# Set working directory.

if isdefined(Main, :TDAPS_DIR)
    cd(TDAPS_DIR)
end


# Set-up packages and paths.

THE_ENV = "powersimulations.env"
include("setup-powersimulations.jl")


# Select the solver amd algorithms.

the_optimizer = with_optimizer(Ipopt.Optimizer, print_level = 0)

algs = [
    PSI.CopperPlatePowerModel,
    PM.DCPlosslessForm,
    PM.StandardACPForm,
]


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

function makeinterruptible!(case_sys, sheddingcost=999)
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


# Create contingencies.

function makecontingent!(buses :: Vector{PSY.Bus}; lambda=1, contingency=0)
    DataFrame(Contingency=Int64[], Bus=String[], Available=Bool[])
end

function makecontingent!(branches :: Vector{PSY.Branch}; lambda=1, contingency=0)
    nmax = lambda == 0 ? 0 : rand(Poisson(lambda)) + 1
    indices = 1:length(branches)
    table = DataFrame(Contingency=Int64[], Branch=String[], Available=Bool[])
    for i in sample(indices, min(length(indices), nmax))
        branch = branches[i]
        branches[i] = @set branch.available = false
        push!(table, (contingency, branch.name, false))
    end
    table
end

function makecontingent!(generators :: Vector{PSY.ThermalDispatch}; lambda=1, contingency=0)
    nmax = lambda == 0 ? 0 : rand(Poisson(lambda)) + 1
    indices = 1:length(generators)
    table = DataFrame(Contingency=Int64[], Generator=String[], Available=Bool[])
    for i in sample(indices, min(length(indices), nmax))
        generator = generators[i]
        generators[i] = @set generator.available = false
        push!(table, (contingency, generator.name, false))
    end
    table
end


# Total the loads served or shed.

function loadserved(case_soln)
    result = case_soln.variables[:Pel]
    map(x -> result[1,x], names(result)) |> sum
end

function loaddemanded(case_sys)
    map(x -> x.maxactivepower, case_sys.loads) |> sum
end

function loadshed(case_sys, case_soln)
    loaddemanded(case_sys) - loadserved(case_soln)
end

function loadreport(case_sys, case_soln)
    demanded = loaddemanded(case_sys)
    served = loadserved(case_soln)
    shed = demanded - served
    @info string("Load demanded: ", demanded * case_sys.basepower, " MWh")
    @info string("Load served:   ", served   * case_sys.basepower, " MWh")
    @info string("Load shed:     ", shed     * case_sys.basepower, " MWh")
end

function loadtable(case_sys, case_soln, contingency=0)
    scale = case_sys.basepower
    result = case_soln.variables[:Pel]
    result = Dict(map(x -> string(x) => result[1,x], names(result)))
    table = DataFrame(Contingency=Int64[], Load=String[], Demanded_MWh=Float64[], Served_MWh=Float64[], Shed_MWh=Float64[])
    for load in case_sys.loads
        name = load.name
        demanded = scale * load.maxactivepower
        served   = scale * result[name]
        push!(table, (contingency, name, demanded, served, demanded - served))
    end
    table
end


# Run the cases.

if !isdefined(Main, :NESTA_CONTINGENCIES)
    NESTA_CONTINGENCIES = 5
end

NESTA_MODELS = [
    "../models/nesta-mirror/opf/nesta_case118_ieee.m"   ,
    "../models/nesta-mirror/opf/nesta_case30_ieee.m"    ,
    "../models/nesta-mirror/opf/nesta_case3120sp_mp.m"  ,
    "../models/nesta-mirror/opf/nesta_case73_ieee_rts.m",
]

for case_data in NESTA_MODELS

    prefix = joinpath("..", "contingency-datasets", "shedding", basename(case_data)[1:(end-2)])

    lastcontingency = -1
    if isfile(string(prefix, "_load.tsv"))
        lastcontingency = maximum(CSV.read(string(prefix, "_load.tsv"), delim="\t").Contingency)
    end

    @info string("Solving ", case_data, " . . .")

    case_model = PSY.parse_file(case_data)
    case_dict = PSY.pm2ps_dict(case_model)
    for (k, l) in case_dict["load"]
        # Set to one time step.
        l["scalingfactor"] = l["scalingfactor"][1]
    end
    case_bus, case_gen, case_stor, case_branch, case_load, case_lz, case_shunts, case_service = ps_dict2ps_struct(case_dict)
    case_sys_backup = PSY.System(case_bus, case_gen, case_load, case_branch, case_stor, 100.0)
    makeinterruptible!(case_sys_backup)

    for alg in algs[3:3]

        nesta_summary = DataFrame(
            File=String[],
            Model=String[],
            Algorithm=String[],
            Solver=String[],
            Status=Symbol[],
            Buses=Int64[],
            Branches=Int64[],
            Generators=Int64[],
            Contingency=Int64[],
            BusContingencies=Int64[],
            BranchContingencies=Int64[],
            GeneratorContingencies=Int64[],
            Demanded_MWh=Float64[],
            Served_MWh=Float64[],
            Shed_MWh=Float64[],
        )

        for contingency in lastcontingency .+ (1:NESTA_CONTINGENCIES)

            case_sys = deepcopy(case_sys_backup)
            buscontingencies       = makecontingent!(case_sys.buses             , lambda=0                       , contingency=contingency)
            branchcontingencies    = makecontingent!(case_sys.branches          , lambda=contingency == 0 ? 0 : 2, contingency=contingency)
            generatorcontingencies = makecontingent!(case_sys.generators.thermal, lambda=0                       , contingency=contingency)

            if true
                case_opf = SheddingOptimalPowerFlow(case_sys, alg; optimizer=the_optimizer, parameters=false)
            else
                case_opf = EconomicDispatch(case_sys, alg)
                case_opf.devices[:Loads] = PSI.DeviceModel(PSY.PowerLoad, PSI.InterruptiblePowerLoad)
                PSI.build_op_model!(case_opf; optimizer=the_optimizer, parameters=false)
            end
            case_soln = solve_op_model!(case_opf)

            @info string(" . . . ", Symbol(alg), " ", Symbol(case_soln.optimizer_log[:termination_status]))
            @info string("Bus contingencies:       ", size(buscontingencies      , 1))
            @info string("Branch contingencies:    ", size(branchcontingencies   , 1))
            @info string("Generator contingencies: ", size(generatorcontingencies, 1))
            loadreport(case_sys, case_soln)

            push!(nesta_summary, (
                case_data,
                basename(case_data)[1:(end-2)],
                string(Symbol(alg)),
                string(the_optimizer.constructor),
                Symbol(case_soln.optimizer_log[:termination_status]),
                length(case_opf.system.buses),
                length(case_opf.system.branches),
                length(case_opf.system.generators.thermal),
                contingency,
                size(buscontingencies, 1),
                size(branchcontingencies, 1),
                size(generatorcontingencies, 1),
                loaddemanded(case_sys),
                loadserved(case_soln),
                loadshed(case_sys, case_soln),
            ))

            if contingency == 0 && case_soln.optimizer_log[:termination_status] != MathOptInterface.LOCALLY_SOLVED
                break
            end

            CSV.write(string(prefix, "_load.tsv"     ), loadtable(case_sys, case_soln, contingency), delim="\t", append=contingency!=0)
            CSV.write(string(prefix, "_bus.tsv"      ), buscontingencies                           , delim="\t", append=contingency!=0)
            CSV.write(string(prefix, "_branch.tsv"   ), branchcontingencies                        , delim="\t", append=contingency!=0)
            CSV.write(string(prefix, "_generator.tsv"), generatorcontingencies                     , delim="\t", append=contingency!=0)

        end

        CSV.write(string(prefix, "_summary.tsv"), nesta_summary, delim="\t", append=lastcontingency>0)
        if !isfile(joinpath("..", "contingency-datasets", string(basename(case_data)[1:(end-2)], ".dot")))
            writegraph(joinpath("..", "contingency-datasets", string(basename(case_data)[1:(end-2)], ".dot")), case_sys_backup)
        end

    end

end
