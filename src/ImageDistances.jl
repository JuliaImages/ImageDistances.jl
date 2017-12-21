__precompile__()

module ImageDistances

import Base: size, ==

using Distances
import Distances: evaluate

include("hausdorff.jl")

export
  # distance types
  Hausdorff,
  ModifiedHausdorff,

  # helper functions
  hausdorff,
  modified_hausdorff

end # module
