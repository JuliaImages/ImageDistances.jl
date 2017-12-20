__precompile__()

module ImageDistances

import Base: size, ==

using Distances
import Distances: evaluate

include("hausdorff.jl")

export
  # distances
  Hausdorff,
  ModifiedHausdorff

end # module
