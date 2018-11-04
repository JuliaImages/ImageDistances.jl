@testset "Minkowski" begin
    test_types = (Float32, Float64, N0f8, N0f16)
    
    array2gray(T, A) = Gray{T}.(A)
    array2rgb(T, A) = colorview(RGB, repeat(reshape(T.(A),(size(A)...,1)),1,1,3))
    
    @testset "Interface" begin
        function test_interface(imgA, imgB, imgC, order)
            @test_nowarn minkowski(imgA, imgB, order)
            @test_nowarn minkowski(imgA, imgB, Minkowski(order))
            @test_nowarn minkowski_p(imgA, imgB, order)
            @test_nowarn minkowski_p(imgA, imgB, Minkowski(order))
            @test minkowski(imgA, imgB, order) == minkowski(imgA, imgB, Minkowski(order))
            @test minkowski_p(imgA, imgB, order) == minkowski_p(imgA, imgB, Minkowski(order))
            
            @test_throws MethodError minkowski(imgA, imgB) # deliberately forbid default argument
            @test_throws MethodError minkowski_p(imgA, imgB)
            
            @test minkowski(imgA, imgA, order) == 0
            @test minkowski(imgA, imgB, order) == minkowski(imgB, imgA, order)
            @test minkowski(imgA, imgB, order) >= 0
        end
        
        A = Matrix(1.0I,3,3); B = copy(A); C = copy(A)
        B[1,2] = 0.5; C[1,3] = 0.5
        orders = (0.5, 1, 2, 3.0)
        
        for T in test_types, order in orders
            test_interface(T.(A), T.(B), T.(C), order) # plain array
            
            imgA = array2gray(T, A); imgB = array2gray(T, B); imgC = array2gray(T, C)
            test_interface(imgA, imgB, imgC, order) # Gray array
            
            imgA = array2rgb(T, A); imgB = array2rgb(T, B); imgC = array2rgb(T, C)
            test_interface(imgA, imgB, imgC, order) # RGB array
        end
        
        @test_throws ArgumentError Minkowski(-1)
    end

    @testset "Numeric" begin
        A = Matrix(1.0I,3,3); B = copy(A); B[1,2:3] = [0.5, 0.5]
        for T in test_types
            # order 1
            @test minkowski(T.(A), T.(B), 1) ≈ 2*T(0.5) # N0fx != 0.5
            @test minkowski(array2gray(T, A), array2gray(T, B), 1) ≈ 2*T(0.5)
            @test minkowski(array2rgb(T, A), array2rgb(T, B), 1) ≈ 6*T(0.5)
            # order 2
            @test minkowski(T.(A), T.(B), 2) ≈ sqrt(2)*T(0.5)
            @test minkowski(array2gray(T, A), array2gray(T, B), 2) ≈ sqrt(2)*T(0.5)
            @test minkowski(array2rgb(T, A), array2rgb(T, B), 2) ≈ sqrt(6)*T(0.5)
        end
    end
end