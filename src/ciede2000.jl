const ColorMetric = Colors.DifferenceMetric

"""
    CIEDE2000 <: SemiMetric
    ciede2000(x, y; metric=DE_2000())

The pixel-wise `CIEDE2000` color-difference between image `a` and `b`.
Optionally, a metric may be supplied, chosen among `DE_2000` (the default), `DE_94`,
`DE_JPC79`, `DE_CMC`, `DE_BFD`, `DE_AB`, `DE_DIN99`, `DE_DIN99d`, `DE_DIN99o`.

## References

Sharma, G., Wu, W., and Dalal, E. N., 2005. *The CIEDE2000 color‐difference formula*.
"""
struct CIEDE2000{M<:ColorMetric} <: SemiMetric
    metric::M
end

CIEDE2000() = CIEDE2000(DE_2000())

function evaluate(d::CIEDE2000, imgA::AbstractArray{<:Colorant}, imgB::AbstractArray{<:Colorant})
    sum(abs, [colordiff(ca, cb, d.metric) for (ca, cb) in zip(imgA, imgB)])
end

# helper function
@doc (@doc CIEDE2000)
ciede2000(imgA::GenericImage, imgB::GenericImage; metric=DE_2000()) = evaluate(CIEDE2000(metric), imgA, imgB)

# accept only 2d array, since the meaning of 3d array isn't clear: is it RGB or Lab?
evaluate(d::CIEDE2000, imgA::AbstractArray{<:Number}, imgB::AbstractArray{<:Number}) =
    throw(ArgumentError("Only AbstractArray{<:Number, 2} with ndims 2 is accepted, instead it's $(typeof(imgA)) with ndims $(ndims(imgA))"))
evaluate(d::CIEDE2000, imgA::AbstractArray{<:Number, 2}, imgB::AbstractArray{<:Number, 2}) =
    evaluate(d, Gray.(imgA), Gray.(imgB))

# Fixedpoint to Float promotion
evaluate(dist::CIEDE2000, a::AbstractArray{<:AbstractGray{T1}}, b::AbstractArray{<:AbstractGray{T2}}) where  {T1<:FixedPoint, T2<:FixedPoint} =
    evaluate(dist, intermediatetype(T1).(a), intermediatetype(T2).(b))
evaluate(dist::CIEDE2000, a::AbstractArray{T1}, b::AbstractArray{T2}) where  {T1<:FixedPoint, T2<:FixedPoint} =
    evaluate(dist, intermediatetype(T1).(a), intermediatetype(T2).(b))

function evaluate(dist::CIEDE2000, a::AbstractArray{<:Color3{T1}}, b::AbstractArray{<:Color3{T2}}) where {T1<:FixedPoint, T2<:FixedPoint}
    CT1 = base_colorant_type(eltype(a)){intermediatetype(T1)}
    CT2 = base_colorant_type(eltype(b)){intermediatetype(T2)}
    evaluate(dist, CT1.(a), CT2.(b))
end
