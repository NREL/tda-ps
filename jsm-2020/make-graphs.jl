

# Activate the environment.

using Pkg
Pkg.activate(".")


# Load general packates.

using CSV
using DataFrames
using DataFramesMeta
using LightGraphs
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


# Select the optimizer.

verbose = false;
the_optimizer = optimizer_with_attributes(
    Cbc.Optimizer                  ,
    "logLevel" => (verbose ? 1 : 0),
    "threads"  => 1                ,
    "ratioGap" => 0.5              ,
);


# Read the system data.

power_system = TamuSystem("PowerSystemsTestData/ACTIVSg2000", time_series_in_memory = true);


# Solve the base case power flow.

system = deepcopy(power_system)
make_interruptible!(system)
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
    optimizer = the_optimizer,
)
result = solve!(problem)


# Write a GML file with the system and results.

open("ACTIVSg2000.gml", "w") do f
    components = power_system.data.components.data
    variables = get_variables(result)
    write(f, "graph [\n")
    netmaxpower = Dict{String, Float64}()
    netpower = Dict{String, Float64}()
    for (name, bus) in components[Bus]
      netmaxpower[name] = 0
      netpower[   name] = 0
    end
    for (name, generator) in components[ThermalStandard]
      netmaxpower[generator.bus.name] += generator.activepowerlimits.max
      netpower[   generator.bus.name] += variables[:P__ThermalStandard][1, Symbol(name)]
    end
    for (name, load) in components[PowerLoad]
      netmaxpower[load.bus.name] -= load.activepower
      netpower[   load.bus.name] -= variables[:P__InterruptibleLoad][1, Symbol(name)]
    end
    last_id = 0
    for (name, bus) in components[Bus]
        write(f, "  node [\n")
        write(f, "    id          ", string(bus.number), "\n")
        write(f, "    label       \"", name, "\"\n")
        write(f, "    device      \"Bus\"\n")
        write(f, "    netmaxpower ", string(netmaxpower[name] * power_system.basepower), "\n")
        write(f, "    netpower    ", string(   netpower[name] * power_system.basepower), "\n")
        write(f, "  ]\n")
        last_id = max(last_id, bus.number)
    end
    last_id += 1
    generators = Dict{String, Int64}()
    for (name, generator) in components[ThermalStandard]
        maxpower = generator.activepowerlimits.max * power_system.basepower
        power    = variables[:P__ThermalStandard][1, Symbol(name)] * power_system.basepower
        write(f, "  node [\n")
        write(f, "    id       ", string(last_id), "\n")
        write(f, "    label    \"", name, "\"\n")
        write(f, "    device   \"ThermalStandard\"\n")
        write(f, "    maxpower ", string(maxpower             ), "\n")
        write(f, "    power    ", string(power                ), "\n")
        write(f, "    residue  ", string(maxpower - abs(power)), "\n")
        write(f, "  ]\n")
        generators[name] = last_id
        last_id += 1
    end
    loads = Dict{String, Int64}()
    for (name, load) in components[PowerLoad]
        maxpower = load.activepower * power_system.basepower
        power    = variables[:P__InterruptibleLoad][1, Symbol(name)] * power_system.basepower
        write(f, "  node [\n")
        write(f, "    id       ", string(last_id), "\n")
        write(f, "    label    \"", name, "\"\n")
        write(f, "    device   \"PowerLoad\"\n")
        write(f, "    maxpower ", string(maxpower             ), "\n")
        write(f, "    power    ", string(power                ), "\n")
        write(f, "    residue  ", string(maxpower - abs(power)), "\n")
        write(f, "  ]\n")
        loads[name] = last_id
        last_id += 1
    end
    for (name, line) in components[Line]
        maxpower = line.rate * power_system.basepower
        power    = variables[:Fp__Line][1, Symbol(name)] * power_system.basepower
        write(f, "  edge [\n")
        write(f, "    source     ", string(power > 0 ? line.arc.from.number : line.arc.to.number  ), "\n")
        write(f, "    target     ", string(power > 0 ? line.arc.to.number   : line.arc.from.number), "\n")
        write(f, "    label      \"", name, "\"\n")
        write(f, "    device     \"Line\"\n")
        write(f, "    resistance ", string(line.r), "\n")
        write(f, "    reactance  ", string(line.x), "\n")
        write(f, "    maxpower   ", string(maxpower             ), "\n")
        write(f, "    power      ", string(           abs(power)), "\n")
        write(f, "    residue    ", string(maxpower - abs(power)), "\n")
        write(f, "    count       1\n")
        write(f, "  ]\n")
    end
    for (name, line) in components[Transformer2W]
        maxpower = line.rate * power_system.basepower
        power    = variables[:Fp__Transformer2W][1, Symbol(name)] * power_system.basepower
        write(f, "  edge [\n")
        write(f, "    source     ", string(power > 0 ? line.arc.from.number : line.arc.to.number  ), "\n")
        write(f, "    target     ", string(power > 0 ? line.arc.to.number   : line.arc.from.number), "\n")
        write(f, "    label      \"", name, "\"\n")
        write(f, "    device     \"Transformer2W\"\n")
        write(f, "    resistance ", string(line.r), "\n")
        write(f, "    reactance  ", string(line.x), "\n")
        write(f, "    maxpower   ", string(maxpower             ), "\n")
        write(f, "    power      ", string(           abs(power)), "\n")
        write(f, "    residue    ", string(maxpower - abs(power)), "\n")
        write(f, "    count       1\n")
        write(f, "  ]\n")
    end
    for (name, generator) in components[ThermalStandard]
        maxpower = generator.activepowerlimits.max * power_system.basepower
        power    = variables[:P__ThermalStandard][1, Symbol(name)] * power_system.basepower
        write(f, "    power    ", string(variables[:P__ThermalStandard][1, Symbol(name)] * power_system.basepower), "\n")
        write(f, "  edge [\n")
        write(f, "    source   ", string(generators[name]), "\n")
        write(f, "    target   ", string(generator.bus.number), "\n")
        write(f, "    label    \"", name, "\"\n")
        write(f, "    device   \"ThermalStandard\"\n")
        write(f, "    maxpower ", string(maxpower             ), "\n")
        write(f, "    power    ", string(           abs(power)), "\n")
        write(f, "    residue  ", string(maxpower - abs(power)), "\n")
        write(f, "    count       1\n")
        write(f, "  ]\n")
    end
    for (name, load) in components[PowerLoad]
        maxpower = load.activepower * power_system.basepower
        power    = variables[:P__InterruptibleLoad][1, Symbol(name)] * power_system.basepower
        write(f, "  edge [\n")
        write(f, "    source   ", string(loads[name]), "\n")
        write(f, "    target   ", string(load.bus.number), "\n")
        write(f, "    label    \"", name, "\"\n")
        write(f, "    device   \"PowerLoad\"\n")
        write(f, "    maxpower ", string(maxpower             ), "\n")
        write(f, "    power    ", string(           abs(power)), "\n")
        write(f, "    residue  ", string(maxpower - abs(power)), "\n")
        write(f, "    count       1\n")
        write(f, "  ]\n")
    end
    write(f, "]\n")
end
