"""
    ReductionOperation

A reduction operation on a set of values (e.g. maximum).
"""
abstract type ReductionOperation end

struct MinReduction  <: ReductionOperation end
struct MeanReduction <: ReductionOperation end
struct MaxReduction  <: ReductionOperation end

reduce(op::MinReduction, x)  = minimum(x)
reduce(op::MeanReduction, x) = mean(x)
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

function evaluate(d::Hausdorff,
                  as::AbstractVector, bs::AbstractVector,
                  sizeA::Tuple, sizeB::Tuple)
    # trivial cases
    sizeA ≠ sizeB && return 0.
    as == bs && return 0.

    # return if there is no object to match
    (isempty(as) || isempty(bs)) && return Inf

    m, n = length(as), length(bs)

    D = zeros(m, n)
    for j=1:n
        b = [ind2sub(sizeB, bs[j])...]
        for i=1:m
            a = [ind2sub(sizeA, as[i])...]
            @inbounds D[i,j] = euclidean(a, b)
        end
    end

    dAB = reduce(d.inner_op, minimum(D, 2))
    dBA = reduce(d.inner_op, minimum(D, 1))

    reduce(d.outer_op, (dAB, dBA))
end

evaluate(d::Hausdorff, imgA::AbstractArray, imgB::AbstractArray) =
    evaluate(d, find(imgA), find(imgB), size(imgA), size(imgB))

# helper functions
hausdorff(imgA::AbstractArray, imgB::AbstractArray) = evaluate(Hausdorff(), imgA, imgB)
modified_hausdorff(imgA::AbstractArray, imgB::AbstractArray) = evaluate(ModifiedHausdorff(), imgA, imgB)

function pairwise(d::Hausdorff,
                  imgsA::AbstractVector{IMG},
                  imgsB::AbstractVector{IMG}) where {IMG<:AbstractArray}

    ptsA = [find(imgA) for imgA in imgsA]
    ptsB = [find(imgB) for imgB in imgsB]
    sizesA = [size(imgA) for imgA in imgsA]
    sizesB = [size(imgB) for imgB in imgsB]

    m, n = length(imgsA), length(imgsB)

    D = zeros(m, n)
    for j=1:n
      bs = ptsB[j]
      sizeB = sizesB[j]
      for i=1:j-1
        as = ptsA[i]
        sizeA = sizesA[i]
        D[i,j] = evaluate(d, as, bs, sizeA, sizeB)
      end
      for i=j+1:m
        as = ptsA[i]
        sizeA = sizesA[i]
        D[i,j] = evaluate(d, as, bs, sizeA, sizeB)
      end
    end

    D
end

function pairwise(d::Hausdorff, imgs::AbstractVector{IMG}) where {IMG<:AbstractArray}

    pts = [find(img) for img in imgs]
    sizes = [size(img) for img in imgs]

    n = length(imgs)

    D = zeros(n, n)
    for j=1:n
      bs = pts[j]
      sizeB = sizes[j]
      for i=j+1:n
        as = pts[i]
        sizeA = sizes[i]
        D[i,j] = evaluate(d, as, bs, sizeA, sizeB)
      end
      # nothing to be done to the diagonal (always zero)
      for i=1:j-1
        D[i,j] = D[j,i] # leverage the symmetry
      end
    end

    D
end
