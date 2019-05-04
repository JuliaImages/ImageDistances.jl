@testset "CIEDE2000" begin
    @info "test: CIEDE2000"
    dist = CIEDE2000()

    sz_img = (3,3)
    m, n = 3, 5
    type_list = generate_test_types([Bool, Float32, N0f8], [Gray])
    for T in type_list
        @testset "$T" begin
            test_SemiMetric(dist, sz_img, T)
            test_colwise(dist, n, sz_img, T)
            test_pairwise(dist, m, n, sz_img, T)

            a = [0 0 0; 1 1 1; 0 0 0] .|> T
            b = [1 1 1; 0 0 0; 1 1 1] .|> T
            test_numeric(dist, a, b, T; filename="references/CIEDE2000_Color1")
            test_numeric(dist, channelview(a), channelview(b), T; filename="references/CIEDE2000_Color1")
        end
    end

    type_list = generate_test_types([N0f8, Float32], [Lab, RGB])
    for T in type_list
        a = [RGB(0.0, 0.0, 0.0) RGB(0.0, 1.0, 0.0) RGB(0.0, 1.0, 1.0)
            RGB(0.0, 0.0, 1.0) RGB(1.0, 0.0, 0.0) RGB(1.0, 1.0, 0.0)
            RGB(1.0, 1.0, 1.0) RGB(1.0, 0.0, 1.0) RGB(0.0, 0.0, 0.0)] .|> T
        b = [RGB(0.0, 0.0, 0.0) RGB(0.0, 0.0, 1.0) RGB(1.0, 1.0, 1.0)
            RGB(0.0, 1.0, 0.0) RGB(1.0, 0.0, 0.0) RGB(1.0, 0.0, 1.0)
            RGB(0.0, 1.0, 1.0) RGB(1.0, 1.0, 0.0) RGB(0.0, 0.0, 0.0)] .|> T
        test_numeric(dist, a, b, T; filename="references/CIEDE2000_Color3")
        @test_throws ArgumentError evaluate(dist, channelview(a), channelview(b))
    end
end
