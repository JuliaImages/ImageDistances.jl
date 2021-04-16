module ImageDistances

using Distances, LinearAlgebra, Statistics
using Distances:
    get_common_ncols,
    get_colwise_dims,
    get_pairwise_dims
import Distances:
    result_type,
    colwise,
    colwise!,
    pairwise

using ImageCore, ColorVectorSpace
using ImageCore.MappedArrays
using ImageCore: GenericImage, GenericGrayImage, Pixel
using ImageMorphology.FeatureTransform:
    feature_transform,
    distance_transform

# FixedPoint and Bool are promoted to Float before evaluate
const PromoteType = Union{FixedPoint,Bool}

include("generic.jl")
include("metrics_distances.jl")
include("metrics.jl")
include("hausdorff.jl")
include("ciede2000.jl")
include("compat.jl")

for MT in [GenericHausdorff, SumAbsoluteDifference, SumSquaredDifference, NCC, RootMeanSquaredError, MeanAbsoluteError, MeanSquaredError, CIEDE2000]
    @eval Distances.result_type(::$MT, a::Type{T}, ::Type{U}) where {T<:AbstractFloat,U<:AbstractFloat} = promote_type(T, U)
end


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
    AxisWeightedHausdorff,
    CIEDE2000,
    SumAbsoluteDifference,
    SumSquaredDifference,
    MeanAbsoluteError,
    MeanSquaredError,
    RootMeanSquaredError,
    NCC,

    # helper functions
    hausdorff,
    modified_hausdorff,
    ciede2000,
    sad,
    ssd,
    mae,
    sadn,
    mse,
    ssdn,
    rmse,
    ncc

"""
`ImageDistances` is an image-related distance package built based on `Distances`.
"""
ImageDistances
end # module
