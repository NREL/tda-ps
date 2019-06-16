# Input/output.


"""
Represent the network as a graph.
"""
function writegraph(filename, case_sys)
    open(filename, "w") do f
        write(f, "digraph {\n")
        write(f, "  overlap=false\n")
        for bus in case_sys.buses
            write(f, "  bus", string(bus.number), " [ label=\"", bus.name, "\" ]\n")
        end
        for branch in case_sys.branches
            write(f, "  bus", string(branch.connectionpoints.from.number), " -> bus", string(branch.connectionpoints.to.number), " [ label=\"", branch.name, "\" ]\n")
        end
        for i in 1:length(case_sys.loads)
            load = case_sys.loads[i]
            write(f, "  load", string(i), " [ shape=box color=maroon label=\"", load.name, "\" ]\n")
            write(f, "  bus", string(load.bus.number), " -> load", string(i), " [ style=dotted color=maroon ]\n")
        end
        if (!isnothing(case_sys.generators.thermal))
            for i in 1:length(case_sys.generators.thermal)
                generator = case_sys.generators.thermal[i]
                write(f, "  thermal", string(i), " [ shape=diamond color=peru label=\"", generator.name, "\" ]\n")
                write(f, "  thermal", string(i), " -> bus", string(generator.bus.number), " [ style=dashed color=peru ]\n")
            end
        end
        if (!isnothing(case_sys.generators.renewable))
            for i in 1:length(case_sys.generators.renewable)
                generator = case_sys.generators.renewable[i]
                write(f, "  renewable", string(i), " [ shape=triangle color=green label=\"", generator.name, "\" ]\n")
                write(f, "  renewable", string(i), " -> bus", string(generator.bus.number), " [ style=dashed color=green ]\n")
            end
        end
        if (!isnothing(case_sys.generators.hydro))
            for i in 1:length(case_sys.generators.hydro)
                generator = case_sys.generators.hydro[i]
                write(f, "  hydro", string(i), " [ shape=invtriangle color=turquoise label=\"", generator.name, "\" ]\n")
                write(f, "  hydro", string(i), " -> bus", string(generator.bus.number), " [ style=dashed color=turquoise ]\n")
            end
        end
        write(f, "}\n")
    end
end


"""
Write the system information.
"""
function writesystem(prefix, case_sys)
    CSV.write(
        joinpath(prefix, "branches.tsv"),
        sort(
            DataFrame(
                Branch  =parse.(Int64, map(x -> x.name                      , case_sys.branches)),
                From_Bus=parse.(Int64, map(x -> x.connectionpoints.from.name, case_sys.branches)),
                To_Bus  =parse.(Int64, map(x -> x.connectionpoints.to.name  , case_sys.branches)),
            )
        ),
        delim="\t"
    )
    CSV.write(
        joinpath(prefix, "loads.tsv"),
        sort(
            DataFrame(
                Load  =parse.(Int64, map(x -> x.name    , case_sys.loads)),
                At_Bus=parse.(Int64, map(x -> x.bus.name, case_sys.loads)),
            )
        ),
        delim="\t"
    )
    CSV.write(
        joinpath(prefix, "generators.tsv"),
        sort(
            DataFrame(
                Generator=parse.(Int64, map(x -> x.name    , case_sys.generators.thermal)),
                At_Bus   =parse.(Int64, map(x -> x.bus.name, case_sys.generators.thermal)),
                Type     ="Thermal",
            )
        ),
        delim="\t"
    )
end
