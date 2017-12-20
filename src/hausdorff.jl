"""
    DirectedDistance

A directed distance between a point a ∈ A and
all points b ∈ B is defined in terms of a reduction
operation and an underlying metric (e.g. Euclidean)

## References

Dubuisson, M-P; Jain, A. K., 1994. A Modified Hausdorff Distance for
Object-Matching.
"""
abstract type DirectedDistance end

struct MinDirectedDistance  <: DirectedDistance end
struct MeanDirectedDistance <: DirectedDistance end
struct MaxDirectedDistance  <: DirectedDistance end

reduce_op(d::MinDirectedDistance)  = minimum
reduce_op(d::MeanDirectedDistance) = mean
reduce_op(d::MaxDirectedDistance)  = maximum

evaluate(d::DirectedDistance,
         a::AbstractVector,
         B::AbstractMatrix) = reduce_op(d)(colwise(Euclidean(), a, B))

"""
    Hausdorff(d, f)

The generalized Hausdorff distance with directed distance `d`
and reduction `f`.

## References

Dubuisson, M-P; Jain, A. K., 1994. A Modified Hausdorff Distance for
Object-Matching.
"""
struct Hausdorff{D<:DirectedDistance,F<:Function} <: Metric
    directed_dist::D
    reduction_op::F
end
