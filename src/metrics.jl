# patches to metrics.jl of Distances.jl

const UnionMetrics = Distances.UnionMetrics

# result_type fallback
# `result_type(dist::UnionMetrics, ::AbstractArray, ::AbstractArray)` is defined in Distances.jl
result_type(dist::UnionMetrics,
            ::AbstractArray{T1},
            ::AbstractArray{T2}) where {T1<:Colorant, T2<:Colorant} =
    typeof(eval_end(dist, eval_op(dist, oneunit(T1), oneunit(T2))))
result_type(dist::UnionMetrics,
            ::AbstractArray{<:AbstractArray{T1}},
            ::AbstractArray{<:AbstractArray{T2}}) where {T1<:Colorant, T2<:Colorant} =
    typeof(eval_end(dist, eval_op(dist, oneunit(T1), oneunit(T2))))
result_type(dist::UnionMetrics,
            ::AbstractArray{<:AbstractArray{T1}},
            ::AbstractArray{<:AbstractArray{T2}}) where {T1<:Number, T2<:Number} =
    typeof(eval_end(dist, eval_op(dist, one(T1), one(T2))))


# convert FixedPoint to AbstractFloat type

# the redundant method on `Array` is used to change the dispatch priority introduced
# by Distances.jl:
# `evaluate(d::UnionMetrics, a::Union{Array, ArraySlice}, b::Union{Array, ArraySlice})`
evaluate(dist::UnionMetrics, a::Array{<:FixedPointLike{T1}}, b::Array{<:FixedPointLike{T2}}) where {T1<:FixedPoint, T2<:FixedPoint} =
    evaluate(dist, floattype(T1).(a), floattype(T2).(b))
evaluate(dist::UnionMetrics, a::AbstractArray{<:FixedPointLike{T1}}, b::AbstractArray{<:FixedPointLike{T2}}) where {T1<:FixedPoint, T2<:FixedPoint} =
    evaluate(dist, floattype(T1).(a), floattype(T2).(b))

result_type(dist::UnionMetrics,
            ::AbstractArray{<:FixedPointLike{T1}},
            ::AbstractArray{<:FixedPointLike{T2}}) where {T1<:FixedPoint, T2<:FixedPoint} =
    typeof(eval_end(dist, eval_op(dist, one(floattype(T1)), one(floattype(T2)))))
result_type(dist::UnionMetrics,
            ::AbstractArray{<:AbstractArray{<:FixedPointLike{T1}}},
            ::AbstractArray{<:AbstractArray{<:FixedPointLike{T2}}}) where {T1<:FixedPoint, T2<:FixedPoint} =
    typeof(eval_end(dist, eval_op(dist, one(floattype(T1)), one(floattype(T2)))))

# convert Bool to Float32 type
evaluate(dist::UnionMetrics, a::Array{<:BoolLike}, b::Array{<:BoolLike}) =
    evaluate(dist, Float32.(a), Float32.(b))
evaluate(dist::UnionMetrics, a::AbstractArray{Bool}, b::AbstractArray{Bool}) =
    evaluate(dist, Float32.(a), Float32.(b))

result_type(dist::UnionMetrics, ::AbstractArray{Bool}, ::AbstractArray{Bool}) = Float32
result_type(dist::UnionMetrics, ::AbstractArray{<:AbstractArray{Bool}}, ::AbstractArray{<:AbstractArray{Bool}}) = Float32


# solve ambiguity introduced by Distances.jl
AmbiguousMetrics = [NormRMSDeviation, RMSDeviation, MeanSqDeviation, MeanAbsDeviation]
for D in AmbiguousMetrics
    @eval evaluate(dist::$D, a::AbstractArray{Bool}, b::AbstractArray{Bool}) =
        evaluate(dist, Float32.(a), Float32.(b))
    @eval evaluate(dist::$D, a::AbstractArray{<:FixedPointLike{T1}}, b::AbstractArray{<:FixedPointLike{T2}}) where {T1<:FixedPoint, T2<:FixedPoint} =
        evaluate(dist, floattype(T1).(a), floattype(T2).(b))
    @eval evaluate(dist::$D, a::AbstractArray{<:Colorant}, b::AbstractArray{<:Colorant}) =
        evaluate(dist, rawview(channelview(a)), rawview(channelview(b)))
end
