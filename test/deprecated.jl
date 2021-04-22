@testset "Deprecations" begin

    @testset "NCC (#63)" begin
        type_list = generate_test_types([Bool, Float32, N0f8], [Gray])
        A = [0.0 0.0 0.0; 1.0 1.0 1.0; 0.0 0.0 0.0]
        B = [1.0 1.0 1.0; 0.0 0.0 0.0; 1.0 1.0 1.0]
        for T in type_list
            a, b = T.(A), T.(B)
            @test nearlysame(ncc(a, b), zncc(a, b))
            @test nearlysame(NCC()(a, b), ZNCC()(a, b))
        end

        type_list = generate_test_types([Float32, N0f8], [RGB])
        A = [RGB(0.0, 0.0, 0.0) RGB(0.0, 1.0, 0.0) RGB(0.0, 1.0, 1.0)
            RGB(0.0, 0.0, 1.0) RGB(1.0, 0.0, 0.0) RGB(1.0, 1.0, 0.0)
            RGB(1.0, 1.0, 1.0) RGB(1.0, 0.0, 1.0) RGB(0.0, 0.0, 0.0)]
        B = [RGB(0.0, 0.0, 0.0) RGB(0.0, 0.0, 1.0) RGB(1.0, 1.0, 1.0)
            RGB(0.0, 1.0, 0.0) RGB(1.0, 0.0, 0.0) RGB(1.0, 0.0, 1.0)
            RGB(0.0, 1.0, 1.0) RGB(1.0, 1.0, 0.0) RGB(0.0, 0.0, 0.0)]
        for T in type_list
            a, b = T.(A), T.(B)
            @test nearlysame(ncc(a, b), zncc(a, b))
            @test nearlysame(NCC()(a, b), ZNCC()(a, b))
        end
    end
end
