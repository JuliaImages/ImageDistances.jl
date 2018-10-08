using Colors
using Distances
using ImageDistances
using LinearAlgebra: I, issymmetric
using Test

# define a dummy distance to test generic
# colwise and pairwise (coverage purposes)
import ImageDistances: evaluate
struct MyImgDist <: ImageMetric end
evaluate(d::MyImgDist, imgA, imgB) = π

@testset "ImageDistances.jl" begin
    @testset "Generic" begin
      imgs = [Matrix(1.0I,3,3), ones(3,3), zeros(3,3)]

      ds = colwise(MyImgDist(), imgs, imgs)
      @test all(ds .== π)

      D1 = pairwise(MyImgDist(), imgs, imgs)
      D2 = pairwise(MyImgDist(), imgs)
      @test D1 == D2
      @test issymmetric(D1)
      @test Set(D1) == Set([0.,π])
    end

    @testset "Hausdorff" begin
        A = Matrix(1.0I,3,3); B = copy(A); C = copy(A)
        B[1,2] = 1; C[1,3] = 1
        @test hausdorff(A,A) == 0
        @test hausdorff(A,B) == hausdorff(B,A)
        @test hausdorff(A,B) == hausdorff(A,C) # Hausdorff is less sensitive than Modified Hausdorff
        @test modified_hausdorff(A,A) == 0
        @test modified_hausdorff(A,B) == modified_hausdorff(B,A)
        @test modified_hausdorff(A,B) < modified_hausdorff(A,C)

        A = rand([0,1],10,10)
        B = rand([0,1],10,10)
        C = rand([0,1],10,10)
        @test hausdorff(A,B) ≥ 0
        @test modified_hausdorff(A,B) ≥ 0

        imgs = [A, B, C]
        D1 = pairwise(Hausdorff(), imgs, imgs)
        D2 = pairwise(Hausdorff(), imgs)
        @test D1 == D2
    end

    @testset "CIEDE2000" begin
      A = Gray.(rand(100,100))
      B = Gray.(rand(100,100))

      @test ciede2000(A, B) ≥ 0
      @test ciede2000(A, B) == ciede2000(B, A)
    end

    @testset "Earth Mover" begin
        edges = 0.0:0.2:1.0
        metric = EarthMoverBinned(edges)
        imgA = fill(0.1, 5, 5)
        imgB = fill(0.3, 5, 5)
        @test evaluate(metric, imgA, imgA) == 0
        @test evaluate(metric, imgB, imgB) == 0
        # Since A and B are on opposite sides of the bin boundary, the cost should be 0
        # (i.e., epsilon)
        @test evaluate(metric, imgA, imgB) < 1e-8
        imgB = fill(0.5, 5, 5)
        @test evaluate(metric, imgA, imgB) ≈ step(edges)
        imgB = [fill(0.1, 5) fill(0.3, 5) fill(0.5, 5) fill(0.7, 5) fill(0.9, 5)]
        @test evaluate(metric, imgA, imgB) ≈ (5 + 10 + 15) * step(edges) / 25
        # Images don't have to be the same size
        imgB = [fill(0.1, 10) fill(0.3, 10) fill(0.5, 10) fill(0.7, 10) fill(0.9, 10)]
        @test evaluate(metric, imgA, imgB) ≈ 5 * step(edges) / 25
        imgB = [fill(0.9, 10) fill(0.3, 10) fill(0.7, 10) fill(0.7, 10) fill(0.9, 10)]
        @test evaluate(metric, imgA, imgB) ≈ 15*(2*step(edges))/25
    end
end
