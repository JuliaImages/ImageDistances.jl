__precompile__()

module ImageDistances

import Base: size, ==

using Distances
import Distances: evaluate, colwise, pairwise

using Colors

include("generic.jl")
include("hausdorff.jl")
include("ciede2000.jl")

export
    # generic types
    ImagePreMetric,
    ImageSemiMetric,
    ImageMetric,

    # concrete types
    Hausdorff,
    ModifiedHausdorff,
    CIEDE2000,

    # helper functions
    hausdorff,
    modified_hausdorff,
    ciede2000

end # module
