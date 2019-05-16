using Test
using ImageCore, Colors
using FixedPointNumbers
using IterTools
using ReferenceTests
using ImageDistances.ImageQualityIndexes

include("../testutils.jl")


@testset "ImageQualityIndexes" begin
    include("psnr.jl")
end
