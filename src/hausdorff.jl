"""
    ReductionOperation

A reduction operation on a set of values (e.g. maximum).
"""
abstract type ReductionOperation end

struct MinReduction  <: ReductionOperation end
struct MeanReduction <: ReductionOperation end
struct MaxReduction  <: ReductionOperation end

reduce(op::MinReduction, x)  = minimum(x)
reduce(op::MeanReduction, x) = sum(x) / length(x)
reduce(op::MaxReduction, x)  = maximum(x)

"""
    Hausdorff(inner_op, outer_op)

The generalized Hausdorff distance with inner reduction `inner_op`
and outer reduction `outer_op`.

## References

Dubuisson, M-P; Jain, A. K., 1994. A Modified Hausdorff Distance for
Object-Matching.
"""
struct Hausdorff{I<:ReductionOperation,O<:ReductionOperation} <: ImageMetric
    inner_op::I
    outer_op::O
end

# original definition as it first appeared in the literature
Hausdorff() = Hausdorff(MinReduction(), MaxReduction())

# modified (fast) Hausdorff distance proposed by Dubuisson, M-P et al. 1994
ModifiedHausdorff() = Hausdorff(MeanReduction(), MaxReduction())

# convert binary image to a point set format
function img2pset(img)
    inds = findall(!iszero, img)
    [inds[j][i] for i=1:ndims(img), j=1:length(inds)]
end

function evaluate_pset(d::Hausdorff, psetA, psetB)
    # trivial cases
    psetA == psetB && return 0.
    (isempty(psetA) || isempty(psetA)) && return Inf

    D = Distances.pairwise(Euclidean(), psetA, psetB)

    dAB = reduce(d.inner_op, minimum(D, dims=2))
    dBA = reduce(d.inner_op, minimum(D, dims=1))

    reduce(d.outer_op, (dAB, dBA))
end

evaluate(d::Hausdorff, imgA::AbstractArray, imgB::AbstractArray) =
    evaluate_pset(d, img2pset(imgA), img2pset(imgB))

# helper functions
hausdorff(imgA::AbstractArray, imgB::AbstractArray) = evaluate(Hausdorff(), imgA, imgB)
modified_hausdorff(imgA::AbstractArray, imgB::AbstractArray) = evaluate(ModifiedHausdorff(), imgA, imgB)

function pairwise(d::Hausdorff,
                  imgsA::AbstractVector{IMG},
                  imgsB::AbstractVector{IMG}) where {IMG<:AbstractArray}

    psetsA = [img2pset(imgA) for imgA in imgsA]
    psetsB = [img2pset(imgB) for imgB in imgsB]

    m, n = length(imgsA), length(imgsB)

    nelm = m*n - min(m, n)
    p = Progress(nelm, 1, "Evaluating Hausdorff...")

    D = zeros(m, n)
    for j=1:n
      psetB = psetsB[j]
      for i=1:j-1
        psetA = psetsA[i]
        D[i,j] = evaluate_pset(d, psetA, psetB)
        next!(p)
      end
      for i=j+1:m
        psetA = psetsA[i]
        D[i,j] = evaluate_pset(d, psetA, psetB)
        next!(p)
      end
    end

    D
end

function pairwise(d::Hausdorff, imgs::AbstractVector{IMG}) where {IMG<:AbstractArray}

    psets = [img2pset(img) for img in imgs]

    n = length(imgs)

    nelm = (n*(n-1)) ÷ 2
    p = Progress(nelm, 1, "Evaluating Hausdorff...")

    D = zeros(n, n)
    for j=1:n
      psetB = psets[j]
      for i=j+1:n
        psetA = psets[i]
        D[i,j] = evaluate_pset(d, psetA, psetB)
        next!(p)
      end
      # nothing to be done to the diagonal (always zero)
      for i=1:j-1
        D[i,j] = D[j,i] # leverage the symmetry
      end
    end

    D
end
