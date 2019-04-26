# patches to metrics.jl of Distances.jl

const UnionMetrics = Distances.UnionMetrics

# FixedPoint and Bool are converted to Float before evaluate
intermediatetype(::Type{T}) where T<:AbstractFloat = T
intermediatetype(::Type{T}) where T<:FixedPoint = FixedPointNumbers.floattype(T)
intermediatetype(::Type{T}) where T<:Bool = Float32

result_type(dist::UnionMetrics,
            ::AbstractArray{<:Union{GenericImage{T1}, PixelLike{T1}}},
            ::AbstractArray{<:Union{GenericImage{T2}, PixelLike{T2}}}) where {T1<:PromoteType, T2<:PromoteType} =
    typeof(eval_end(dist, eval_op(dist, one(intermediatetype(T1)), one(intermediatetype(T2)))))


# the redundant method on `Array` is used to change the dispatch priority introduced
# by Distances.jl:
# `evaluate(d::UnionMetrics, a::Union{Array, ArraySlice}, b::Union{Array, ArraySlice})`
evaluate(dist::UnionMetrics, a::Array{<:PixelLike{T1}}, b::Array{<:PixelLike{T2}}) where {T1<:FixedPoint, T2<:FixedPoint} =
    evaluate(dist, intermediatetype(T1).(a), intermediatetype(T2).(b))
evaluate(dist::UnionMetrics, a::GenericImage{T1}, b::GenericImage{T2}) where  {T1<:FixedPoint, T2<:FixedPoint} =
    evaluate(dist, intermediatetype(T1).(a), intermediatetype(T2).(b))
