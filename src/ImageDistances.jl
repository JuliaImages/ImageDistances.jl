module ImageDistances

using Reexport
@reexport using Distances
using Distances: get_common_ncols, get_colwise_dims, get_pairwise_dims, result_type
import Distances:
    evaluate,
    colwise,
    colwise!,
    pairwise,
    pairwise!

using Colors
using ImageCore
using ProgressMeter

const NumberLike{T <: Number} = Union{T,Gray{T}}
const GrayImageLike{T <: Number} = AbstractArray{<:NumberLike{T}}

include("generic.jl")
# include("hausdorff.jl")
# include("ciede2000.jl")

# export
#     # concrete types
#     Hausdorff,
#     ModifiedHausdorff,
#     CIEDE2000,

#     # helper functions
#     hausdorff,
#     modified_hausdorff,
#     ciede2000

"""
`ImageDistances` is an superset of `Distances` that focus on providing image-related functions
"""
ImageDistances
end # module
