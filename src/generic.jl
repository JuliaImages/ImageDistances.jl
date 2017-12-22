# define abstract types to avoid clash with
# distances defined for ordinary arrays

# a premetric is a function d that satisfies:
#
#   d(x, y) >= 0
#   d(x, x) = 0
#
abstract type ImagePreMetric end

# a semimetric is a function d that satisfies:
#
#   d(x, y) >= 0
#   d(x, x) = 0
#   d(x, y) = d(y, x)
#
abstract type ImageSemiMetric <: ImagePreMetric end

# a metric is a semimetric that satisfies triangle inequality:
#
#   d(x, y) + d(y, z) >= d(x, z)
#
abstract type ImageMetric <: ImageSemiMetric end

# --------------------------------------------
# define generic colwise and pairwise in case
# the type doesn't provide specialized version
# --------------------------------------------

function colwise(d::ImagePreMetric,
                 imgsA::AbstractVector{IMG},
                 imgsB::AbstractVector{IMG}) where {IMG<:AbstractArray}
    [evaluate(d, imgA, imgB) for (imgA, imgB) in zip(imgsA, imgsB)]
end

function pairwise(d::ImagePreMetric,
                  imgsA::AbstractVector{IMG},
                  imgsB::AbstractVector{IMG}) where {IMG<:AbstractArray}
    m, n = length(imgsA), length(imgsB)
    D = zeros(m, n)
    for j=1:n
      imgB = imgsB[j]
      for i=1:j-1
        imgA = imgsA[i]
        @inbounds D[i,j] = evaluate(d, imgA, imgB)
      end
      for i=j+1:m
        imgA = imgsA[i]
        @inbounds D[i,j] = evaluate(d, imgA, imgB)
      end
    end

    D
end

pairwise(d::ImagePreMetric, imgs::AbstractArray{IMG}) where {IMG<:AbstractArray} =
    pairwise(d, imgs, imgs)

# exploit symmetry of semimetric
function pairwise(d::ImageSemiMetric, imgs::AbstractArray{IMG}) where {IMG<:AbstractArray}
    n = length(imgs)
    D = zeros(n, n)
    for j=1:n
      imgB = imgs[j]
      for i=j+1:n
        imgA = imgs[i]
        @inbounds D[i,j] = evaluate(d, imgA, imgB)
      end
      # nothing to be done to the diagonal (always zero)
      for i=1:j-1
        @inbounds D[i,j] = D[j,i] # leverage the symmetry
      end
    end

    D
end
