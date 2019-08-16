# patches to Distances.jl

const metrics = Distances.metrics

# Before evaluation, unwrap the AbstractGray colorant and promote storage type
#
# (Gray{N0f8}, Gray{N0f8}) -> (Float32, Float32)
# (Gray{N0f8}, N0f8      ) -> (Float32, Float32)
# (N0f8      , Gray{N0f8}) -> (Float32, Float32)
# (N0f8      , N0f8      ) -> (Float32, Float32)
#
# For Color3, only promote storage type; basic operation such as `abs2`
# returns a `Number` for `Color3`(e.g., `RGB`)
#
# (RGB{N0f8}, RGB{N0f8}) -> (RGB{Float32}, RGB{Float32} )
#
# we don't extend `evaluate` here because it makes the dispatching rules too complicated
# we only need to extend `eval_op`, since other operations
# (e.g., `eval_start`, `eval_reduce`, and `eval_end`) will automatically get promoted
for M in metrics
    for (Ta, Tb) in ((AbstractGray, AbstractGray),
                     (AbstractGray, Number),
                     (Number, AbstractGray),
                     (PromoteType, PromoteType))
        @eval function Distances.eval_op(d::$M, a::$Ta, b::$Tb)
            T1 = eltype(floattype(typeof(a)))
            T2 = eltype(floattype(typeof(a)))
            Distances.eval_op(d, T1(a), T2(b))
        end
    end
    @eval function Distances.eval_op(d::$M,
                                     a::Color3{<:PromoteType},
                                     b::Color3{<:PromoteType})
        CT1 = floattype(typeof(a))
        CT2 = floattype(typeof(b))
        Distances.eval_op(d, CT1(a), CT2(b))
    end
end


### ambiguities

# These metrics in Distances.jl define their own result_type
const independentmetrics = (CorrDist, Mahalanobis, SqMahalanobis, SpanNormDist)
const UnionMetrics = Distances.UnionMetrics
const UnionWeightedMetrics = Distances.UnionWeightedMetrics

for (ATa, ATb) in ((AbstractGray, AbstractGray),
                   (AbstractGray, Number),
                   (Number, AbstractGray),
                   (PromoteType, PromoteType),
                   (Color3, Color3))
    @eval function result_type(dist::UnionMetrics, ::Type{Ta}, ::Type{Tb}) where {Ta <: $ATa,Tb <: $ATb}
        T1 = eltype(floattype(Ta))
        T2 = eltype(floattype(Tb))
        result_type(dist, T1, T2)
    end

    @eval function result_type(dist::UnionWeightedMetrics, ::Type{Ta}, ::Type{Tb}) where {Ta <: $ATa,Tb <: $ATb}
        T1 = eltype(floattype(Ta))
        T2 = eltype(floattype(Tb))
        result_type(dist, T1, T2)
    end

    for M in independentmetrics
        @eval function result_type(dist::$M, ::Type{Ta}, ::Type{Tb}) where {Ta <: $ATa,Tb <: $ATb}
            T1 = eltype(floattype(Ta))
            T2 = eltype(floattype(Tb))
            result_type(dist, T1, T2)
        end
    end
end
