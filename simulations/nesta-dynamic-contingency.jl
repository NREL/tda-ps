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


# Make all of the loads interruptible.

function makeinterruptible!(case_sys, sheddingcost=999)
    for i in 1:length(case_sys.loads)
        z = case_sys.loads[i]
        case_sys.loads[i] = PSY.InterruptibleLoad(
            z.name,
            z.available,
            z.bus,
            "0", # FIXME: What is this for?
            z.maxactivepower,
            z.maxreactivepower,
            sheddingcost, # FIXME: Is this large enough?
            z.scalingfactor
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
    @info string("Load demanded: ", demanded * case_sys.basepower, " MW")
    @info string("Load served:   ", served   * case_sys.basepower, " MW")
    @info string("Load shed:     ", shed     * case_sys.basepower, " MW")
end


# Run the cases.

####for case_data in NESTA_MODELS[1:1]
case_data = NESTA_MODELS[1]

    @info string("Solving ", case_data, " . . .")

    case_model = PSY.parse_file(case_data)
    case_dict = PSY.pm2ps_dict(case_model)
    for (k,l) in case_dict["load"]
        # Set to one time step.
        l["scalingfactor"] = l["scalingfactor"][1]
    end
    case_bus, case_gen, case_stor, case_branch, case_load, case_lz, case_shunts, case_service = ps_dict2ps_struct(case_dict)
    case_sys = PSY.System(case_bus, case_gen, case_load, case_branch, case_stor, 100.0)
    makeinterruptible!(case_sys)

    ####for alg in algs[3:3]
    alg = algs[3]

        case_opf = SheddingOptimalPowerFlow(case_sys, alg; optimizer = the_optimizer, parameters=true)
        case_soln = solve_op_model!(case_opf)

        @info string(" . . . ", String(Symbol(alg)), " ", Symbol(case_soln.optimizer_log[:termination_status]))
        loadreport(case_sys, case_soln)
        
        push!(nesta_summary, (
            case_data,
            basename(case_data)[1:(end-2)],
            length(case_opf.system.buses),
            length(case_opf.system.branches),
            String(Symbol(alg)),
            "Ipopt",
            Symbol(case_soln.optimizer_log[:termination_status]),
        ))

    ####end

####end


# Record the results.

println(nesta_summary)

CSV.write("nesta-dynamic-contingency.tsv", nesta_summary, delim="\t")
