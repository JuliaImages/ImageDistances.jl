module ImageDistances

using Reexport
@reexport using Distances
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
    pairwise,
    pairwise!

using FixedPointNumbers
using FixedPointNumbers: floattype
using ImageCore, ColorVectorSpace

const BoolLike{T<:Bool} = Union{T, Colorant{T}}
const FixedPointLike{T<:FixedPoint} = Union{T, Colorant{T}}


include("metrics.jl")
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
`ImageDistances` is an image-related distance package built based on `Distances`.
"""
ImageDistances
end # module
