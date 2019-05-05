using Test
using ImageCore, Colors
using FixedPointNumbers
using IterTools
using ReferenceTests
using ImageDistances

# general distances should cover any combination of number_types and color_types unless it's special designed
include("testutils.jl")


include("hausdorff.jl")
include("metrics.jl")
include("ciede2000.jl")

nothing
