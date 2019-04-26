function test_colwise(dist, n, sz, T)
    @testset "colwise" begin
        @testset "$T" begin
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
end

n = 5
sz_img = (3, 3)
w = rand(Float64, sz_img)
type_list = generate_test_types(number_types, [Gray,])
dist_list = [SqEuclidean(),
            Euclidean(),
            Cityblock(),
            Minkowski(2.5),
            Hamming(),
            WeightedSqEuclidean(w),
            WeightedEuclidean(w),
            WeightedCityblock(w),
            WeightedMinkowski(w, 2.5),
            WeightedHamming(w),
            MeanAbsDeviation(),
            MeanSqDeviation(),
            RMSDeviation(),
            NormRMSDeviation(),
            Chebyshev(),
            TotalVariation(),
            ]

for dist in dist_list
    @testset "$(typeof(dist))" begin
        for T in type_list
            test_colwise(dist, n, sz_img, T)
        end
    end
end
