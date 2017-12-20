__precompile__()

module ImageDistances

using Distances

include("hausdorff.jl")

export
  # distances
  Hausdorff

end # module
