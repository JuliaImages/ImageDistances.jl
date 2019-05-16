module ImageQualityIndexes
    using ImageCore
    using ..ImageDistances
    import ..ImageDistances: evaluate

    # copy these alias directly from ImageCore
    # remove them before minor release upgrade
    const NumberLike = Union{Number,AbstractGray}
    const Pixel = Union{Number,Colorant}
    const GenericGrayImage{T<:NumberLike,N} = AbstractArray{T,N}
    const GenericImage{T<:Pixel,N} = AbstractArray{T,N}

    include("generic.jl")
    include("psnr.jl")

    export
        ImageQualityIndex,
        evaluate,

        PeakSignalNoiseRatio,
        PSNR,
        psnr
end
