
A = [true false false
     false true false
     false false true]
B = copy(A); B[1,2] = true;
sz_img = (3,3)
sz_img_3 = (3, 3, 3)
m, n = 3, 5

type_list = generate_test_types([Bool], [Gray])

@testset "GenericHausdorff" begin
    @info "test: GenericHausdorff"

    dist = Hausdorff()
    A_zero = zeros(Bool, 3, 3)
    @testset "Hausdorff" begin
        for T in type_list
            @testset "$T" begin
                test_Metric(dist, sz_img, T)
                test_ndarray(dist, sz_img_3, T)
                test_colwise(dist, n, sz_img, T)
                test_pairwise(dist, m, n, sz_img, T)

                a = A .|> T
                b = B .|> T
                test_numeric(dist, a, b, T; filename="references/Hausdorff_2d_Gray")
            end
        end
        @test dist(A_zero, A_zero) == 0.0
        @test dist(A_zero, A) == Inf
        @test dist(A, A_zero) == Inf
    end
    test_cross_type(dist, A, B, type_list)

    dist = ModifiedHausdorff()
    @testset "ModifiedHausdorff" begin
        for T in type_list
            @testset "$T" begin
                test_SemiMetric(dist, sz_img, T)
                test_ndarray(dist, sz_img_3, T)
                test_colwise(dist, n, sz_img, T)
                test_pairwise(dist, m, n, sz_img, T)

                a = A .|> T
                b = B .|> T
                test_numeric(dist, a, b, T; filename="references/ModifiedHausdorff_2d_Gray")
            end
        end
    end
    test_cross_type(dist, A, B, type_list)

    dist_2 = AxisWeightedHausdorff((1.0, 1.5))
    dist_3 = AxisWeightedHausdorff((1.0, 1.5, 2.0))
    @testset "AxisWeightedHausdorff" begin
        Aw = [false false false
            false true false
            false false true]
        Bw = [false true false
            false true false
            false false true]
        Cw = [false false false
            true true false
            false false true]
        @test dist_2(Aw, Bw) == 1.0
        @test dist_2(Aw, Cw) == 1.5
        
        for T in type_list
            @testset "$T" begin
                test_SemiMetric(dist_2, sz_img, T)
                test_ndarray(dist_3, sz_img_3, T)
                test_colwise(dist_2, n, sz_img, T)
                test_pairwise(dist_2, m, n, sz_img, T)
            end
        end
    end
    test_cross_type(dist_2, A, B, type_list)
end
