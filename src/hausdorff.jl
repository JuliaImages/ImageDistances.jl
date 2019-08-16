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
function img2pset(img::AbstractArray{T}) where T<:Union{Gray{Bool}, Bool}
    inds = findall(x->x==true, img)
    [inds[j][i] for i=1:ndims(img), j=1:length(inds)]
end
function img2pset(img::GenericGrayImage)
    try
        return img2pset(of_eltype(Bool, img))
    catch e
        e isa InexactError && throw(ArgumentError("Binary image is needed."))
        rethrow(e)
    end
end

function evaluate_pset(d::GenericHausdorff, psetA, psetB)
    # trivial cases
    psetA == psetB && return 0.
    (isempty(psetA) || isempty(psetA)) && return Inf

    D = pairwise(Euclidean(), psetA, psetB, dims=2)

    dAB = _reduce(d.inner_op, minimum(D, dims=2))
    dBA = _reduce(d.inner_op, minimum(D, dims=1))

    _reduce(d.outer_op, (dAB, dBA))
end

(d::GenericHausdorff)(imgA::GenericGrayImage, imgB::GenericGrayImage) =
    evaluate_pset(d, img2pset(imgA), img2pset(imgB))

# helper functions
@doc (@doc Hausdorff)
hausdorff(imgA::GenericGrayImage, imgB::GenericGrayImage) =
    Hausdorff()(imgA, imgB)

@doc (@doc ModifiedHausdorff)
modified_hausdorff(imgA::GenericGrayImage, imgB::GenericGrayImage)  =
    ModifiedHausdorff()(imgA, imgB)

# precalculate psets to accelerate computing
function pairwise(d::GenericHausdorff,
                  imgsA::AbstractVector{<:GenericGrayImage},
                  imgsB::AbstractVector{<:GenericGrayImage})
    psetsA = [img2pset(imgA) for imgA in imgsA]
    psetsB = [img2pset(imgB) for imgB in imgsB]

    m, n = length(imgsA), length(imgsB)
    D = zeros(m, n)

    for j=1:n
      psetB = psetsB[j]
      for i=min(m, j+1):m
        psetA = psetsA[i]
        D[i,j] = evaluate_pset(d, psetA, psetB)
      end
      for i=1:min(m, j+1)
        psetA = psetsA[i]
        D[i,j] = evaluate_pset(d, psetA, psetB)
      end
    end

    D
end

function pairwise(d::GenericHausdorff, imgs::AbstractVector{<:GenericGrayImage})
    psets = [img2pset(img) for img in imgs]

    n = length(imgs)
    D = zeros(n, n)
    for j=1:n
      psetB = psets[j]
      for i=j+1:n
        psetA = psets[i]
        D[i,j] = evaluate_pset(d, psetA, psetB)
      end
      # nothing to be done to the diagonal (always zero)
      for i=1:j-1
        D[i,j] = D[j,i] # leverage the symmetry
      end
    end

    D
end
