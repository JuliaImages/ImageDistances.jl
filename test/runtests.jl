using Test
using ImageCore, Colors
using FixedPointNumbers
using IterTools
using ReferenceTests
using ImageDistances

include("testutils.jl")

include("hausdorff.jl")
include("metrics.jl")
include("ciede2000.jl")

include("ImageQualityIndexes/runtests.jl")

nothing
