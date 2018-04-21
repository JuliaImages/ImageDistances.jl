const ColorMetric = Colors.DifferenceMetric

"""
    CIEDE2000(metric)

The pixel-wise CIEDE2000 color-difference formula.

## References

Sharma, G., Wu, W., and Dalal, E. N., 2005.
The CIEDE2000 color‐difference formula.
"""
struct CIEDE2000{M<:ColorMetric} <: ImageSemiMetric
    metric::M
end

CIEDE2000() = CIEDE2000(DE_2000())

function evaluate(d::CIEDE2000, imgA::AbstractArray, imgB::AbstractArray)
    sum(abs, [colordiff(ca, cb, d.metric) for (ca, cb) in zip(imgA, imgB)])
end

# helper function
ciede2000(imgA::AbstractArray, imgB::AbstractArray, metric=DE_2000()) = evaluate(CIEDE2000(metric), imgA, imgB)
