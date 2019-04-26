# TODO: broadcasting
# TODO: RGB distance
function colwise!(r::AbstractVector, dist::PreMetric,
                  a::AbstractVector{<:GrayImageLike},
                  b::AbstractVector{<:GrayImageLike})
    n = length(a)
    n == length(b) || throw(DimensionMismatch("The number of columns in a and b must match."))
    length(r) == n || throw(DimensionMismatch("Incorrect size of r."))
    @inbounds for j = 1:n
        r[j] = evaluate(dist, a[j], b[j])
    end
    r
end

function colwise!(r::AbstractVector, dist::PreMetric,
                  a::AbstractMatrix{<:GrayImageLike},
                  b::AbstractMatrix{<:GrayImageLike})
    (m, n) = get_colwise_dims(r, a, b)
    m == 1 || throw(DimensionMismatch("The number of columns should be 1."))
    @inbounds for j = 1:n
        r[j] = evaluate(dist, a[1,j], b[1,j])
    end
    r
end

function colwise(dist::PreMetric, a::AbstractVector{<:GrayImageLike}, b::AbstractVector{<:GrayImageLike})
    n = length(a)
    r = Vector{result_type(dist, a, b)}(undef, n)
    colwise!(r, dist, a, b)
end

function colwise(dist::PreMetric, a::AbstractMatrix{<:GrayImageLike}, b::AbstractMatrix{<:GrayImageLike})
    n = get_common_ncols(a, b)
    r = Vector{result_type(dist, a, b)}(undef, n)
    colwise!(r, dist, a, b)
end

# function pairwise(d::PreMetric,
#                   imgsA::AbstractVector{IMG},
#                   imgsB::AbstractVector{IMG}) where {IMG<:AbstractArray}
#     m, n = length(imgsA), length(imgsB)
#     D = zeros(m, n)
#     for j=1:n
#       imgB = imgsB[j]
#       for i=1:j-1
#         imgA = imgsA[i]
#         @inbounds D[i,j] = evaluate(d, imgA, imgB)
#       end
#       for i=j+1:m
#         imgA = imgsA[i]
#         @inbounds D[i,j] = evaluate(d, imgA, imgB)
#       end
#     end

#     D
# end

# pairwise(d::PreMetric, imgs::AbstractArray{IMG}) where {IMG<:AbstractArray} =
#     pairwise(d, imgs, imgs)

# # exploit symmetry of semimetric
# function pairwise(d::SemiMetric, imgs::AbstractArray{IMG}) where {IMG<:AbstractArray}
#     n = length(imgs)
#     D = zeros(n, n)
#     for j=1:n
#       imgB = imgs[j]
#       for i=j+1:n
#         imgA = imgs[i]
#         @inbounds D[i,j] = evaluate(d, imgA, imgB)
#       end
#       # nothing to be done to the diagonal (always zero)
#       for i=1:j-1
#         @inbounds D[i,j] = D[j,i] # leverage the symmetry
#       end
#     end

#     D
# end

evaluate(dist::PreMetric, a::GrayImageLike, b::GrayImageLike) = evaluate(dist, rawview(channelview(a)), rawview(channelview(b)))
