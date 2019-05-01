"""
    test_colwise(dist, n, sz, T)

test if `colwise` works as expected in the following two inputs:

* (n,)Vector - (n,)Vector
* (1,n)Matrix - (1,n)Matrix

and throw error for ambigious inputs:

* (m,n)Matrix - (m,b)Matrix  ,where `m!=1`

"""
function test_colwise(dist, n, sz, T)
    @testset "colwise" begin
        vec_imgsA = [rand(T, sz) for _ in 1:n]
        vec_imgsB = [rand(T, sz) for _ in 1:n]
        mat_imgsA = reshape(vec_imgsA, (1, n))
        mat_imgsB = reshape(vec_imgsB, (1, n))
        mat_imgsA_wrong = reshape(vec_imgsA, (n, 1))
        mat_imgsB_wrong = reshape(vec_imgsB, (n, 1))

        RT = result_type(dist, vec_imgsA, vec_imgsB)
        r1 = zeros(RT, n)
        r2 = zeros(RT, n)
        for j = 1:n
            r1[j] = evaluate(dist, vec_imgsA[j], vec_imgsB[j])
            r2[j] = evaluate(dist, mat_imgsA[1,j], mat_imgsB[1,j])
        end
        @test all(colwise(dist, vec_imgsA, vec_imgsB) .≈ r1)
        @test all(colwise(dist, mat_imgsA, mat_imgsB) .≈ r2)
        @test_throws DimensionMismatch colwise(dist, mat_imgsA_wrong, mat_imgsB_wrong)
    end
end

"""
    test_numeric(dist, a, b, T)

simply test that `dist` works for 2d image as expected, more tests go to `Distances.jl`
"""
function test_numeric(dist, a, b, T)
    @testset "numeric" begin
        @testset "$T" begin
            # @test_reference "references/$(typeof(dist))_$(eltype(a))_$(eltype(b)).txt" evaluate(dist, a, b)
            @test_reference "references/$(typeof(dist)).txt" Float64(evaluate(dist, a, b))
        end
    end
end

n = 5
sz_img = (3, 3)
w = rand(Float64, sz_img)
type_list = generate_test_types(number_types, [Gray,]) # RGB is not supported yet
dist_list = [SqEuclidean(),
            Euclidean(),
            Cityblock(),
            Minkowski(2.5),
            Hamming(),
            MeanAbsDeviation(),
            MeanSqDeviation(),
            RMSDeviation(),
            NormRMSDeviation(),
            TotalVariation(),
            ]

for dist in dist_list
    @testset "$(typeof(dist))" begin
        @info "test: $(typeof(dist))"
        for T in type_list
            @testset "$T" begin
                test_colwise(dist, n, sz_img, T)
                a = [0 0 0; 1 1 1; 0 0 0] .|> T
                b = [1 1 1; 0 0 0; 1 1 1] .|> T
                test_numeric(dist, a, b, T)
            end
        end
    end
end
