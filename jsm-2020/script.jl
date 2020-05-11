

# Activate the environment.

using Pkg
Pkg.activate(".")


# Load general packates.

using CSV
using DataFrames
using DataFramesMeta
using Logging
using Setfield
using Statistics
using StatsBase


# Load optimization packages.

using JuMP, MathOptInterface
using Cbc


# Load SIIP packages.

using InfrastructureModels, InfrastructureSystems, PowerSystems, PowerSimulations


# Make all of the loads interruptible.

function make_interruptible!(case_sys, sheddingcost = TwoPartCost(1e4, 1e4))
    case_sys.data.components.data[InterruptibleLoad] = Dict{String, InterruptibleLoad}(
        [
            name => InterruptibleLoad(
                load.name            ,
                load.available       ,
                load.bus             ,
                load.model           ,
                load.activepower     ,
                load.reactivepower   ,
                load.maxactivepower  ,
                load.maxreactivepower,
                sheddingcost         ,
                load.services        ,
                load.ext             ,
                load.forecasts       ,
                load.internal        ,
            )
            for (name, load) in case_sys.data.components.data[PowerLoad]
        ])
    delete!(case_sys.data.components.data, PowerLoad)
    Nothing
end


# Create contingencies.

function make_contingencies!(case_sys, device, names; remove = true)
    components = case_sys.data.components
    if remove
        for name in names
            remove_component!(device, case_sys, name)
        end
    else
        collection = components.data[device]
        for name in names
            component = collection[name]
            collection[name] = @set component.available = false
        end
    end
end


# Simulate contingencies.

function simulate_contingency(case, system_base, device_type, device_count, optimizer)
    system = deepcopy(system_base)
    make_interruptible!(system)
    candidates = [device.name for device in get_components(device_type, system)] |> sort
    selection = sample(candidates, device_count, replace = false)
    make_contingencies!(system, device_type, selection)
    problem = OperationsProblem(
        GenericOpProblem,
        template_economic_dispatch(
            network = DCPPowerModel,
            devices = Dict{Symbol, DeviceModel}(
                :ILoads     => DeviceModel(InterruptibleLoad, DispatchablePowerLoad ),
                :Generators => DeviceModel(ThermalStandard  , ThermalDispatch       ),
            ),
            branches = Dict{Symbol, DeviceModel}(
                :T => DeviceModel(Transformer2W, StaticTransformer),
                :L => DeviceModel(Line         , StaticLine       ),
            ),
        ),
        system,
        use_forecast_data = false,
        optimizer = optimizer,
    )
    solved = false
    exception = nothing
    loads = nothing
    devices = unstack(DataFrame(
        Case     = repeat([case], length(candidates))            ,
        variable = candidates                                    ,
        value    = [device in selection for device in candidates],
    ))
    try
        configure_logging(console_level = Logging.Error)
        result = solve!(problem)
        configure_logging(console_level = Logging.Info)
        solved = get_optimizer_log(result)[:termination_status] == MathOptInterface.OPTIMAL
        loads = hcat(
            DataFrame(Case = case)                                       ,
            system.basepower .* get_variables(result)[:P__InterruptibleLoad],
        )
    catch e
        exception = e
    end
    (
        solved      = solved     ,
        exception   = exception  ,
        device_type = device_type,
        devices     = devices    ,
        loads       = loads      ,
    )
end


# Select the optimizer.

verbose = false;
the_optimizer = optimizer_with_attributes(
    Cbc.Optimizer                  ,
    "logLevel" => (verbose ? 1 : 0),
    "threads"  => 12               ,
    "ratioGap" => 0.5              ,
);


# Read the system data.

power_system = TamuSystem("PowerSystemsTestData/ACTIVSg2000", time_series_in_memory = true);


# Simulate some contingencies.

if !isdefined(Main, :FIRST_CASE)
    FIRST_CASE = 1
end
case = FIRST_CASE
@info string("FIRST_CASE = ", case)

if !isdefined(Main, :OUTPUT_DIR)
    OUTPUT_DIR = "."
end
output_dir = OUTPUT_DIR
@info string("OUTPUT_DIR = ", output_dir)

device_type   = eval(DEVICE_TYPE)
@info string("DEVICE_TYPE = ", DEVICE_TYPE)

device_counts = eval(DEVICE_COUNTS)
@info string("DEVICE_COUNTS = ", DEVICE_COUNTS)

sample_size   = eval(SAMPLE_SIZE)
@info string("SAMPLE_SIZE = ", SAMPLE_SIZE)

inputs  = true
outputs = true
for device_count in device_counts
    for i in 1:sample_size
        result = simulate_contingency(case, power_system, device_type, device_count, the_optimizer);
        global case += 1
        CSV.write(joinpath(output_dir, string(device_type, "-devices.tsv")), result.devices, delim = "\t", append = !inputs)
        global inputs = false
        if result.solved
            CSV.write(joinpath(output_dir, string(device_type, "-loads.tsv")), result.loads, delim = "\t", append = !outputs)
            global outputs = false
        end
    end
end
