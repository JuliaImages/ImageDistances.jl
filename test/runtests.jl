using Test
using ImageCore
using IterTools
using ReferenceTests
using ImageDistances

# general distances should cover any combination of number_types and color_types unless it's special designed
include("testutils.jl")


include("hausdorff.jl")
include("metrics.jl")
include("ciede2000.jl")

@info "deprecation warnings are expected"
include("deprecated.jl")

nothing
