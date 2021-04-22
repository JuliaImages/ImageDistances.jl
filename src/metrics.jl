@doc raw"""
    Cityblock <: Metric
    SumAbsoluteDifference <: Metric
    cityblock(x, y)
    sad(x, y)

sum of absolute difference(sad), also known as [`Cityblock`](@ref) distance, is calculated by `sum(abs(x - y))`
"""
struct SumAbsoluteDifference <: Metric end

@doc raw"""
    SqEuclidean <: Metric
    SumSquaredDifference <: Metric
    sqeuclidean(x, y)
    ssd(x, y)

sum of squared difference(ssd), also known as [`SqEuclidean`](@ref) distance, is calculated by `sum(abs2(x - y))`
"""
struct SumSquaredDifference <: Metric end

@doc raw"""
    MeanAbsoluteError <: Metric
    mae(x, y)
    sadn(x, y)

mean absolute error(mae) is calculated by [`sad`](@ref)`(x, y)/length(x)`
"""
struct MeanAbsoluteError <: Metric end

@doc raw"""
    MeanSquaredError <: Metric
    mse(x, y)
    ssdn(x, y)

mean squared error(mse) is calculated by [`ssd`](@ref)`(x, y)/length(x)`
"""
struct MeanSquaredError <: Metric end

@doc raw"""
    ZNCC <: PreMetric
    zncc(x, y)

Zero-mean Normalized Cross-correlation(ZNCC) is calculated by `dot(x,y)/(norm(x)*norm(y))`:

```math
\frac{<\bar{x}, \bar{y}>}{||\bar{x}||*||\bar{y}||}
```

where `x`/`y` are zero-meaned, i.e., `x := x - mean(x)`.

!!! info

    ZNCC isn't a `Metric` because `zncc(x, x) == 1.0`. ZNCC might output `NaN` if any of the input
    array is all-zero.

# References

[1] Nakhmani, Arie, and Allen Tannenbaum. "A new distance measure based on generalized image normalized cross-correlation for robust video tracking and image recognition." _Pattern recognition letters_ 34.3 (2013): 315-321.
"""
struct ZNCC <: PreMetric end

@doc raw"""
    RootMeanSquaredError <: Metric
    rmse(x, y)

Root Mean Square Error(rmse) is calculated by `sqrt(mse(x, y))`
"""
struct RootMeanSquaredError <: Metric end

# SumAbsoluteDifference
(::SumAbsoluteDifference)(a::GenericImage, b::GenericImage) =
    Cityblock()(a, b)

@doc (@doc SumAbsoluteDifference)
sad(a::GenericImage, b::GenericImage) = SumAbsoluteDifference()(a, b)


# SumSquaredDifference
(::SumSquaredDifference)(a::GenericImage, b::GenericImage) =
    SqEuclidean()(a, b)

@doc (@doc SumSquaredDifference)
ssd(a::GenericImage, b::GenericImage) = SumSquaredDifference()(a, b)


# MeanAbsoluteError
(::MeanAbsoluteError)(a::GenericImage, b::GenericImage) =
    SumAbsoluteDifference()(a, b) / length(a)

@doc (@doc MeanAbsoluteError)
mae(a::GenericImage, b::GenericImage) = MeanAbsoluteError()(a, b)
@doc (@doc MeanAbsoluteError)
const sadn = mae


# MeanSquaredError
(::MeanSquaredError)(a::GenericImage, b::GenericImage) =
    SumSquaredDifference()(a, b) / length(a)

@doc (@doc MeanSquaredError)
mse(a::GenericImage, b::GenericImage) = MeanSquaredError()(a, b)
@doc (@doc MeanSquaredError)
const ssdn = mse


# RootMeanSquaredError
(::RootMeanSquaredError)(a::GenericImage, b::GenericImage) =
    sqrt(MeanSquaredError()(a, b))

@doc (@doc RootMeanSquaredError)
rmse(a::GenericImage, b::GenericImage) = RootMeanSquaredError()(a, b)

# ZNCC
function (::ZNCC)(a::GenericGrayImage, b::GenericGrayImage)
    A = channelview(of_eltype(floattype(eltype(a)), a))
    B = channelview(of_eltype(floattype(eltype(b)), b))
    return _zncc(A, B)
end

function (::ZNCC)(a::AbstractArray{<:Color3}, b::AbstractArray{<:Color3})
    A = of_eltype(floattype(eltype(a)), a)
    B = of_eltype(floattype(eltype(b)), b)
    return _zncc(A, B)
end

function _zncc(A::GenericImage, B::GenericImage)
    Am = @view (A.-mean(A))[:]
    Bm = @view (B.-mean(B))[:]
    # _norm is a patch for ColorVectorSpace 0.9
    _dot(Am, Bm)/(_norm(Am)*_norm(Bm))
end

_dot(a::AbstractArray{<:Number}, b::AbstractArray{<:Number}) = dot(a, b)
_dot(a::GenericImage, b::GenericImage) = mapreduce(xy->dotc(xy...), +, zip(a, b))

@doc (@doc ZNCC)
zncc(a::GenericImage, b::GenericImage) = ZNCC()(a, b)
