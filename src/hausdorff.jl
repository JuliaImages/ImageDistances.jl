"""
    ReductionOperation

A reduction operation on a set of values (e.g. maximum).
"""
abstract type ReductionOperation end

struct MaxReduction  <: ReductionOperation end
struct MeanReduction <: ReductionOperation end

_reduce(op::MaxReduction, x)  = maximum(x)
_reduce(op::MeanReduction, x) = sum(x) / length(x)

"""
    GenericHausdorff(inner_op, outer_op, weights = nothing)

The generalized Hausdorff distance with inner reduction `inner_op`
and outer reduction `outer_op`. Optionally, `weights` can be used for each axis
before distance transformations are applied.

## References

Dubuisson, M-P; Jain, A. K., 1994. *A Modified Hausdorff Distance for Object-Matching*.

See also: [`Hausdorff`](@ref), [`ModifiedHausdorff`](@ref)
"""
struct GenericHausdorff{I<:ReductionOperation, O<:ReductionOperation, W<:Union{Nothing,Tuple}} <: Metric
    inner_op::I
    outer_op::O
    weights::W
end

@doc raw"""
    Hausdorff <: GenericHausdorff
    hausdorff(x::BoolImage, y::BoolImage)

Hausdorff distance between two point sets ``\mathcal{A}`` and ``\mathcal{B}``, which
consist of point positions of 1s of `x` and `y`, respectively. The distance is computed
using the following formula:

```math
    \text{hausdorff}(x,y) = max(d(\mathcal{A}, \mathcal{B}), d(\mathcal{B}, \mathcal{A}))
```
where
```math
    d(\mathcal{A}, \mathcal{B}) = max_{a\in\mathcal{A}}d(a, \mathcal{B}) \\
    d(a, \mathcal{B}) = max_{b\in\mathcal{B}}d(a, b)
```
and the point distance is calcuated using [`Euclidean`](@ref) distance.

## References

Dubuisson, M-P; Jain, A. K., 1994. *A Modified Hausdorff Distance for Object-Matching*.

See also: [`modified_hausdorff`](@ref)
"""
const Hausdorff = GenericHausdorff{MaxReduction, MaxReduction, Nothing}
Hausdorff() = Hausdorff(MaxReduction(), MaxReduction(), nothing)

@doc raw"""
    ModifiedHausdorff <: GenericHausdorff
    modified_hausdorff(x::BoolImage, y::BoolImage)

Modified Hausdorff distance between two point sets ``\mathcal{A}`` and ``\mathcal{B}``,
which consist of point positions of 1s of `x` and `y`, respectively. The distance is
computed using the following formula:

```math
    \text{modified_hausdorff}(x,y) = max(d(\mathcal{A}, \mathcal{B}), d(\mathcal{B}, \mathcal{A}))
```
where
```math
    d(\mathcal{A}, \mathcal{B}) = \frac{1}{N_a}\sum_{a\in\mathcal{A}}d(a, \mathcal{B}) \\
    d(a, \mathcal{B}) = max_{b\in\mathcal{B}}d(a, b)
```
and the point distance is calcuated using [`Euclidean`](@ref) distance.

## References

Dubuisson, M-P; Jain, A. K., 1994. *A Modified Hausdorff Distance for Object-Matching*.

See also: [`hausdorff`](@ref)
"""
const ModifiedHausdorff = GenericHausdorff{MeanReduction, MaxReduction, Nothing}
ModifiedHausdorff() = ModifiedHausdorff(MeanReduction(), MaxReduction(), nothing)

"""
    AxisWeightedHausdorff(weights::Tuple)

Hausdorff distance (see `Hausdorff` for general documentation) where axes are weighted
using specified weights. Distances (expressed as differences between indices in
successive axes) are multiplied by given weights.
"""
AxisWeightedHausdorff(weights::Tuple) = GenericHausdorff(MaxReduction(), MaxReduction(), weights)

