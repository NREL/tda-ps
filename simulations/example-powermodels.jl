# Set working directory.

if isdefined(Main, :SIIP_TDAPS_DIR)
    cd(SIIP_TDAPS_DIR)
end


# Set-up packages and paths.

THE_ENV = "powermodels.env"
include("setup-powermodels.jl")


# Select the optimizer.

using JuMP
using Ipopt


# Create and solve the model using PowerModels.

case_data = joinpath(PM_DIR,"test/data/matpower/case5.m")

case_soln = run_dc_opf(case_data, IpoptSolver())
@info "DC Flow"
print(case_soln)
for (k,v) in case_soln["solution"]["bus"]
   println(k, "\t", v)
end

@info "AC Flow"
case_soln = run_ac_opf(case_data, IpoptSolver())
print(case_soln)
for (k,v) in case_soln["solution"]["bus"]
    println(k, "\t", v)
end
for (k,v) in case_soln["solution"]["gen"]
    println(k, "\t", v)
end
