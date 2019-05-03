# Test Metrics from Distances.jl
m, n = 3, 5
sz_img = (3, 3)
type_list = generate_test_types([Bool, Float32, N0f8], [Gray]) # RGB is not supported yet
dist_list = [SqEuclidean(),
            Euclidean(),
            Cityblock(),
            Minkowski(2.5),
            Hamming(),
            TotalVariation(),
            ]

for dist in dist_list
    @testset "$(typeof(dist))" begin
        @info "test: $(typeof(dist))"
        for T in type_list
            @testset "$T" begin
                test_colwise(dist, n, sz_img, T)
                test_pairwise(dist, m, n, sz_img, T)

                a = [0 0 0; 1 1 1; 0 0 0] .|> T
                b = [1 1 1; 0 0 0; 1 1 1] .|> T
                test_numeric(dist, a, b, T)
            end
        end
    end
end
