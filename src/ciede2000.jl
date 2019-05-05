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

evaluate(d::CIEDE2000, imgA::AbstractArray{<:Number}, imgB::AbstractArray{<:Number}) =
    evaluate(d, Gray.(imgA), Gray.(imgB))
evaluate(d::CIEDE2000, imgA::AbstractArray{<:Number}, imgB::AbstractArray{<:AbstractGray}) =
    evaluate(d, eltype(imgB).(imgA), imgB)
evaluate(d::CIEDE2000, imgA::AbstractArray{<:AbstractGray}, imgB::AbstractArray{<:Number}) =
    evaluate(d, imgA, eltype(imgA).(imgB))

evaluate(dist::CIEDE2000, a::GenericGrayImage{T1}, b::GenericGrayImage{T2}) where  {T1<:PromoteType, T2<:PromoteType} =
    evaluate(dist, intermediatetype(T1).(a), intermediatetype(T2).(b))

function evaluate(dist::CIEDE2000, a::AbstractArray{<:Color3{T1}}, b::AbstractArray{<:Color3{T2}}) where {T1<:FixedPoint, T2<:FixedPoint}
    CT1 = base_colorant_type(eltype(a)){intermediatetype(T1)}
    CT2 = base_colorant_type(eltype(b)){intermediatetype(T2)}
    evaluate(dist, CT1.(a), CT2.(b))
end
