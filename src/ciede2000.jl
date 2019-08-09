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

# TODO: remove these when https://github.com/JuliaGraphics/Colors.jl/pull/338 is merged and tagged
# expand colordiff to number type
_colordiff(ca,cb; metric) = colordiff(ca, cb, metric)
_colordiff(ca::Number, cb::AbstractGray; metric) = colordiff(Gray(ca), cb, metric)
_colordiff(ca::AbstractGray, cb::Number; metric) = colordiff(ca, Gray(cb), metric)
_colordiff(ca::Number, cb::Number; metric) = colordiff(Gray(ca), Gray(cb), metric)

# colordiff converts image to Lab space, so we don't promote the storage type here
function (d::CIEDE2000)(imgA::GenericImage, imgB::GenericImage)
    sum(abs, _colordiff.(imgA, imgB; metric=d.metric))
end

# helper function
@doc (@doc CIEDE2000)
ciede2000(imgA::GenericImage, imgB::GenericImage; metric=DE_2000()) =
    CIEDE2000(metric)(imgA, imgB)
