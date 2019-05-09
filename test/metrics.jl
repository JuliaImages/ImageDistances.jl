# Test Metrics from Distances.jl
m, n = 3, 5
sz_img = (3, 3)
sz_img_3 = (3, 3, 3)

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
        # Gray image
        type_list = generate_test_types([Bool, Float32, N0f8], [Gray])
        A = [0.0 0.0 0.0; 1.0 1.0 1.0; 0.0 0.0 0.0]
        B = [1.0 1.0 1.0; 0.0 0.0 0.0; 1.0 1.0 1.0]
        for T in type_list
            @testset "$T" begin
                test_colwise(dist, n, sz_img, T)
                test_pairwise(dist, m, n, sz_img, T)
                test_ndarray(dist, sz_img_3, T)

                a = A .|> T
                b = B .|> T
                test_numeric(dist, a, b, T)
                test_numeric(dist, channelview(a), channelview(b), T)
            end
        end
        test_cross_type(dist, A, B, type_list)

        # RGB image
        type_list = generate_test_types([Float32, N0f8], [RGB])
        A = [RGB(0.0, 0.0, 0.0) RGB(0.0, 1.0, 0.0) RGB(0.0, 1.0, 1.0)
            RGB(0.0, 0.0, 1.0) RGB(1.0, 0.0, 0.0) RGB(1.0, 1.0, 0.0)
            RGB(1.0, 1.0, 1.0) RGB(1.0, 0.0, 1.0) RGB(0.0, 0.0, 0.0)]
        B = [RGB(0.0, 0.0, 0.0) RGB(0.0, 0.0, 1.0) RGB(1.0, 1.0, 1.0)
            RGB(0.0, 1.0, 0.0) RGB(1.0, 0.0, 0.0) RGB(1.0, 0.0, 1.0)
            RGB(0.0, 1.0, 1.0) RGB(1.0, 1.0, 0.0) RGB(0.0, 0.0, 0.0)]
        for T in type_list
            @testset "$T" begin
                test_colwise(dist, n, sz_img, T)
                test_pairwise(dist, m, n, sz_img, T)
                test_ndarray(dist, sz_img_3, T)

                a = A .|> T
                b = B .|> T

                test_numeric(dist, a, b, T)
            end
        end
        test_cross_type(dist, A, B, type_list)
    end
end
