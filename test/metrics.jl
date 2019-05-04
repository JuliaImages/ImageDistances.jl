# Test Metrics from Distances.jl
m, n = 3, 5
sz_img = (3, 3)

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
        for T in type_list
            @testset "$T" begin
                test_colwise(dist, n, sz_img, T)
                test_pairwise(dist, m, n, sz_img, T)

                a = [0 0 0; 1 1 1; 0 0 0] .|> T
                b = [1 1 1; 0 0 0; 1 1 1] .|> T
                test_numeric(dist, a, b, T)
                test_numeric(dist, channelview(a), channelview(b), T)
            end
        end

        # RGB image
        type_list = generate_test_types([Float32, N0f8], [RGB])
        for T in type_list
            @testset "$T" begin
                test_colwise(dist, n, sz_img, T)
                test_pairwise(dist, m, n, sz_img, T)

                a = [RGB(0.0, 0.0, 0.0) RGB(0.0, 1.0, 0.0) RGB(0.0, 1.0, 1.0)
                     RGB(0.0, 0.0, 1.0) RGB(1.0, 0.0, 0.0) RGB(1.0, 1.0, 0.0)
                     RGB(1.0, 1.0, 1.0) RGB(1.0, 0.0, 1.0) RGB(0.0, 0.0, 0.0)] .|> T
                b = [RGB(0.0, 0.0, 0.0) RGB(0.0, 0.0, 1.0) RGB(1.0, 1.0, 1.0)
                     RGB(0.0, 1.0, 0.0) RGB(1.0, 0.0, 0.0) RGB(1.0, 0.0, 1.0)
                     RGB(0.0, 1.0, 1.0) RGB(1.0, 1.0, 0.0) RGB(0.0, 0.0, 0.0)] .|> T

                # generally, for Color3 images
                # `evaluate(dist, channelview(a), channelview(b)) != evaluate(dist, a, b)`
                # so we need to use another reference file
                test_numeric(dist, a, b, T)
                test_numeric(dist, channelview(a), channelview(b), T; filename = "references/$(typeof(dist))_channelwise_Color3")
            end
        end
    end
end
