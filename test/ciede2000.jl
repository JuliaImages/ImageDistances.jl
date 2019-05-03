# test data comes from http://www2.ece.rochester.edu/~gsharma/ciede2000/dataNprograms/ciede2000testdata.txt
A_lab = [50.0       2.6772  -79.7751
        50.0       3.1571  -77.2803
        50.0       2.8361  -74.02
        50.0      -1.3802  -84.2814
        50.0      -1.1848  -84.8006]
B_lab = [50.0       0.0     -82.7485
        50.0       0.0     -82.7485
        50.0       0.0     -82.7485
        50.0       0.0     -82.7485
        50.0       0.0     -82.7485]
A = [(Lab(A_lab[i,:]...)) for i in 1:size(A_lab,1)]
B = [(Lab(B_lab[i,:]...)) for i in 1:size(B_lab,1)]

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
        end
    end

    type_list = generate_test_types([N0f8, Float32], [Lab, RGB])
    for T in type_list
        a = A .|> T
        b = B .|> T
        test_numeric(dist, A, B, Lab; filename="references/CIEDE2000")
    end
end
