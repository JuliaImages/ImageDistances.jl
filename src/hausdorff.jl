"""
    BoolImage

A type representing a binary image.
"""
const BoolImage = AbstractArray{Bool}

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
    GenericHausdorff(inner_op, outer_op)

The generalized Hausdorff distance with inner reduction `inner_op`
and outer reduction `outer_op`.

## References

Dubuisson, M-P; Jain, A. K., 1994. *A Modified Hausdorff Distance for Object-Matching*.

See also: [`Hausdorff`](@ref), [`ModifiedHausdorff`](@ref)
"""
struct GenericHausdorff{I<:ReductionOperation, O<:ReductionOperation} <: Metric
    inner_op::I
    outer_op::O
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
const Hausdorff = GenericHausdorff{MaxReduction, MaxReduction}
Hausdorff() = Hausdorff(MaxReduction(), MaxReduction())

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
const ModifiedHausdorff = GenericHausdorff{MeanReduction, MaxReduction}
ModifiedHausdorff() = ModifiedHausdorff(MeanReduction(), MaxReduction())

# convert binary image to a point set format
function img2dt(img::BoolImage)
    distance_transform(feature_transform(img))
end
function img2dt(img::GenericGrayImage)
    try
        return img2dt(of_eltype(Bool, img))
    catch e
        e isa InexactError && throw(ArgumentError("Binary image is needed."))
        rethrow(e)
    end
end

function evaluate_dt(   d::GenericHausdorff,
                        imgA::BoolImage,
                        imgB::BoolImage,
                        dtA::AbstractArray,
                        dtB::AbstractArray)
    # trivial cases
    imgA == imgB && return 0.
    (isempty(imgA) || isempty(imgB)) && return Inf

    # dtA and dtB contain the distance from each pixel
    # to the nearest active pixel in imgA and imgB, respectively.
    # We only care about the distances from imgA to imgB and vice
    # versa, so we'll pull those out by using those images as logical
    # masks into the distance arrays.
    dAB = _reduce(d.inner_op, dtB[imgA])
    dBA = _reduce(d.inner_op, dtA[imgB])
    _reduce(d.outer_op, (dAB, dBA))
end
function evaluate_dt(   d::GenericHausdorff,
                        imgA::GenericGrayImage,
                        imgB::GenericGrayImage,
                        dtA::AbstractArray,
                        dtB::AbstractArray)
    try
        return evaluate_dt( d,
                            of_eltype(Bool, imgA),
                            of_eltype(Bool, imgB),
                            dtA,
                            dtB)
    catch e
        e isa InexactError && throw(ArgumentError("Binary image is needed."))
        rethrow(e)
    end
end

(d::GenericHausdorff)(imgA::GenericGrayImage, imgB::GenericGrayImage) =
    evaluate_dt(d, imgA, imgB, img2dt(imgA), img2dt(imgB))

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
    dtsA = [img2dt(imgA) for imgA in imgsA]
    dtsB = [img2dt(imgB) for imgB in imgsB]

    m, n = length(imgsA), length(imgsB)
    D = zeros(m, n)

    for j=1:n
      imgB = imgsB[j]
      dtB = dtsB[j]
      for i=min(m, j+1):m
        imgA = imgsA[i]
        dtA = dtsA[i]
        D[i,j] = evaluate_dt(d, imgA, imgB, dtA, dtB)
      end
      for i=1:min(m, j+1)
        imgA = imgsA[i]
        dtA = dtsA[i]
        D[i,j] = evaluate_dt(d, imgA, imgB, dtA, dtB)
      end
    end

    D
end

function pairwise(d::GenericHausdorff, imgs::AbstractVector{<:GenericGrayImage})
    dts = [img2dt(img) for img in imgs]

    n = length(imgs)
    D = zeros(n, n)
    for j=1:n
      imgB = imgs[j]
      dtB = dts[j]
      for i=j+1:n
        imgA = imgs[i]
        dtA = dts[i]
        D[i,j] = evaluate_dt(d, imgA, imgB, dtA, dtB)
      end
      # nothing to be done to the diagonal (always zero)
      for i=1:j-1
        D[i,j] = D[j,i] # leverage the symmetry
      end
    end

    D
end
