# patches to metrics.jl of Distances.jl
const UnionMetrics = Distances.UnionMetrics

result_type(dist::UnionMetrics,
            ::AbstractArray{<:Union{GenericImage{T1}, PixelLike{T1}}},
            ::AbstractArray{<:Union{GenericImage{T2}, PixelLike{T2}}}) where {T1<:PromoteType, T2<:PromoteType} =
    typeof(eval_end(dist, eval_op(dist, one(intermediatetype(T1)), one(intermediatetype(T2)))))


evaluate(dist::UnionMetrics, a::AbstractArray{T1}, b::AbstractArray{T2}) where  {T1<:FixedPoint, T2<:FixedPoint} =
    evaluate(dist, intermediatetype(T1).(a), intermediatetype(T2).(b))

evaluate(dist::UnionMetrics, a::AbstractArray{<:AbstractGray{T1}}, b::AbstractArray{<:AbstractGray{T2}}) where  {T1<:FixedPoint, T2<:FixedPoint} =
    evaluate(dist, intermediatetype(T1).(a), intermediatetype(T2).(b))

function evaluate(dist::UnionMetrics, a::AbstractArray{<:Color3{T1}}, b::AbstractArray{<:Color3{T2}}) where {T1<:FixedPoint, T2<:FixedPoint}
    CT1 = base_colorant_type(eltype(a)){intermediatetype(T1)}
    CT2 = base_colorant_type(eltype(b)){intermediatetype(T2)}
    evaluate(dist, CT1.(a), CT2.(b))
end

# the redundant method on `Array` is used to change the dispatch priority introduced
# by Distances.jl:
# `evaluate(d::UnionMetrics, a::Union{Array, ArraySlice}, b::Union{Array, ArraySlice})`
evaluate(dist::UnionMetrics, a::Array{<:FractionalLike{T1}}, b::Array{<:FractionalLike{T2}}) where  {T1<:FixedPoint, T2<:FixedPoint} =
    evaluate(dist, intermediatetype(T1).(a), intermediatetype(T2).(b))

function evaluate(dist::UnionMetrics, a::Array{<:Color3{T1}}, b::Array{<:Color3{T2}}) where {T1<:FixedPoint, T2<:FixedPoint}
    CT1 = base_colorant_type(eltype(a)){intermediatetype(T1)}
    CT2 = base_colorant_type(eltype(b)){intermediatetype(T2)}
    evaluate(dist, CT1.(a), CT2.(b))
end
