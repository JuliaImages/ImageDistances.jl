# ImageDistances.jl

[![][travis-img]][travis-url]
[![][pkgeval-img]][pkgeval-url]
[![][codecov-img]][codecov-url]

`ImageDistances.jl` aims to:

* follow the same API in [Distances.jl](https://github.com/JuliaStats/Distances.jl)
* support image types
* provide image-specific distances

## Usage

`ImageDistances.jl` is shipped together with `Images.jl`, but you can still use it as a standlone package.

```julia
# both line includes this package
using Images
using ImageDistances
```

Here's a simple usage example

```julia
using ImageDistances, TestImages

d = Euclidean()
imgA = testimage("cameraman") # N0f8
imgB = testimage("lena_gray_512") # N0f8

# distance between two images
evaluate(d, imgA, imgB) # 142.59576f0
d(imgA, imgB) # 142.59576f0
```

Distances are calculated regardless of the color type and storage type.

```julia
using ImageCore

# For gray image, all of them equals
d(imgA, imgB) # 142.59576f0
d(float32.(imgA), float32.(imgB)) # 142.59576f0
d(Float32.(imgA), Float32.(imgB)) # 142.59576f0
d(imgA, float32.(imgB)) # 142.59576f0
```

However, for `Color3` images such as `RGB`, it's noteworthy that the following results are
different in general.

```julia
d = NCC()
imgA = testimage("lena_color_512")
imgB = testimage("fabio_color_512")
# distance of each pixel is calculated first, and then sum up all pixels
d(imgA, imgB) # 0.023451565f0
# distance of each slice is calculated first, and then sum up three channels
d(channelview(imgA), channelview(imgB)) # 0.21142173f0
```

That's said, to achieve the same results to other languages, you need to `channelview` the image first to get a raw numeric view.

Just like in `Distances.jl`, huge performance gains are obtained by calling the `colwise` and `pairwise`
functions instead of naively looping over a collection of images and calling `evaluate`.

```julia
d = ModifiedHausdorff()

# two lists of images
imgsA = [imgA, imgB, ...]
imgsB = [imgB, imgA, ...]

# distance between the "columns"
colwise(d, imgsA, imgsB)

# distance between every pair of images
pairwise(d, imgsA, imgsB)
pairwise(d, imgsA)
```

## Distances

### General Distances

| type name               |  convenient syntax         | math definition                   |
| ----------------------- | -------------------------- | --------------------------------- |
|  Euclidean              |  `euclidean(x, y)`         | `sqrt(sum((x - y) .^ 2))`         |
|  SqEuclidean            |  `sqeuclidean(x, y)`       | `sum((x - y).^2)`                 |
|  Cityblock              |  `cityblock(x, y)`         | `sum(abs(x - y))`                 |
|  TotalVariation         |  `totalvariation(x, y)`    | `sum(abs(x - y)) / 2`             |
|  Minkowski              |  `minkowski(x, y, p)`      | `sum(abs(x - y).^p) ^ (1/p)`      |
|  Hamming                |  `hamming(x, y)`           | `sum(x .!= y)`                    |
|  SumAbsoluteDifference  |  `sad(x, y)`               | `sum(abs(x - y))`                 |
|  SumSquaredDifference   |  `ssd(x, y)`               | `sum((x - y).^2)`                 |
|  MeanAbsoluteError      |  `mae(x, y)`, `sadn(x, y)` | `sum(abs(x - y))/len(x)`          |
|  MeanSquaredError       |  `mse(x, y)`, `ssdn(x, y)` | `sum((x - y).^2)/len(x)`          |
|  RootMeanSquaredError   |  `rmse(x, y)`              | `sqrt(sum((x - y) .^ 2))`         |
|  NCC                    |  `ncc(x, y)`               | `dot(x,y)/(norm(x)*norm(y))`      |

### Image-specific Distances

| Distance type | Convenient syntax | References |
|----------|------------------------|------------|
| `Hausdorff` and `ModifiedHausdorff` | `hausdorff(imgA,imgB)` and `modified_hausdorff(imgA,imgB)` | Dubuisson, M-P et al. 1994. A Modified Hausdorff Distance for Object-Matching. |
| `CIEDE2000` | `ciede2000(imgA,imgB)` and `ciede2000(imgA,imgB; metric=DE_2000())` | Sharma, G., Wu, W., and Dalal, E. N., 2005. The CIEDE2000 color‐difference formula. |


<!-- URLS -->

[pkgeval-img]: https://juliaci.github.io/NanosoldierReports/pkgeval_badges/I/ImageDistances.svg
[pkgeval-url]: https://juliaci.github.io/NanosoldierReports/pkgeval_badges/report.html
[travis-img]: https://travis-ci.org/JuliaImages/ImageDistances.jl.svg?branch=master
[travis-url]: https://travis-ci.org/JuliaImages/ImageDistances.jl
[codecov-img]: https://codecov.io/github/JuliaImages/ImageDistances.jl/coverage.svg?branch=master
[codecov-url]: https://codecov.io/github/JuliaImages/ImageDistances.jl?branch=master
