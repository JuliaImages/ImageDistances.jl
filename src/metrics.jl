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

mean absolute error(mae) is calculated by [`sad`](@ref)`(x, y)/length(x)`
"""
struct MeanAbsoluteError <: Metric end

@doc raw"""
    MeanSquaredError <: Metric
    mse(x, y) <: Metric

mean squared error(mse) is calculated by [`ssd`](@ref)`(x, y)/length(x)`
"""
struct MeanSquaredError <: Metric end

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


# MeanSquaredError
(::MeanSquaredError)(a::GenericImage, b::GenericImage) =
    SumSquaredDifference()(a, b) / length(a)

@doc (@doc MeanSquaredError)
mse(a::GenericImage, b::GenericImage) = MeanSquaredError()(a, b)


# RootMeanSquaredError
(::RootMeanSquaredError)(a::GenericImage, b::GenericImage) =
    sqrt(MeanSquaredError()(a, b))

@doc (@doc RootMeanSquaredError)
rmse(a::GenericImage, b::GenericImage) = RootMeanSquaredError()(a, b)
