
A = [true false false
     false true false
     false false true]
B = copy(A); B[1,2] = true;
sz_img = (3,3)
m, n = 3, 5

type_list = generate_test_types([Bool], [Gray])

@testset "Hausdorff" begin
    @info "test: Hausdorff"

    dist = Hausdorff()
    for T in type_list
        @testset "$T" begin
            test_Metric(dist, sz_img, T)
            test_colwise(dist, n, sz_img, T)
            test_pairwise(dist, m, n, sz_img, T)

            a = A .|> T
            b = B .|> T
            test_numeric(dist, a, b, T; filename="references/Hausdorff")
        end
    end
end

@testset "ModifiedHausdorff" begin
    @info "test: ModifiedHausdorff"

    dist = ModifiedHausdorff()
    for T in type_list
        @testset "$T" begin
            test_SemiMetric(dist, sz_img, T)
            test_colwise(dist, n, sz_img, T)
            test_pairwise(dist, m, n, sz_img, T)

            a = A .|> T
            b = B .|> T
            test_numeric(dist, a, b, T; filename="references/ModifiedHausdorff")
        end
    end
end
