

# Activate the environment.

using Pkg
Pkg.activate(".")


# Load general packates.

using CSV
using DataFrames
using DataFramesMeta
using DataStructures
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

function simulate_contingency(case, system_base, adjacencies, device_count, radius, device_types, optimizer)
    system = deepcopy(system_base)
    make_interruptible!(system)
    candidates = [
      device.name
      for device_type in device_types
      for device in get_components(device_type, system)
    ] |> sort
    selections = sample_radius(adjacencies, device_count, radius, device_types)
    for (device_type, names) in selections
      make_contingencies!(system, device_type, names)
    end
    selection = reduce(vcat, values(selections))
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
        solved       = solved      ,
        exception    = exception   ,
        device_types = device_types,
        devices      = devices     ,
        loads        = loads       ,
    )
end

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
    "threads"  => 1                ,
    "ratioGap" => 0.5              ,
);


# Read the system data.

power_system = TamuSystem("PowerSystemsTestData/ACTIVSg2000", time_series_in_memory = true);


function adjacencies(sys)
  components = sys.data.components.data
  adj = Dict([(bus, Dict()) for (_, bus) in components[Bus]])
  for (_, line) in components[Line]
    adj[line.arc.from][line] = line.arc.to
    adj[line.arc.to  ][line] = line.arc.from
  end
  for (_, line) in components[Transformer2W]
    adj[line.arc.from][line] = line.arc.to
    adj[line.arc.to  ][line] = line.arc.from
  end
  adj
end

function distances(adj, radius = 0, start = nothing :: Union{String,Nothing})
  if isnothing(start)
    start = sample(collect(keys(adj)))
  end
  dists = Dict(start => 0)
  visited = Set([start])
  pending = Queue{Any}()
  for (_, to) in adj[start]
    enqueue!(pending, (start, to))
  end
  while !isempty(pending)
    (from, to) = dequeue!(pending)
    push!(visited, to)
    dist = min(dists[from] + 1, get(dists, to, radius + 1))
    if dist <= radius
      dists[to] = dist
      for (_, next) in adj[to]
        if !in(next, visited)
          enqueue!(pending, (to, next))
        end
      end
    end
  end
  dists
end

function sample_radius(adj, count = 1, radius = 0, device_types = [Bus])
  dists = distances(adj, radius)
  vertices = Set(keys(dists))
  edges = reduce((a, v) -> union(a, Set(keys(adj[v]))), vertices, init = Set())
  selections = sample(
    collect(
      filter(
        c -> in(typeof(c), device_types),
        union(vertices, edges)
      )
    ),
    count,
    replace = false,
  )
  result = Dict()
  for t in device_types
    result[t] = map(c -> c.name, filter(c -> typeof(c) == t, selections))
  end
  result
end


# Simulate some contingencies.

if !isdefined(Main, :FIRST_CASE)
    FIRST_CASE = 1
end
case = FIRST_CASE
@info string("FIRST_CASE = ", case)

if !isdefined(Main, :OUTPUT_DIR)
    OUTPUT_DIR = "."
end
@info string("OUTPUT_DIR = ", OUTPUT_DIR)

if !isdefined(Main, :DEVICE_TYPES)
  DEVICE_TYPES = [:Line, :Transformer2W]
end
device_types = map(eval, DEVICE_TYPES)
@info string("DEVICE_TYPES = ", device_types)

if !isdefined(Main, :RADIUS)
  RADIUS = 0
end
@info string("RADIUS = ", RADIUS)

sample_size   = SAMPLE_SIZE
@info string("SAMPLE_SIZE = ", sample_size)

adjacency_matrix = adjacencies(power_system);

begin
  result = simulate_contingency(case, power_system, adjacency_matrix, 0, 0, device_types, the_optimizer)
  prefix = string(reduce((s, t) -> string(s, ",", t), device_types), "-", 0, "-", 0)
  CSV.write(joinpath(OUTPUT_DIR, string(prefix, "-devices.tsv")), result.devices, delim = "\t")
  CSV.write(joinpath(OUTPUT_DIR, string(prefix, "-loads.tsv"  )), result.loads, delim = "\t")
end

for radius in 0:RADIUS
  for device_count in 1 : radius + 1
    inputs  = true
    outputs = true
    for i in 1:sample_size
      result = simulate_contingency(
        case,
        power_system,
        adjacency_matrix,
        device_count, 
        radius,
        device_types,
        the_optimizer,
      )
      global case += 1
      prefix = string(
        reduce((s, t) -> string(s, ",", t), device_types),
        "-",
        radius,
        "-",
        device_count,
      )
      CSV.write(joinpath(OUTPUT_DIR, string(prefix, "-devices.tsv")), result.devices, delim = "\t", append = !inputs)
      inputs = false
      if result.solved
          CSV.write(joinpath(OUTPUT_DIR, string(prefix, "-loads.tsv")), result.loads, delim = "\t", append = !outputs)
          outputs = false
      end
    end
  end
end
