# Access to model properties.


"""
Sort the buses by descending degree.
"""
function bus_degrees(case_sys)
    z = Dict()
    for x in case_sys.branches
        z[x.connectionpoints.from] = get(z, x.connectionpoints.from, 0) + (x.available ? 1 : 0)
        z[x.connectionpoints.to  ] = get(z, x.connectionpoints.to  , 0) + (x.available ? 1 : 0)
    end
    sort(
        collect(z),
        lt=((x, y) -> x[2] < y[2]),
        rev=true
    )
end


"""
Extract status of devices.
"""
function available_devices(case_sys)
    Dict{String,Any}(
        vcat(
            map(
                x -> string("g_", x.name) => x.available,
                case_sys.generators.thermal
            ),
            map(
                x -> string("f_", x.name) => x.available,
                case_sys.branches
            )
        )
    )
end


"""
Extract limits of devices.
"""
function device_limits(case_sys)
    Dict{String,Any}(
        vcat(
            map(x -> string("L_", x.name) => x.maxactivepower            , case_sys.loads             ),
            map(x -> string("G_", x.name) => x.tech.activepowerlimits.max, case_sys.generators.thermal),
            map(x -> string("F_", x.name) =>x.rate                       , case_sys.branches          ),
        )
    )
end


"""
Extract the device limits.
"""
function collect_limits(case_sys)
    hcat(
        DataFrame(Sequence=-1, Status="LIMITS"),
        sort_results(
            merge(
                bus_contingencies!(case_sys, []),
                available_devices(case_sys),
                device_limits(case_sys)
            )
        )
    )
end
