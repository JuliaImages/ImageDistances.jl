using Colors
using ImageDistances
using LinearAlgebra: I, issymmetric
using Test

# define a dummy distance to test generic
# colwise and pairwise (coverage purposes)
struct MyImgDist <: ImageMetric end
ImageDistances.evaluate(d::MyImgDist, imgA, imgB) = π

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
end
