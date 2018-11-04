__precompile__()

module ImageDistances

import Base: size, ==

using Distances
import Distances: evaluate, colwise, pairwise

using Colors
using ProgressMeter

include("generic.jl")
include("hausdorff.jl")
include("ciede2000.jl")
include("minkowski.jl")
include("mae.jl")
include("mse.jl")
include("psnr.jl")

export
    # generic types
    ImagePreMetric,
    ImageSemiMetric,
    ImageMetric,

    # concrete types
    Hausdorff,
    ModifiedHausdorff,
    CIEDE2000,
    Minkowski,
    MeanAbsoluteError,
    MeanSquaredError,

    # helper functions
    hausdorff,
    modified_hausdorff,
    ciede2000,
    minkowski,
    minkowski_p,
    mae,
    mse,
    psnr

end # module
