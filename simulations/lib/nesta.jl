# NESTA models.

"""
Directory for NESTA models.
"""
NESTA_DIR = realpath(
    joinpath(@__DIR__, "../../models/nesta-mirror/opf/")
)


"""
List of NESTA models.
"""
NESTA_MODELS = map(
    x -> joinpath(NESTA_DIR, x),
    filter(
        x -> endswith(x, ".m"),
        readdir(NESTA_DIR)
    )
)


nothing
