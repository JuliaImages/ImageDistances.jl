# patches to metrics.jl of Distances.jl
#
# the main reason for these type piracy codes is: in Distances.jl
# all implementations uses a quite general `AbstractArray` type restriction
# `evaluate(dist, a::AbstractArray, b::AbstractArray)`
#
# Things would become much easier if we can restrict it to
# `evaluate(dist, a::AbstractArray{<:Number}, b::AbstractArray{<:Number}`
#
# See https://github.com/JuliaStats/Distances.jl/pull/128
#
# For this reason, we must override the dispatch priorities to make things work,
# we only overload the definition by inserting `intermediatetype` to promote types,
# so it's quite safe
#
# TODO: reduce memory allocation
#
# Johnny Chen <johnnychen94@hotmail.com>

const UnionMetrics = Distances.UnionMetrics

result_type(dist::UnionMetrics,
            ::AbstractArray{<:Union{GenericImage{T1}, PixelLike{T1}}},
            ::AbstractArray{<:Union{GenericImage{T2}, PixelLike{T2}}}) where {T1<:Number, T2<:Number} =
    typeof(eval_end(dist, eval_op(dist, one(intermediatetype(T1)), one(intermediatetype(T2)))))

evaluate(dist::UnionMetrics, a::AbstractArray{<:NumberLike{T1}}, b::AbstractArray{<:NumberLike{T2}}) where {T1<:PromoteType, T2<:PromoteType} =
    evaluate(dist, intermediatetype(T1).(a), intermediatetype(T2).(b))

function evaluate(dist::UnionMetrics, a::AbstractArray{<:Color3{T1}}, b::AbstractArray{<:Color3{T2}}) where {T1<:FixedPoint, T2<:FixedPoint}
    CT1 = base_colorant_type(eltype(a)){intermediatetype(T1)}
    CT2 = base_colorant_type(eltype(b)){intermediatetype(T2)}
    evaluate(dist, CT1.(a), CT2.(b))
end

# the redundant method on `Array` is used to change the dispatch priority introduced
# by Distances.jl:
# `evaluate(d::UnionMetrics, a::Union{Array, ArraySlice}, b::Union{Array, ArraySlice})`
evaluate(dist::UnionMetrics, a::Array{<:NumberLike{T1}}, b::Array{<:NumberLike{T2}}) where {T1<:PromoteType, T2<:PromoteType} =
    evaluate(dist, intermediatetype(T1).(a), intermediatetype(T2).(b))

function evaluate(dist::UnionMetrics, a::Array{<:Color3{T1}}, b::Array{<:Color3{T2}}) where {T1<:FixedPoint, T2<:FixedPoint}
    CT1 = base_colorant_type(eltype(a)){intermediatetype(T1)}
    CT2 = base_colorant_type(eltype(b)){intermediatetype(T2)}
    evaluate(dist, CT1.(a), CT2.(b))
end
