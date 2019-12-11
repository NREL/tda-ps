# Run random permutations of bus contingencies.


# Set working directory.
cd(@__DIR__)


# Set-up packages and paths.

NO_INSTANTIATE = true
include("../../simulations/lib/powersimulations/setup.jl")


# Select the solver amd algorithms.

the_optimizer = with_optimizer(Ipopt.Optimizer, print_level = 0)

the_algorithm = false ? PSI.CopperPlatePowerModel : PM.DCPlosslessForm

case_data = "Matpower/case_ACTIVSg2000.m"


# Read and create the system model.

case_model = PSY.parse_file(case_data)
case_dict = PSY.pm2ps_dict(case_model)
for (k, l) in case_dict["load"]
    # Set to one time step (noon).
    l["scalingfactor"] = l["scalingfactor"][12]
end
case_bus, case_gen, case_stor, case_branch, case_load, case_lz, case_shunts, case_service = ps_dict2ps_struct(case_dict)
case_sys_backup = PSY.System(case_bus, case_gen, case_load, case_branch, case_stor, 100.0)
makeinterruptible!(case_sys_backup)


# Figure out the number of buses.

bus_numbering = CSV.read("bus-number-name.tsv", delim="\t")

bus_sequence2name = Dict([getfield(r, :row) => r.Name            for r in eachrow(bus_numbering)])
bus_name2sequence = Dict([r.Name            => getfield(r, :row) for r in eachrow(bus_numbering)])

bus_number2name = Dict([r.Number => r.Name   for r in eachrow(bus_numbering)])
bus_name2number = Dict([r.Name   => r.Number for r in eachrow(bus_numbering)])

bus_number2sequence = Dict([r.Number          => getfield(r, :row) for r in eachrow(bus_numbering)])
bus_sequence2number = Dict([getfield(r, :row) => r.Number          for r in eachrow(bus_numbering)])

bus_index2name = Dict([b.number => b.name   for b in case_sys_backup.buses])
bus_name2index = Dict([b.name   => b.number for b in case_sys_backup.buses])

bus_index2sequence = Dict([i                    => bus_name2sequence[n] for (i, n) in bus_index2name])
bus_sequence2index = Dict([bus_name2sequence[n] => i                    for (i, n) in bus_index2name])

buses = sort(case_sys_backup.buses, by = b -> bus_index2sequence[b.number])


# Run contingencies.

for file in filter(x -> endswith(x, ".csv"), sort(vcat(map(d -> map(s -> joinpath("Attacks", d, s), readdir(joinpath("Attacks", d))), readdir("Attacks"))...)))

  @info string("Processing ", file, " . . .")
  name = replace(file, r"\.csv$" => "")
  z = rename!(CSV.read(file), Dict(:Column1 => :Sequence))

  result = collect_limits(case_sys_backup, name2sequence = (x -> bus_name2sequence[x]))

  for row in eachrow(z)

    case_sys = deepcopy(case_sys_backup)

    bs = string(names(row)[2])[1] == 'V' ? [i - 2 for i in 2:size(z, 2) if !row[i]] : Vector{Int64}([bus_number2sequence[parse(Int64, string(names(row)[i])[3:end])] for i in 2:size(z, 2) if !row[i]])
    @info bs

    local row_result;
    try
      row_result = run_contingency(
        row.Sequence,
        case_sys,
        buses[bs],
        name2sequence = (x -> bus_name2sequence[x]),
      )
    catch e
      @error e
      continue
    end

    result = vcat(result, row_result)
      
  end

  CSV.write(string(name, "-result.tsv"), result, delim="\t")

end
