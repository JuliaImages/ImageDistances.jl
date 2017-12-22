"""
    PointSet(img)

A minimal interface that treats binary images as point sets.
"""
struct PointSet{A<:AbstractArray}
    img::A
end

==(A::PointSet, B::PointSet) = A.img == B.img
size(A::PointSet) = size(A.img)
points(A::PointSet) = find(A.img)

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

function evaluate(d::Hausdorff, A::PointSet, B::PointSet)
    # trivial case
    A == B && return 0.

    as, bs = points(A), points(B)

    # return if there is no object to match
    (isempty(as) || isempty(bs)) && return Inf

    m, n = length(as), length(bs)

    D = zeros(m, n)
    for j=1:n
        b = [ind2sub(size(B), bs[j])...]
        for i=1:m
            a = [ind2sub(size(A), as[i])...]
            @inbounds D[i,j] = norm(a - b)
        end
    end

    dAB = reduce(d.inner_op, minimum(D, 2))
    dBA = reduce(d.inner_op, minimum(D, 1))

    reduce(d.outer_op, [dAB, dBA])
end

evaluate(d::Hausdorff, imgA::AbstractArray, imgB::AbstractArray) =
    evaluate(d, PointSet(imgA), PointSet(imgB))

# helper functions
hausdorff(imgA::AbstractArray, imgB::AbstractArray) = evaluate(Hausdorff(), imgA, imgB)
modified_hausdorff(imgA::AbstractArray, imgB::AbstractArray) = evaluate(ModifiedHausdorff(), imgA, imgB)
