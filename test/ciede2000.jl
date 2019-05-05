@testset "CIEDE2000" begin
    @info "test: CIEDE2000"
    dist = CIEDE2000()

    sz_img = (3,3)
    m, n = 3, 5
    type_list = generate_test_types([Bool, Float32, N0f8], [Gray])
    A = [0 0 0; 1 1 1; 0 0 0]
    B = [1 1 1; 0 0 0; 1 1 1]
    for T in type_list
        @testset "$T" begin
            test_SemiMetric(dist, sz_img, T)
            test_colwise(dist, n, sz_img, T)
            test_pairwise(dist, m, n, sz_img, T)

            a = A .|> T
            b = B .|> T
            # FIXME: the result of Bool type is not strictly equal to others
            eltype(T) <: Bool && continue
            test_numeric(dist, a, b, T; filename="references/CIEDE2000_2d_$(_base_colorant_type(T))")
            test_numeric(dist, channelview(a), channelview(b), T; filename="references/CIEDE2000_2d_$(_base_colorant_type(T))")
        end
    end
    test_cross_type(dist, A, B, type_list)

    type_list = generate_test_types([N0f8, Float32], [Lab, RGB])
    A = [RGB(0.0, 0.0, 0.0) RGB(0.0, 1.0, 0.0) RGB(0.0, 1.0, 1.0)
        RGB(0.0, 0.0, 1.0) RGB(1.0, 0.0, 0.0) RGB(1.0, 1.0, 0.0)
        RGB(1.0, 1.0, 1.0) RGB(1.0, 0.0, 1.0) RGB(0.0, 0.0, 0.0)]
    B = [RGB(0.0, 0.0, 0.0) RGB(0.0, 0.0, 1.0) RGB(1.0, 1.0, 1.0)
        RGB(0.0, 1.0, 0.0) RGB(1.0, 0.0, 0.0) RGB(1.0, 0.0, 1.0)
        RGB(0.0, 1.0, 1.0) RGB(1.0, 1.0, 0.0) RGB(0.0, 0.0, 0.0)]
    for T in type_list
        a = A .|> T
        b = B .|> T
        test_numeric(dist, a, b, T; filename="references/CIEDE2000_2d_Color3")
    end
    test_cross_type(dist, A, B, type_list)
end
