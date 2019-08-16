# TODO: broadcasting
function colwise!(r::AbstractVector, dist::PreMetric,
                  a::AbstractVector{<:GenericImage},
                  b::AbstractVector{<:GenericImage})
    n = length(a)
    n == length(b) || throw(DimensionMismatch("The number of columns in a and b must match."))
    length(r) == n || throw(DimensionMismatch("Incorrect size of r."))
    @inbounds for j = 1:n
        r[j] = dist(a[j], b[j]) # TODO: use view
    end
    r
end

function colwise!(r::AbstractVector, dist::PreMetric,
                  a::AbstractMatrix{<:GenericImage},
                  b::AbstractMatrix{<:GenericImage})
    (m, n) = get_colwise_dims(r, a, b)
    m == 1 || throw(DimensionMismatch("The number of columns should be 1."))
    @inbounds for j = 1:n
        r[j] = dist(a[1,j], b[1,j]) # TODO: use view
    end
    r
end

function colwise(dist::PreMetric,
                 a::AbstractVector{<:GenericImage},
                 b::AbstractVector{<:GenericImage})
    n = length(a)
    r = Vector{result_type(dist, a, b)}(undef, n)
    colwise!(r, dist, a, b)
end

function colwise(dist::PreMetric,
                 a::AbstractMatrix{<:GenericImage},
                 b::AbstractMatrix{<:GenericImage})
    n = get_common_ncols(a, b)
    r = Vector{result_type(dist, a, b)}(undef, n)
    colwise!(r, dist, a, b)
end

# Generic pairwise evaluation
# TODO: Matrix support
# TODO: add `pairwise!` and `_pairwise!` to accelerate using codes from `Distances`

function pairwise(d::PreMetric,
                  imgsA::AbstractVector{<:GenericImage},
                  imgsB::AbstractVector{<:GenericImage} = imgsA)
    m, n = length(imgsA), length(imgsB)
    D = zeros(m, n)
    for j = 1:n
        imgB = imgsB[j] # TODO: use view
        for i = 1:m
            imgA = imgsA[i] # TODO: use view
            @inbounds D[i,j] = d(imgA, imgB)
        end
    end

    D
end

# exploit symmetry of semimetric
function pairwise(d::SemiMetric, imgs::AbstractVector{<:GenericImage})
    n = length(imgs)
    D = zeros(n, n)
    for j = 1:n
        imgB = imgs[j] # TODO: use view
        for i = j + 1:n
            imgA = imgs[i] # TODO: use view
            @inbounds D[i,j] = d(imgA, imgB)
        end
        # nothing to be done to the diagonal (always zero)
        for i = 1:j - 1
            @inbounds D[i,j] = D[j,i] # leverage the symmetry
        end
    end

    D
end

# fallback

result_type(dist::PreMetric,
            a::AbstractArray{<:AbstractArray},
            b::AbstractArray{<:AbstractArray}) =
    result_type(dist, a[1], b[1]) # TODO: use view

for (ATa, ATb) in ((AbstractGray, AbstractGray),
                   (AbstractGray, Number),
                   (Number, AbstractGray),
                   (PromoteType, PromoteType),
                   (Color3, Color3))
    @eval function result_type(dist::PreMetric, ::Type{Ta}, ::Type{Tb}) where {Ta <: $ATa,Tb <: $ATb}
        T1 = eltype(floattype(Ta))
        T2 = eltype(floattype(Tb))
        result_type(dist, T1, T2)
    end
end
