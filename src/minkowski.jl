"""
    Minkowski(order::Real)

Minkowski distance of order p (p≧0)

```math
D(X,Y) = (\\sum_{i=1}^n \\left|X_i - Y_i\\right|^p)^{1/p}
```

See also: [`evaluate`](@ref), [`minkowski`](@ref)
"""
struct Minkowski <: ImagePreMetric # not ImageMetric if order < 1
    order::Real
    Minkowski(order) = order < 0 ? ArgumentError("order $order should be positive") : new(order)
end

"""
    minkowski_p(imgA, imgB, metric::Minkowski)
    minkowski_p(imgA, imgB, order::Real)

minkowski distance to p-th power

See also: [`Minkowski`](@ref), [`minkowski`](@ref)
"""
function minkowski_p(imgA::AbstractArray, imgB::AbstractArray, metric::Minkowski)
    T = promote_type(difftype(eltype(imgA)), difftype(eltype(imgB))) # N0fx -> Float
    imgA = channelview(convert.(T, imgA))
    imgB = channelview(convert.(T, imgB))
    if metric.order == 2
        return reduce(+, abs2.(imgA[:] .- imgB[:]))
    end
    return reduce(+, abs.(imgA[:] .- imgB[:]) .^ metric.order)
end
minkowski_p(imgA::AbstractArray, imgB::AbstractArray, order::Real) = minkowski_p(imgA, imgB, Minkowski(order))

"""
    minkowski(imgA, imgB, metric::Minkowski)
    minkowski(imgA, imgB, order::Real)

minkowski distance of order p

See also: [`Minkowski`](@ref), [`minkowski_p`](@ref)
"""
function minkowski(imgA::AbstractArray, imgB::AbstractArray, metric::Minkowski)
    if metric.order == 2
        return sqrt(minkowski_p(imgA, imgB, metric))
    else
        return minkowski_p(imgA, imgB, metric) .^ (1/metric.order)
    end
end
minkowski(imgA::AbstractArray, imgB::AbstractArray, order::Real) = minkowski(imgA, imgB, Minkowski(order))

evaluate(d::Minkowski, imgA::AbstractArray, imgB::AbstractArray) = minkowski(imgA, imgB, d)