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