# convert binary image to its distance transform
function hausdorff_transform(d::GenericHausdorff, img::AbstractArray{Bool})
    return distance_transform(_feature_transform(img, d.weights), d.weights)
end
function hausdorff_transform(d::GenericHausdorff, img::GenericGrayImage)
  try
      hausdorff_transform(d, of_eltype(Bool, img))
  catch e
      e isa InexactError && throw(ArgumentError("Binary image is needed."))
      rethrow(e)
  end
end

function evaluate_hausdorff(d::GenericHausdorff,
                            imgA::AbstractArray{Bool},
                            imgB::AbstractArray{Bool},
                            dtA::AbstractArray,
                            dtB::AbstractArray)
    # trivial cases
    T = result_type(d, dtA, dtB)
    imgA == imgB && return zero(T)
    (!any(imgA) || !any(imgB)) && return convert(T, Inf)

    # dtA and dtB contain the distance from each pixel
    # to the nearest active pixel in imgA and imgB, respectively.
    # We only care about the distances from imgA to imgB and vice
    # versa, so we'll pull those out by using those images as logical
    # masks into the distance arrays.
    dAB = _reduce(d.inner_op, view(dtB, imgA))
    dBA = _reduce(d.inner_op, view(dtA, imgB))
    _reduce(d.outer_op, (dAB, dBA))
end
function evaluate_hausdorff(d::GenericHausdorff,
                            imgA::GenericGrayImage,
                            imgB::GenericGrayImage,
                            dtA::AbstractArray,
                            dtB::AbstractArray)
    try
        evaluate_hausdorff(d, of_eltype(Bool, imgA), of_eltype(Bool, imgB), dtA, dtB)
    catch e
        e isa InexactError && throw(ArgumentError("Binary image is needed."))
        rethrow(e)
    end
end

(d::GenericHausdorff)(imgA::GenericGrayImage, imgB::GenericGrayImage) =
    evaluate_hausdorff(d, imgA, imgB, hausdorff_transform(d, imgA), hausdorff_transform(d, imgB))

# helper functions
@doc (@doc Hausdorff)
hausdorff(imgA::GenericGrayImage, imgB::GenericGrayImage) =
    Hausdorff()(imgA, imgB)

@doc (@doc ModifiedHausdorff)
modified_hausdorff(imgA::GenericGrayImage, imgB::GenericGrayImage)  =
    ModifiedHausdorff()(imgA, imgB)

# precalculate distance transforms to accelerate computing
function pairwise(d::GenericHausdorff,
                  imgsA::AbstractVector{<:GenericGrayImage},
                  imgsB::AbstractVector{<:GenericGrayImage})
    dtsA = hausdorff_transform.(Ref(d), imgsA)
    dtsB = hausdorff_transform.(Ref(d), imgsB)

    m, n = length(imgsA), length(imgsB)
    D = zeros(m, n)

    for j=1:n
      imgB = imgsB[j]
      dtB = dtsB[j]
      for i=min(m, j+1):m
        imgA = imgsA[i]
        dtA = dtsA[i]
        D[i,j] = evaluate_hausdorff(d, imgA, imgB, dtA, dtB)
      end
      for i=1:min(m, j+1)
        imgA = imgsA[i]
        dtA = dtsA[i]
        D[i,j] = evaluate_hausdorff(d, imgA, imgB, dtA, dtB)
      end
    end

    D
end

function pairwise(d::GenericHausdorff, imgs::AbstractVector{<:GenericGrayImage})
    dts = hausdorff_transform.(Ref(d), imgs)

    n = length(imgs)
    D = zeros(n, n)
    for j=1:n
      imgB = imgs[j]
      dtB = dts[j]
      for i=j+1:n
        imgA = imgs[i]
        dtA = dts[i]
        D[i,j] = evaluate_hausdorff(d, imgA, imgB, dtA, dtB)
      end
      # nothing to be done to the diagonal (always zero)
      for i=1:j-1
        D[i,j] = D[j,i] # leverage the symmetry
      end
    end

    D
end
