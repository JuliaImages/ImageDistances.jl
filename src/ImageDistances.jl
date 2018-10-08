module ImageDistances

import Base: size, ==

using Distances
import Distances: evaluate, colwise, pairwise

using Colors
using ProgressMeter
using EarthMoversDistance

include("generic.jl")
include("hausdorff.jl")
include("ciede2000.jl")
include("earthmover.jl")

export
    # generic types
    ImagePreMetric,
    ImageSemiMetric,
    ImageMetric,

    # concrete types
    Hausdorff,
    ModifiedHausdorff,
    CIEDE2000,
    EarthMoverBinned,

    # helper functions
    hausdorff,
    modified_hausdorff,
    ciede2000

end # module
