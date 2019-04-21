# ImageDistances.jl

[![Build Status](https://travis-ci.org/JuliaImages/ImageDistances.jl.svg?branch=master)](https://travis-ci.org/JuliaImages/ImageDistances.jl)
[![codecov.io](http://codecov.io/github/JuliaImages/ImageDistances.jl/coverage.svg?branch=master)](http://codecov.io/github/JuliaImages/ImageDistances.jl?branch=master)

Distances between images following the [Distances.jl](https://github.com/JuliaStats/Distances.jl) API.

## Installation

Get the latest stable release with Julia's package manager:

```julia
] add ImageDistances
```

## Usage

```julia
using ImageDistances

d = ModifiedHausdorff()

# distance between two images
evaluate(d, imgA, imgB)

# two lists of images
imgsA = [imgA, imgB, ...]
imgsB = [imgB, imgA, ...]

# distance between the "columns"
colwise(d, imgsA, imgsB)

# distance between every pair of images
pairwise(d, imgsA, imgsB)
pairwise(d, imgsA)
```

Like in Distances.jl, huge performance gains are obtained by calling the `colwise` and `pairwise`
functions instead of naively looping over a collection of images and calling `evaluate`.

## Distances

| Distance type | Convenient syntax | References |
|----------|------------------------|------------|
| `Hausdorff` and `ModifiedHausdorff` | `hausdorff(imgA,imgB)` and `modified_hausdorff(imgA,imgB)` | Dubuisson, M-P et al. 1994. A Modified Hausdorff Distance for Object-Matching. |
| `CIEDE2000` | `ciede2000(imgA,imgB)` and `ciede2000(imgA,imgB,ciede_metric)` | Sharma, G., Wu, W., and Dalal, E. N., 2005. The CIEDE2000 color‐difference formula. |

## Contributing

Contributions are very welcome, as are feature requests and suggestions.

Please [open an issue](https://github.com/juliohm/ImageDistances.jl/issues) if you encounter
any problems.
