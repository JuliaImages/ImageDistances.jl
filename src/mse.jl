struct MeanSquaredError <: ImageMetric end

"""
    mse(imgA, imgB)

mean absolute error

See also: [`minkowski`](@ref)
"""
mse(imgA::AbstractArray, imgB::AbstractArray) = minkowski_p(imgA, imgB, 2) / length(channelview(imgA))

evaluate(d::MeanSquaredError, imgA::AbstractArray, imgB::AbstractArray) = mse(imgA, imgB)