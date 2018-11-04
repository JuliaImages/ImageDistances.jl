"""
    psnr(imgA, imgB, [maxvalue=1])

calculating peak signal to noise ratio (psnr) using the following equation

```math
    psnr = 10log_{10}\\big(\\frac{maxvalue^2}{MSE}\\big)
```

where `maxvalue` is the maximum possible pixel value of the image. High `psnr` indicates better image quality.

See also: [`mse`](@ref)
"""
psnr(imgA::AbstractArray, imgB::AbstractArray, maxvalue = 1) = 10*log10(maxvalue^2 / mse(imgA, imgB))