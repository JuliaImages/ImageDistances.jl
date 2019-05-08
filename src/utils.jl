function sumdiff(f, A::AbstractArray, B::AbstractArray)
    axes(A) == axes(B) || throw(DimensionMismatch("A and B must have the same axes"))
    T = promote_type(difftype(eltype(A)), difftype(eltype(B)))
    s = zero(accum(eltype(T)))
    for (a, b) in zip(A, B)
        x = convert(T, a) - convert(T, b)
        s += f(x)
    end
    s
end

"`s = ssd(A, B)` computes the sum-of-squared differences over arrays/images A and B"
ssd(A::AbstractArray, B::AbstractArray) = sumdiff(abs2, A, B)

"`s = sad(A, B)` computes the sum-of-absolute differences over arrays/images A and B"
sad(A::AbstractArray, B::AbstractArray) = sumdiff(abs, A, B)

difftype(::Type{T}) where {T<:Integer} = Int
difftype(::Type{T}) where {T<:Real} = Float32
difftype(::Type{Float64}) = Float64
difftype(::Type{CV}) where {CV<:Colorant} = difftype(CV, eltype(CV))
difftype(::Type{CV}, ::Type{T}) where {CV<:RGBA,T<:Real} = RGBA{Float32}
difftype(::Type{CV}, ::Type{Float64}) where {CV<:RGBA} = RGBA{Float64}
difftype(::Type{CV}, ::Type{T}) where {CV<:BGRA,T<:Real} = BGRA{Float32}
difftype(::Type{CV}, ::Type{Float64}) where {CV<:BGRA} = BGRA{Float64}
difftype(::Type{CV}, ::Type{T}) where {CV<:AbstractGray,T<:Real} = Gray{Float32}
difftype(::Type{CV}, ::Type{Float64}) where {CV<:AbstractGray} = Gray{Float64}
difftype(::Type{CV}, ::Type{T}) where {CV<:AbstractRGB,T<:Real} = RGB{Float32}
difftype(::Type{CV}, ::Type{Float64}) where {CV<:AbstractRGB} = RGB{Float64}

accum(::Type{T}) where {T<:Integer} = Int
accum(::Type{Float32})    = Float32
accum(::Type{T}) where {T<:Real} = Float64
accum(::Type{C}) where {C<:Colorant} = base_colorant_type(C){accum(eltype(C))}

graytype(::Type{T}) where {T<:Number} = T
graytype(::Type{C}) where {C<:AbstractGray} = C
graytype(::Type{C}) where {C<:Colorant} = Gray{eltype(C)}

# normalized by Array size
"`s = ssdn(A, B)` computes the sum-of-squared differences over arrays/images A and B, normalized by array size"
ssdn(A::AbstractArray{T}, B::AbstractArray{T}) where {T} = ssd(A, B)/length(A)

# normalized by Array size
"`s = sadn(A, B)` computes the sum-of-absolute differences over arrays/images A and B, normalized by array size"
sadn(A::AbstractArray{T}, B::AbstractArray{T}) where {T} = sad(A, B)/length(A)

# normalized cross correlation
"""
`C = ncc(A, B)` computes the normalized cross-correlation of `A` and `B`.
"""
function ncc(A::AbstractArray{T}, B::AbstractArray{T}) where T
    Am = (A.-mean(A))[:]
    Bm = (B.-mean(B))[:]
    return dot(Am,Bm)/(norm(Am)*norm(Bm))
end

# Simple image difference testing
macro test_approx_eq_sigma_eps(A, B, sigma, eps)
    quote
        if size($(esc(A))) != size($(esc(B)))
            error("Sizes ", size($(esc(A))), " and ",
                  size($(esc(B))), " do not match")
        end
        kern = KernelFactors.IIRGaussian($(esc(sigma)))
        Af = imfilter($(esc(A)), kern, NA())
        Bf = imfilter($(esc(B)), kern, NA())
        diffscale = max(maxabsfinite($(esc(A))), maxabsfinite($(esc(B))))
        d = sad(Af, Bf)
        if d > length(Af)*diffscale*($(esc(eps)))
            error("Arrays A and B differ")
        end
    end
end

# image difference testing (@tbreloff's, based on the macro)
#   A/B: images/arrays to compare
#   sigma: tuple of ints... how many pixels to blur
#   eps: error allowance
# returns: percentage difference on match, error otherwise
function test_approx_eq_sigma_eps(A::AbstractArray, B::AbstractArray,
                         sigma::AbstractVector{T} = ones(ndims(A)),
                         eps::AbstractFloat = 1e-2,
                         expand_arrays::Bool = true) where T<:Real
    if size(A) != size(B)
        if expand_arrays
            newsize = map(max, size(A), size(B))
            if size(A) != newsize
                A = copyto!(zeros(eltype(A), newsize...), A)
            end
            if size(B) != newsize
                B = copyto!(zeros(eltype(B), newsize...), B)
            end
        else
            error("Arrays differ: size(A): $(size(A)) size(B): $(size(B))")
        end
    end
    if length(sigma) != ndims(A)
        error("Invalid sigma in test_approx_eq_sigma_eps. Should be ndims(A)-length vector of the number of pixels to blur.  Got: $sigma")
    end
    kern = KernelFactors.IIRGaussian(sigma)
    Af = imfilter(A, kern, NA())
    Bf = imfilter(B, kern, NA())
    diffscale = max(maxabsfinite(A), maxabsfinite(B))
    d = sad(Af, Bf)
    diffpct = d / (length(Af) * diffscale)
    if diffpct > eps
        error("Arrays differ.  Difference: $diffpct  eps: $eps")
    end
    diffpct
end
