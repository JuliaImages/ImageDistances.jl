module ImageDistances

using Distances

using Colors
using ProgressMeter

include("generic.jl")
include("hausdorff.jl")
include("ciede2000.jl")

export
    # generic types
    ImagePreMetric,
    ImageSemiMetric,
    ImageMetric,

    # generic functions
    evaluate,
    colwise,
    pairwise,

    # concrete types
    Hausdorff,
    ModifiedHausdorff,
    CIEDE2000,

    # helper functions
    hausdorff,
    modified_hausdorff,
    ciede2000

end # module
