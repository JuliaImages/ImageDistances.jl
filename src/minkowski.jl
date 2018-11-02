"""
    Minkowski(order::Real)

Minkowski distance of order p

```math
D(X,Y) = (\\sum_{i=1}^n \\left|X_i - Y_i\\right|^p)^{1/p}
```

"""
struct Minkowski <: ImageDistances.ImageMetric
    order::Real
end

"""
    minkowski_p(d::Minkowski, imgA, imgB)

minkowski distance to p-th power

See also: [`minkowski`](@ref)
"""
function minkowski_p(d::Minkowski, imgA::AbstractArray, imgB::AbstractArray)::Real
    if d.order == 2
        return reduce(+, abs2.(channelview(imgA)[:] .- channelview(imgB)[:]))
    end
    return reduce(+, abs.(channelview(imgA[:]) .- channelview(imgB[:])) .^ d.order)
end

function evaluate(d::Minkowski, imgA::AbstractArray, imgB::AbstractArray)::Real
    if d.order == 2
        return sqrt(minkowski_p(d, imgA, imgB))
    end
    return minkowski_p(d, imgA, imgB) .^ (1/d.order)
end

"""
    minkowski(imgA, imgB, order::Real)
    minkowski(imgA, imgB, metric::Minkowski)

minkowski distance of order p

See also: [`Minkowski`](@ref)
"""
minkowski(imgA::AbstractArray, imgB::AbstractArray, metric::Minkowski = Minkowski(2)) = evaluate(metric, imgA, imgB)
minkowski(imgA::AbstractArray, imgB::AbstractArray, order::Real = 2) = evaluate(Minkowski(order), imgA, imgB)

"""
    mae(imgA, imgB)

mean absolute error

See also: [`minkowski`](@ref)
"""
mae(imgA::AbstractArray, imgB::AbstractArray) = minkowski_p(imgA, imgB, 1) / length(imgA)

"""
    mse(imgA, imgB)

mean squared error

See also: [`minkowski`](@ref)
""" 
mse(imgA::AbstractArray, imgB::AbstractArray) = minkowski_p(imgA, imgB, 2) / length(imgA)

"""
    psnr(imgA, imgB, [maxvalue=1])

peak signal to noise ratio

```math
    psnr = 10log_{10}\\big(\\frac{MAX_I^2}{MSE}\\big)
```

"""
psnr(imgA::AbstractArray, imgB::AbstractArray, maxvalue = 1) = 10*log10(maxvalue^2 / mse(imgA, imgB))
