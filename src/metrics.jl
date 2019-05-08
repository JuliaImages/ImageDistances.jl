@doc raw"""
    CityBlock <: Metric
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
evaluate(::SumAbsoluteDifference, a::GenericImage, b::GenericImage) = cityblock(a, b)

@doc (@doc SumAbsoluteDifference)
sad(a::GenericImage, b::GenericImage) = evaluate(SumAbsoluteDifference(), a, b)


# SumSquaredDifference
evaluate(::SumSquaredDifference, a::GenericImage, b::GenericImage) = sqeuclidean(a, b)

@doc (@doc SumSquaredDifference)
ssd(a::GenericImage, b::GenericImage) = evaluate(SumSquaredDifference(), a, b)


# MeanAbsoluteError
evaluate(::MeanAbsoluteError, a::GenericImage, b::GenericImage) = sad(a, b) / length(a)

@doc (@doc MeanAbsoluteError)
mae(a::GenericImage, b::GenericImage) = evaluate(MeanAbsoluteError(), a, b)


# MeanSquaredError
evaluate(::MeanSquaredError, a::GenericImage, b::GenericImage) = ssd(a, b) / length(a)

@doc (@doc MeanSquaredError)
mse(a::GenericImage, b::GenericImage) = evaluate(MeanSquaredError(), a, b)


# RootMeanSquaredError
evaluate(::RootMeanSquaredError, a::GenericImage, b::GenericImage) = sqrt(mse(a, b))

@doc (@doc RootMeanSquaredError)
rmse(a::GenericImage, b::GenericImage) = evaluate(RootMeanSquaredError(), a, b)


# fix ambiguity
for ambigious_dist in [SumAbsoluteDifference,
                       SumSquaredDifference,
                       MeanAbsoluteError,
                       MeanSquaredError,
                       RootMeanSquaredError]
    @eval begin
        evaluate(dist::$(ambigious_dist), a::GenericGrayImage{T1}, b::GenericGrayImage{T2}) where  {T1<:PromoteType, T2<:PromoteType} =
            evaluate(dist, intermediatetype(T1).(a), intermediatetype(T2).(b))

        function evaluate(dist::$(ambigious_dist), a::AbstractArray{<:Color3{T1}}, b::AbstractArray{<:Color3{T2}}) where {T1<:FixedPoint, T2<:FixedPoint}
            CT1 = base_colorant_type(eltype(a)){intermediatetype(T1)}
            CT2 = base_colorant_type(eltype(b)){intermediatetype(T2)}
            evaluate(dist, CT1.(a), CT2.(b))
        end
    end
end
