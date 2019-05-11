# Set working directory.

if isdefined(Main, :SIIP_TDAPS_DIR)
    cd(SIIP_TDAPS_DIR)
end


# Set-up packages and paths.

THE_ENV = "powersimulations.env"
include("setup-powersimulations.jl")


# Select the optimizer.

the_optimizer = with_optimizer(Ipopt.Optimizer, print_level = 0)


# Create and solve the model using PowerSimulations.

case_data = joinpath(PM_DIR,"test/data/matpower/case5.m")

case_model = PSY.parse_file(case_data)
case_dict = PSY.pm2ps_dict(case_model)
case_bus, case_gen, case_stor, case_branch, case_load, case_lz, case_shunts, case_service = ps_dict2ps_struct(case_dict)
case_sys = PSY.System(case_bus, case_gen, case_load, case_branch, case_stor, 100.0)

case_ed = PSI.EconomicDispatch(case_sys, PM.DCPlosslessForm; optimizer = the_optimizer)
case_soln = solve_op_model!(case_ed)

@info "DC Flow"
print(case_soln)
