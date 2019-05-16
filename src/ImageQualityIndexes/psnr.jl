"""
    PeakSignalNoiseRatio <: ImageQualityIndex
    psnr(x, ref [, peakval]) -> Union{AbstractFloat, Vector{<:AbstractFloat}}

Peak signal-to-noise ratio (PSNR) is used to measure the quality of image.

PSNR (in dB) is calculated by `10log10(PeakVal^2/mse(x, ref))`, where `PeakVal`
is the maximum possible pixel value of image `ref`, and
[`mse`](@ref ImageDistances.mse) is the mean squared error between images `x`
and `ref`.

For general `Color3` images, PSNR is calculated against each channel of that
color space as `Tuple`. One exception is `AbstractRGB` images, where `mse` is
calculated over three channels.

# References

[1] Wikipedia contributors. (2019, March 14). Peak signal-to-noise ratio. In _Wikipedia, The Free Encyclopedia_. Retrieved 07:18, May 16, 2019, from https://en.wikipedia.org/w/index.php?title=Peak_signal-to-noise_ratio&oldid=887764757
"""
struct PeakSignalNoiseRatio <: ImageQualityIndex end
const PSNR = PeakSignalNoiseRatio # alias PSNR since it's too famous

# api
(iqi::PSNR)(x, ref, peakval) = _psnr(x, ref, peakval)
(iqi::PSNR)(x, ref) = iqi(x, ref, peak_value(eltype(ref)))

@doc (@doc PeakSignalNoiseRatio)
psnr(x, ref, peakval) = _psnr(x, ref, peakval)
psnr(x, ref) = psnr(x, ref, peak_value(eltype(ref)))


# implementation
peak_value(::Type{T}) where T <: NumberLike = one(eltype(T))
peak_value(::Type{T}) where T <: AbstractRGB = one(eltype(T))
function peak_value(::Type{T}) where T <: Color3
    err_msg = "peakval for PSNR can't be inferred and should be explicitly passed for $(T) images"
    throw(ArgumentError(err_msg))
end

_psnr(x::GenericGrayImage,
      ref::GenericGrayImage,
      peakval::Real) =
    20log10(peakval) - 10log10(mse(x, ref))

_psnr(x::GenericImage{<:AbstractRGB},
      ref::GenericImage{<:AbstractRGB},
      peakval::Real) =
    _psnr(channelview(x), channelview(ref), peakval)

function _psnr(x::GenericImage{<:Color3},
               ref::GenericImage{CT},
               peakvals) where {CT<:Color3}
    check_peakvals(CT, peakvals)

    cx = channelview(x)
    cref = channelview(ref)
    n = length(CT)
    [_psnr(view(cx, i,:,:), view(cref, i,:,:), peakvals[i]) for i in 1:n]
end

function check_peakvals(CT, peakvals)
    if length(peakvals) ≠ length(CT)
        err_msg = "peakvals for PSNR should be length-$(length(CT)) vector for $(base_colorant_type(CT)) images"
        throw(ArgumentError(err_msg))
    end
end
