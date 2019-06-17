# Analyze results of study 1.


# Set working directory.

cd(@__DIR__)


# Set-up packages and paths.

include("../../simulations/lib/powersimulations/setup.jl")


# Generate summary table and plots.

for case_data in NESTA_MODELS[[22, 1, 23]]
    @info string("Processing ", case_data, " . . .")

    # Set output folder.
    prefix = joinpath(replace(basename(case_data), r"\..*$" => s""))

    result = DataFrame(Case=Int64[], Sequence=Int64[], Load=Float64[])

    for f in readdir(prefix)
        if !occursin(r"^result-.*\.tsv", f)
            continue
        end

        i = parse(Int64, replace(f, r"^result-(.*)\.tsv" => s"\1"))
        z = CSV.read(joinpath(prefix, f))
        okay_rows = z.Status .== "LOCALLY_SOLVED"
        load_cols = filter(x -> occursin(r"^L_", string(x)), names(z))
        load_matrix = convert(Matrix{Float64}, z[okay_rows, load_cols])
        load_total = sum(load_matrix, dims=2)

        result = vcat(result, DataFrame(Case=i, Sequence=z.Sequence[okay_rows], Load=load_total[:, 1]))

    end

    CSV.write(joinpath(prefix, "summary.tsv"), result, delim="\t")

    if maximum(result.Case) < 100
        plot(
            result,
            x=:Sequence,
            y=:Load,
            color=:Case,
            Geom.line
            Coord.cartesian(xmin=0, xmax=maximum(result.Sequence)),
        ) |> PNG(joinpath(prefix, "summary.png"))
    else
        plot(
            result,
            x=:Sequence,
            y=:Load,
            Geom.boxplot
            Coord.cartesian(xmin=0, xmax=maximum(result.Sequence)),
        ) |> PNG(joinpath(prefix, "summary.png"))
    end

end
