# Run the RTS-GMLC base case using `PowerSimulations.jl`.


# Set working directory.

if isdefined(Main, :SIIP_TDAPS_DIR)
    cd(SIIP_TDAPS_DIR)
end


# Set-up packages and paths.

THE_ENV = "powersimulations.env"
include("setup-powersimulations.jl")


# Select the optimizer.

the_optimizer = with_optimizer(Ipopt.Optimizer, print_level = 0)


# Read RTS-GMLC data.

@info string("Reading RTS-GMLC model from ", RTS_GMLC_DIR, " . . .")
rts_dict_backup = PSY.csv2ps_dict(RTS_GMLC_DIR, 100.0)
rts_dict = deepcopy(rts_dict_backup)


# Set number of time slices.

n_times = 6
times = range(1, stop=n_times) .+ 9
@info string("Number of time slices: ", n_times)

timestamps = timestamp(
    rts_dict["forecast"]["DA"]["gen"]["Renewable"]["PV"][
        collect(
            keys(
                rts_dict["forecast"]["DA"]["gen"]["Renewable"]["PV"]
            )
        )[1]
    ]
)[times]

@info string("Earliest time: ", timestamps[1  ])
@info string("Latest time: "  , timestamps[end])

function retaintimestamp(x)
    any(
        map(
            y -> month(y)  == month(x)
              && day(y)    == day(x)
              && hour(y)   == hour(x)
              && minute(y) == minute(x)
              && second(y) == second(x),
            timestamps
        )
    )
end

function filtertimeseries(x)
    function filtertimestamp(x)
        filter(retaintimestamp, x)
    end
    x[filtertimestamp(timestamp(x))]
end

function filterforecasts!(x)
    epsilon = 0.0001 # See https://github.com/NREL/PowerSimulations.jl/issues/135.
    for k in keys(x)
        x[k] = filtertimeseries(x[k]) .+ epsilon
    end
end

function filterload!(x)
    z = x["load"]
    x["load"] = z[retaintimestamp.(z.DateTime), :]
end


# Use day-ahead timeseries for renewables and hydro.

filterforecasts!(rts_dict["forecast"]["DA"]["gen"]["Renewable"]["PV"  ])
filterforecasts!(rts_dict["forecast"]["DA"]["gen"]["Renewable"]["RTPV"])
filterforecasts!(rts_dict["forecast"]["DA"]["gen"]["Renewable"]["WIND"])

filterforecasts!(rts_dict["forecast"]["DA"]["gen"]["Hydro"]            )


# Use day-ahead timeseries for load.

filterload!(rts_dict["forecast"]["DA"])


# Remove DC lines.

delete!(rts_dict, "dcline")


# Select the day-ahead load forecast.

PSY.assign_ts_data(rts_dict, rts_dict["forecast"]["DA"])


# Work around the per-unit error in https://github.com/NREL/PowerSystems.jl/issues/223.

function scalemva!(basemva, series)
    for n in keys(series)
        series[n]["scalingfactor"] = series[n]["scalingfactor"] ./ basemva
    end
end

scalemva!(rts_dict["baseMVA"], rts_dict["gen"]["Renewable"]["PV"  ])
scalemva!(rts_dict["baseMVA"], rts_dict["gen"]["Renewable"]["RTPV"])
scalemva!(rts_dict["baseMVA"], rts_dict["gen"]["Renewable"]["WIND"])
scalemva!(rts_dict["baseMVA"], rts_dict["gen"]["Hydro"]            )


# Create the system model.

rts_sys = PSY.System(rts_dict)


# Create the economic dispatch model.

rts_ed_dc = PSI.EconomicDispatch(deepcopy(rts_sys), PM.DCPlosslessForm; optimizer=the_optimizer, parameters=false)
rts_ed_dc.devices[:ThermalGenerators  ] = PSI.DeviceModel(ThermalGen  , PSI.ThermalDispatchNoMin ) # FIXME: Why not `PSI.ThermalDispatch`?
rts_ed_dc.devices[:RenewableGenerators] = PSI.DeviceModel(RenewableGen, PSI.RenewableFullDispatch)
rts_ed_dc.devices[:Loads              ] = PSI.DeviceModel(PowerLoad   , PSI.StaticPowerLoad      )


# Build and solve the optimization model.

PSI.build_op_model!(rts_ed_dc; optimizer = the_optimizer, parameters=false)
rts_soln_dc = solve_op_model!(rts_ed_dc)

@info "Lossless DC-flow solution:"
println(rts_soln_dc)
