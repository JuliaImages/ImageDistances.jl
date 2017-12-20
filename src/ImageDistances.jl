__precompile__()

module ImageDistances

using Distances
import Distances: evaluate

include("hausdorff.jl")

export
  # distances
  Hausdorff

end # module
