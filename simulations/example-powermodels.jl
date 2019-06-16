# Example of running a `matpower` model with `PowerModels.jl`.


# Set working directory.

cd(@__DIR__)


# Set-up packages and paths.

include("lib/powermodels/setup.jl")


# Create and solve the model using PowerModels.

case_data = joinpath(PM_DIR,"test/data/matpower/case5.m")

case_soln = run_dc_opf(case_data, IpoptSolver())
@info "DC Flow"
println(case_soln)
for (k,v) in case_soln["solution"]["bus"]
   println(k, "\t", v)
end

@info "AC Flow"
case_soln = run_ac_opf(case_data, IpoptSolver())
println(case_soln)
for (k,v) in case_soln["solution"]["bus"]
    println(k, "\t", v)
end
for (k,v) in case_soln["solution"]["gen"]
    println(k, "\t", v)
end
