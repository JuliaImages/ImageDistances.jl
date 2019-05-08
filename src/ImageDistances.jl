module ImageDistances

using Distances
using Distances:
    eval_op,
    eval_end,
    get_common_ncols,
    get_colwise_dims,
    get_pairwise_dims
import Distances:
    result_type,
    evaluate,
    colwise,
    colwise!,
    pairwise

# TODO: remove dependency on FixedPointNumbers and Colors
# https://github.com/JuliaImages/Images.jl/issues/802
using FixedPointNumbers
using Colors
using FixedPointNumbers: floattype
using ImageCore, ColorVectorSpace


# These traits are already defined in ImageCore
# copied them here for compatibility consideration
const PixelLike{T<:Number} = Union{T, Colorant{T}}
const NumberLike{T<:Number} = Union{T, AbstractGray{T}}
const RealLike{T<:Real} = NumberLike{T}
const FractionalLike{T<:Union{FixedPoint, AbstractFloat}} = RealLike{T}
const GrayLike{T<:Union{Bool, FixedPoint, AbstractFloat}} = RealLike{T}
const GenericImage{T<:Number, N} = AbstractArray{<:PixelLike{T}, N}
const GenericGrayImage{T<:GrayLike, N} = AbstractArray{<:GrayLike{T}, N}
const Gray2dImage{T<:GrayLike} = GenericGrayImage{T, 2}

# FixedPoint and Bool are promoted to Float before evaluate
const PromoteType = Union{FixedPoint, Bool} # result_type need promotion
intermediatetype(::Type{T}) where T<:Any = T # make type piracy in metrics.jl safe
intermediatetype(::Type{T}) where T<:FixedPoint = FixedPointNumbers.floattype(T)
intermediatetype(::Type{T}) where T<:Bool = Float64

include("generic.jl")
include("metrics_distances.jl")
include("metrics.jl")
include("hausdorff.jl")
include("ciede2000.jl")


# reexport symbols from Distances.jl
# delibrately not use Reexport
# untested metrics from Distances are not exported
export
    # generic types
    PreMetric,
    SemiMetric,
    Metric,

    # generic functions
    result_type,
    evaluate,
    colwise,
    colwise!,
    pairwise,

    # concrete types
    SqEuclidean,
    Euclidean,
    Cityblock,
    Minkowski,
    Hamming,
    TotalVariation,

    # helper functions
    sqeuclidean,
    euclidean,
    cityblock,
    minkowski,
    hamming,
    totalvariation

export
    # concrete types
    GenericHausdorff,
    Hausdorff,
    ModifiedHausdorff,
    CIEDE2000,
    SumAbsoluteDifference,
    SumSquaredDifference,
    MeanAbsoluteError,
    MeanSquaredError,
    RootMeanSquaredError,

    # helper functions
    hausdorff,
    modified_hausdorff,
    ciede2000,
    sad,
    ssd,
    mae,
    mse,
    rmse

"""
`ImageDistances` is an image-related distance package built based on `Distances`.
"""
ImageDistances
end # module
