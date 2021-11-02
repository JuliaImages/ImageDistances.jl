# patch for ColorVectorSpace 0.9
# for CVS < 0.9, we can just use the fallback solution in Distances
if isdefined(ImageCore.ColorVectorSpace, :⊙)
    # Because how abs2 calculated in color vector space is ambiguious, abs2(::RGB) is un-defined
    # since ColorVectorSpace 0.9
    # https://github.com/JuliaGraphics/ColorVectorSpace.jl/pull/131
    @inline _abs2(c::AbstractRGB) = red(c)^2+green(c)^2+blue(c)^2
    @inline _abs2(c::AbstractRGB{<:Normed}) = _abs2(float32(c))
    @inline _abs(c::AbstractRGB) = abs(red(c))+abs(green(c))+abs(blue(c))

    @inline Distances.eval_op(::Euclidean, ai::AbstractRGB, bi::AbstractRGB) = _abs2(ai - bi)
    @inline Distances.eval_op(::SqEuclidean, ai::AbstractRGB, bi::AbstractRGB) = _abs2(ai - bi)
    @inline Distances.eval_op(::Cityblock, ai::AbstractRGB, bi::AbstractRGB) = _abs(ai - bi)
    @inline Distances.eval_op(d::Minkowski, ai::AbstractRGB, bi::AbstractRGB) = _abs(ai - bi)^d.p
    @inline Distances.eval_op(::Hamming, ai::AbstractRGB, bi::AbstractRGB) = ai != bi ? 1 : 0
    @inline Distances.eval_op(::TotalVariation, ai::AbstractRGB, bi::AbstractRGB) = _abs(ai - bi)

    # The result can differ from CSV 0.8 because of the computational order
    _norm(X::AbstractArray{<:AbstractRGB}) = sqrt(_abs(sum(x->x⊙x, X)))
    _norm(X::AbstractArray) = norm(X)
else
    _norm(X::AbstractArray) = norm(X)
end

# depwarn fix for ImageMorphology v0.3
# https://github.com/JuliaImages/ImageMorphology.jl/pull/47
if isdefined(ImageMorphology, :SplitAxis)
    _feature_transform(img, weights; kwargs...) = feature_transform(img; weights=weights, kwargs...)
else
    const _feature_transform = feature_transform
end
