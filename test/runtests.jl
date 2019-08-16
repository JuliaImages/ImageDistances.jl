using Test
using ImageCore
using IterTools
using ReferenceTests
using ImageDistances
using Distances

# there're still two ambiguities on colwise! for SqMahalanobis and Mahalanobisat
@test length(detect_ambiguities(Distances, ImageDistances)) == 2

# general distances should cover any combination of number_types and color_types unless it's special designed
include("testutils.jl")


include("hausdorff.jl")
include("metrics.jl")
include("ciede2000.jl")

nothing
