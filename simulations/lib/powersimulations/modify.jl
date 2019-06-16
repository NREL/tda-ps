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
function bus_contingencies!(case_sys, buses)
    for i in 1:length(case_sys.generators.thermal)
        generator = case_sys.generators.thermal[i]
        if generator.bus in buses
            case_sys.generators.thermal[i] = @set generator.available = false
        end
    end
    for i in 1:length(case_sys.branches)
        branch = case_sys.branches[i]
        if branch.connectionpoints.from in buses || branch.connectionpoints.to in buses
            case_sys.branches[i] = @set branch.available = false
        end
    end
    Dict{String,Any}(
        map(
            x -> string("b_", x.name) => !(x in buses),
            case_sys.buses
        )
    )
end


"""
Create contingencies at branches.
"""
function branch_contingencies!(case_sys, branches)
    for i in 1:length(case_sys.branches)
        branch = case_sys.branches[i]
        if branch in branches
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
