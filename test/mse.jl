@testset "MeanSquaredError" begin
    test_types = (Float32, Float64, N0f8, N0f16)
    
    array2gray(T, A) = Gray{T}.(A)
    array2rgb(T, A) = colorview(RGB, repeat(reshape(T.(A),(size(A)...,1)),1,1,3))
    
    @testset "Interface" begin
        function test_interface(imgA, imgB, imgC)
            @test_nowarn mse(imgA, imgB)
            
            @test mse(imgA, imgA) == 0
            @test mse(imgA, imgB) >= 0
            @test mse(imgA, imgB) == mse(imgB, imgA)
            @test mse(imgA, imgB) + mse(imgB, imgC) >= mse(imgA, imgC)
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
            @test mse(T.(A), T.(B)) ≈ 2*T(0.5)*T(0.5)/9 # FIXME: change to T(0.5)*T(0.5)*2/9 will fail the test
            @test mse(array2gray(T, A), array2gray(T, B)) ≈ 2*T(0.5)*T(0.5)/9
            @test mse(array2rgb(T, A), array2rgb(T, B)) ≈ 2*T(0.5)*T(0.5)/9
        end
    end
end

@testset "PSNR" begin
    test_types = (Float32, Float64, N0f8, N0f16)
    
    array2gray(T, A) = Gray{T}.(A)
    array2rgb(T, A) = colorview(RGB, repeat(reshape(T.(A),(size(A)...,1)),1,1,3))
    
    function test_interface(imgA, imgB)
        @test_nowarn psnr(imgA, imgB)

        @test psnr(imgA, imgA) == Inf
        @test mse(imgA, imgB) == mse(imgB, imgA)
    end

    A = Matrix(1.0I,3,3); B = copy(A); B[1,2] = 0.5
    
    for T in test_types
        test_interface(T.(A), T.(B)) # plain array

        imgA = array2gray(T, A); imgB = array2gray(T, B)
        test_interface(imgA, imgB) # Gray array

        imgA = array2rgb(T, A); imgB = array2rgb(T, B)
        test_interface(imgA, imgB) # RGB array
    end
    
    # no numerical test for psnr
end