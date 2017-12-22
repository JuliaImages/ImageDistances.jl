using Distances # export evaluate, colwise, pairwise
using ImageDistances
using Base.Test

# define a dummy distance to test generic
# colwise and pairwise (coverage purposes)
import ImageDistances: evaluate
struct MyImgDist <: ImageMetric end
evaluate(d::MyImgDist, imgA, imgB) = π

@testset "ImageDistances.jl" begin
    @testset "Generic" begin
      imgs = [eye(3), ones(3,3), zeros(3,3)]

      ds = colwise(MyImgDist(), imgs, imgs)
      @test all(ds .== π)

      D = pairwise(MyImgDist(), imgs)
      @test issymmetric(D)
      @test Set(D) == Set([0.,π])
    end

    @testset "Hausdorff" begin
        A = eye(3); B = copy(A); C = copy(A)
        B[1,2] = 1; C[1,3] = 1
        @test hausdorff(A,A) == 0
        @test hausdorff(A,B) == hausdorff(B,A)
        @test hausdorff(A,B) == hausdorff(A,C) # Hausdorff is less sensitive than Modified Hausdorff
        @test modified_hausdorff(A,A) == 0
        @test modified_hausdorff(A,B) == modified_hausdorff(B,A)
        @test modified_hausdorff(A,B) < modified_hausdorff(A,C)

        A = rand([0,1],10,10)
        B = rand([0,1],10,10)
        @test hausdorff(A,B) ≥ 0
        @test modified_hausdorff(A,B) ≥ 0
    end
end
