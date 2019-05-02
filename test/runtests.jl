using Test
using ImageCore, Colors
using FixedPointNumbers
using ReferenceTests
using ImageDistances

# general distances should cover any combination of number_types and color_types unless it's special designed
const number_types = [Bool, N0f8, Float32]
const color_types = [Gray, RGB]
include("testutils.jl")


include("hausdorff.jl")
include("metrics.jl")


# @testset "CIEDE2000" begin
#     A = Gray.(rand(100,100))
#     B = Gray.(rand(100,100))

#     @test ciede2000(A, B) ≥ 0
#     @test ciede2000(A, B) == ciede2000(B, A)
# end
