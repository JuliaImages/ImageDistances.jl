"""
    test_numeric(dist, a, b, T)

simply test that `dist` works for 2d image as expected, more tests go to `Distances.jl`
"""
function test_numeric(dist, a, b, T)
    @testset "numeric" begin
        @testset "$T" begin
            # @test_reference "references/$(typeof(dist))_$(eltype(a))_$(eltype(b)).txt" evaluate(dist, a, b)
            @test_reference "references/$(typeof(dist)).txt" Float64(evaluate(dist, a, b))
        end
    end
end

m = 3
n = 5
sz_img = (3, 3)
w = rand(Float64, sz_img)
type_list = generate_test_types(number_types, [Gray,]) # RGB is not supported yet
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
