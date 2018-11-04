struct MeanAbsoluteError <: ImageMetric end

"""
    mae(imgA, imgB)

mean absolute error

See also: [`minkowski`](@ref)
"""
mae(imgA::AbstractArray, imgB::AbstractArray) = minkowski_p(imgA, imgB, 1) / length(channelview(imgA))

evaluate(d::MeanAbsoluteError, imgA::AbstractArray, imgB::AbstractArray) = mae(imgA, imgB)