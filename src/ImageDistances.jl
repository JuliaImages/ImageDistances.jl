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

using FixedPointNumbers
using Colors
using FixedPointNumbers: floattype
using ImageCore, ColorVectorSpace

const PromoteType = Union{AbstractFloat, FixedPoint, Bool} # result_type need promotion
const PixelLike{T<:Number} = Union{T, Colorant{T}}
const FractionalLike{T<:Union{FixedPoint, AbstractFloat}} = Union{T, AbstractGray{T}}
const GrayLike{T<:Union{Bool, FixedPoint, AbstractFloat}} = Union{T, AbstractGray{T}}
const GenericImage{T<:Number, N} = AbstractArray{<:PixelLike{T}, N}
const Gray2dImage{T<:GrayLike} = AbstractArray{<:GrayLike{T}, 2}

# FixedPoint and Bool are converted to Float before evaluate
intermediatetype(::Type{T}) where T<:AbstractFloat = T
intermediatetype(::Type{T}) where T<:FixedPoint = FixedPointNumbers.floattype(T)
intermediatetype(::Type{T}) where T<:Bool = Float64

include("metrics.jl")
include("generic.jl")
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

    # helper functions
    hausdorff,
    modified_hausdorff,
    ciede2000

"""
`ImageDistances` is an image-related distance package built based on `Distances`.
"""
ImageDistances
end # module
