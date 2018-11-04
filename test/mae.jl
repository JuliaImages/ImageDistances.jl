@testset "MeanAbsoluteError" begin
    test_types = (Float32, Float64, N0f8, N0f16)
    
    array2gray(T, A) = Gray{T}.(A)
    array2rgb(T, A) = colorview(RGB, repeat(reshape(T.(A),(size(A)...,1)),1,1,3))
    
    @testset "Interface" begin
        function test_interface(imgA, imgB, imgC)
            @test_nowarn mae(imgA, imgB)
            
            @test mae(imgA, imgA) == 0
            @test mae(imgA, imgB) >= 0
            @test mae(imgA, imgB) == mae(imgB, imgA)
            @test mae(imgA, imgB) + mae(imgB, imgC) >= mae(imgA, imgC)
        end
        
        A = Matrix(1.0I,3,3); B = copy(A); C = copy(A)
        B[1,2] = 0.5; C[1,3] = 0.5
        
        for T in test_types
            test_interface(T.(A), T.(B), T.(C)) # plain array
            
            imgA = array2gray(T, A); imgB = array2gray(T, B); imgC = array2gray(T, C)
            test_interface(imgA, imgB, imgC) # Gray array
            
            imgA = array2rgb(T, A); imgB = array2rgb(T, B); imgC = array2rgb(T, C)
            test_interface(imgA, imgB, imgC) # RGB array
        end
    end

    @testset "Numeric" begin
        A = Matrix(1.0I,3,3); B = copy(A); B[1,2:3] = [0.5, 0.5]
        for T in test_types
            @test mae(T.(A), T.(B)) ≈ 2*T(0.5)/9
            @test mae(array2gray(T, A), array2gray(T, B)) ≈ 2*T(0.5)/9
            @test mae(array2rgb(T, A), array2rgb(T, B)) ≈ 2*T(0.5)/9
        end
    end
end