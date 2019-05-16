@testset "PSNR" begin
    @info "test: PSNR"

    iqi = PSNR()
    sz_img_3 = (3, 3, 3)

    @test PSNR === PeakSignalNoiseRatio

    # Gray image
    type_list = generate_test_types([Bool, Float32, N0f8], [Gray])
    A = [1.0 1.0 1.0; 1.0 1.0 1.0; 0.0 0.0 0.0]
    B = [1.0 1.0 1.0; 0.0 0.0 0.0; 1.0 1.0 1.0]
    for T in type_list
        @testset "$T" begin
            test_ndarray(iqi, sz_img_3, T)

            a = A .|> T
            b = B .|> T

            @test psnr(a, b) == evaluate(PSNR(), a, b)
            @test psnr(a, b) == psnr(a, b, 1.0)
            @test isinf(psnr(A, A))

            # FIXME: the result of Bool type is not strictly equal to others
            eltype(T) <: Bool && continue
            test_numeric(iqi, a, b, T)
            test_numeric(iqi, channelview(a), channelview(b), T)
        end
    end
    test_cross_type(iqi, A, B, type_list)

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
            test_ndarray(iqi, sz_img_3, T)

            a = A .|> T
            b = B .|> T

            @test psnr(a, b) == evaluate(PSNR(), a, b)
            @test psnr(a, b) == psnr(a, b, 1.0)
            @test isinf(psnr(A, A))

            test_numeric(iqi, a, b, T)
            test_numeric(iqi, channelview(a), channelview(b), T; filename="references/PeakSignalNoiseRatio_2d_RGB")
        end
    end
    test_cross_type(iqi, A, B, type_list)

    # general Color3 images that doesn't have peakval inferred
    type_list = generate_test_types([Float32], [Lab, HSV])
    A = [RGB(0.0, 0.0, 0.0) RGB(0.0, 1.0, 0.0) RGB(0.0, 1.0, 1.0)
        RGB(0.0, 0.0, 1.0) RGB(1.0, 0.0, 0.0) RGB(1.0, 1.0, 0.0)
        RGB(1.0, 1.0, 1.0) RGB(1.0, 0.0, 1.0) RGB(0.0, 0.0, 0.0)]
    B = [RGB(0.0, 0.0, 0.0) RGB(0.0, 0.0, 1.0) RGB(1.0, 1.0, 1.0)
        RGB(0.0, 1.0, 0.0) RGB(1.0, 0.0, 0.0) RGB(1.0, 0.0, 1.0)
        RGB(0.0, 1.0, 1.0) RGB(1.0, 1.0, 0.0) RGB(0.0, 0.0, 0.0)]
    for T in type_list
        @testset "$T" begin
            a = A .|> T
            b = B .|> T

            @test_throws ArgumentError psnr(a, b)
            @test_throws ArgumentError psnr(a, b, 1.0)
            @test psnr(a, b, [1.0, 1.0, 1.0]) == evaluate(PSNR(), a, b, [1.0, 1.0, 1.0])
            @test all(isinf.(psnr(A, A, [1.0, 1.0, 1.0])))
        end
    end
end
