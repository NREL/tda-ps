# Run random permutations of bus contingencies.


# Set working directory.
cd(@__DIR__)


# Set-up packages and paths.

NO_INSTANTIATE = true
include("../../simulations/lib/powersimulations/setup.jl")


# Select the solver amd algorithms.

the_optimizer = with_optimizer(Ipopt.Optimizer, print_level = 0)

the_algorithm = PM.DCPlosslessForm


case_data = NESTA_MODELS[1]

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

branches = sort(case_sys_backup.branches, by = x -> parse(Int16, x.name)) 


for file in filter(x -> endswith(x, "_ED.csv"), readdir())

  @info string("Processing ", file, " . . .")
  name = replace(file, r"_ED\.csv$" => "")
  z = CSV.read(file)

  result = collect_limits(case_sys_backup)

  for row in eachrow(z)

    case_sys = deepcopy(case_sys_backup)

    bs = [i - 1 for i in 2:size(z, 2) if !row[i]]
    @info bs

    result = vcat(
      result,
      run_contingency(
        row.Sequence,
        case_sys,
        branches[bs]
      )
    )
      
  end

  CSV.write(string(name, "_ED-result.tsv"), result, delim="\t")

end
