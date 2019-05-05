# AbstractGray and Color3 tests should be generated seperately
function generate_test_types(number_types::AbstractArray{<:DataType}, color_types::AbstractArray{<:UnionAll})
    test_types = map(Iterators.product(number_types, color_types)) do T
        try
            T[2]{T[1]}
        catch err
            !isa(err, TypeError) && rethrow(err)
        end
    end
    test_types = filter(x->x != false, test_types)
    if isempty(filter(x->x<:Color3, test_types))
        test_types = [number_types..., test_types...]
    end
    test_types
end

"""
    test_colwise(dist, n, sz, T)

test if `colwise` works as expected in the following two inputs:

* `(n,)Vector` - `(n,)Vector`
* `(1,n)Matrix` - `(1,n)Matrix`

and throw error for ambigious inputs:

* `(m,n)Matrix` - `(m,b)Matrix`  where `m!=1`

"""
function test_colwise(dist, n, sz, T)
    @testset "colwise" begin
        vec_imgsA = [rand(T, sz) for _ in 1:n]
        vec_imgsB = [rand(T, sz) for _ in 1:n]
        mat_imgsA = reshape(vec_imgsA, (1, n))
        mat_imgsB = reshape(vec_imgsB, (1, n))
        mat_imgsA_wrong = reshape(vec_imgsA, (n, 1))
        mat_imgsB_wrong = reshape(vec_imgsB, (n, 1))

        RT = result_type(dist, vec_imgsA, vec_imgsB)
        r1 = zeros(RT, n)
        r2 = zeros(RT, n)
        for j = 1:n
            r1[j] = evaluate(dist, vec_imgsA[j], vec_imgsB[j])
            r2[j] = evaluate(dist, mat_imgsA[1,j], mat_imgsB[1,j])
        end
        @test all(colwise(dist, vec_imgsA, vec_imgsB) .≈ r1)
        @test all(colwise(dist, mat_imgsA, mat_imgsB) .≈ r2)
        @test_throws DimensionMismatch colwise(dist, mat_imgsA_wrong, mat_imgsB_wrong)
    end
end

"""
    test_pairwise(dist, nA, nB, sz, T)

test if `pairwise` works as expected in the following two inputs:

* `(n,)Vector`-`(n,)Vector`
"""
function test_pairwise(dist, nA, nB, sz, T)
    @testset "pairwise" begin
        vec_imgsA = [rand(T, sz) for _ in 1:nA]
        vec_imgsB = [rand(T, sz) for _ in 1:nB]

        RT = result_type(dist, vec_imgsA, vec_imgsB)
        rAB = zeros(RT, nA, nB)
        rAA = zeros(RT, nA, nA)
        for j = 1:nB, i = 1:nA
            rAB[i, j] = evaluate(dist, vec_imgsA[i], vec_imgsB[j])
        end
        for j = 1:nA, i = 1:nA
            rAA[i, j] = evaluate(dist, vec_imgsA[i], vec_imgsA[j])
        end
        @test pairwise(dist, vec_imgsA, vec_imgsB) ≈ rAB
        @test pairwise(dist, vec_imgsA, vec_imgsA) ≈ rAA
        @test pairwise(dist, vec_imgsA) ≈ rAA
    end
end

_base_colorant_type(::Type{<:Number}) = Gray
_base_colorant_type(::Type{T}) where T<:Colorant = base_colorant_type(T)
"""
    test_numeric(dist, a, b, T; filename=nothing)

simply test that `dist` works for 2d image as expected, more tests go to `Distances.jl`
"""
function test_numeric(dist, a, b, T; filename=nothing)
    size(a) == size(b) || error("a and b should be the same size")
    if filename == nothing
        filename = "references/$(typeof(dist))_$(ndims(a))d"

        if eltype(a) <: Color3
            filename = filename * "_$(_base_colorant_type(T))"
        elseif eltype(a) <: Union{Number, AbstractGray}
            filename = filename * "_$(_base_colorant_type(T))"
        end
    end
    @testset "numeric" begin
        @testset "$T" begin
            # @test_reference "$(filename)_$(eltype(a))_$(eltype(b)).txt" evaluate(dist, a, b)
            @test_reference "$(filename).txt" Float64(evaluate(dist, a, b))
        end
    end
end

"""
    test_cross_type(dist, a, b, type_list)

simply test if operations between `N0f8`, `Bool` and `Float32` types works as expected.
`a` and `b` should be simple enough to get rid of InexactError.
"""
function test_cross_type(dist, a, b, type_list)
    size(a) == size(b) || error("a and b should be the same size")
    rsts = [[evaluate(dist, Ta.(a), Tb.(b)),
             evaluate(dist, Tb.(a), Ta.(b))] for (Ta, Tb) in subsets(type_list, 2)]
    rsts = hcat(rsts...)
    @test all(isapprox.(rsts, rsts[1]; rtol=1e-5))
end

function test_Metric(d, sz, T)
    x = rand(T, sz)
    y = rand(T, sz)
    z = rand(T, sz)
    @test evaluate(d, x, y) >= 0
    @test evaluate(d, x, x) ≈ 0
    @test evaluate(d, x, y) ≈ evaluate(d, y, x)
    @test evaluate(d, x, y) + evaluate(d, y, z) >= evaluate(d, x, z)
end

function test_SemiMetric(d, sz, T)
    x = rand(T, sz)
    y = rand(T, sz)
    z = rand(T, sz)
    @test evaluate(d, x, y) >= 0
    @test evaluate(d, x, x) ≈ 0
    @test evaluate(d, x, y) ≈ evaluate(d, y, x)
end
