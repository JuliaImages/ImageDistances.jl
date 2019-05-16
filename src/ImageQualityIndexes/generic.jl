abstract type ImageQualityIndex end
evaluate(iqi::ImageQualityIndex, x, ref, args...) = iqi(x, ref, args...)
