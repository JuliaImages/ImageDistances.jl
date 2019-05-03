# patches to metrics.jl of Distances.jl
const UnionMetrics = Distances.UnionMetrics

result_type(dist::UnionMetrics,
            ::AbstractArray{<:Union{GenericImage{T1}, PixelLike{T1}}},
            ::AbstractArray{<:Union{GenericImage{T2}, PixelLike{T2}}}) where {T1<:PromoteType, T2<:PromoteType} =
    typeof(eval_end(dist, eval_op(dist, one(intermediatetype(T1)), one(intermediatetype(T2)))))

# the redundant method on `Array` is used to change the dispatch priority introduced
# by Distances.jl:
# `evaluate(d::UnionMetrics, a::Union{Array, ArraySlice}, b::Union{Array, ArraySlice})`
evaluate(dist::UnionMetrics, a::Array{<:FractionalLike{T1}}, b::Array{<:FractionalLike{T2}}) where {T1<:FixedPoint, T2<:FixedPoint} =
    evaluate(dist, intermediatetype(T1).(a), intermediatetype(T2).(b))
evaluate(dist::UnionMetrics, a::Gray2dImage{T1}, b::Gray2dImage{T2}) where  {T1<:FixedPoint, T2<:FixedPoint} =
    evaluate(dist, intermediatetype(T1).(a), intermediatetype(T2).(b))
# RGB is not supported yet
