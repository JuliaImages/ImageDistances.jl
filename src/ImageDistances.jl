__precompile__()

module ImageDistances

import Base: size, ==

using Distances
import Distances: evaluate, colwise, pairwise

include("generic.jl")
include("hausdorff.jl")

export
    # generic types
    ImagePreMetric,
    ImageSemiMetric,
    ImageMetric,

    # concrete types
    Hausdorff,
    ModifiedHausdorff,

    # helper functions
    hausdorff,
    modified_hausdorff

end # module
