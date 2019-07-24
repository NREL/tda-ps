# Modify power simulation models.


"""
Make all of the loads interruptible.
"""
function makeinterruptible!(case_sys, sheddingcost=1999)
    for i in 1:length(case_sys.loads)
        load = case_sys.loads[i]
        case_sys.loads[i] = PSY.InterruptibleLoad(
            load.name,
            load.available,
            load.bus,
            "0", # FIXME: What is this for?
            load.maxactivepower,
            load.maxreactivepower,
            sheddingcost, # FIXME: Is this large enough?
            load.scalingfactor
        )
    end
    Nothing
end


"""
Create contingencies at buses.
"""
function make_contingencies!(case_sys, buses :: Vector{Bus})
    names = map(x -> x.name, buses)
    for i in 1:length(case_sys.generators.thermal)
        generator = case_sys.generators.thermal[i]
        if generator.bus.name in names
            case_sys.generators.thermal[i] = @set generator.available = false
        end
    end
    for i in 1:length(case_sys.branches)
        branch = case_sys.branches[i]
        if branch.connectionpoints.from.name in names || branch.connectionpoints.to.name in names
            case_sys.branches[i] = @set branch.available = false
        end
    end
    Dict{String,Any}(
        map(
            x -> string("b_", x.name) => !(x.name in names),
            case_sys.buses
        )
    )
end


"""
Create contingencies at branches.
"""
function make_contingencies!(case_sys, branches :: Vector{Branch})
    names = map(x -> x.name, branches)
    for i in 1:length(case_sys.branches)
        branch = case_sys.branches[i]
        if branch.name in names
            case_sys.branches[i] = @set branch.available = false
        end
    end
    Dict{String,Any}(
        map(
            x -> string("b_", x.name) => true,
            case_sys.buses
        )
    )
end


"""
Create contingencies at generators.
"""
function make_contingencies!(case_sys, generators :: Vector{Generator})
    names = map(x -> x.name, generators)
    for i in 1:length(case_sys.generators.thermal)
        generator = case_sys.generators.thermal[i]
        if generator.name in names
            case_sys.generators.thermal[i] = @set generator.available = false
        end
    end
    Dict{String,Any}(
        map(
            x -> string("b_", x.name) => true,
            case_sys.buses
        )
    )
end
