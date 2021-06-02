using BenchmarkTools
using ImageDistances
using Distances
using TestImages
using ImageBinarization

const SUITE = BenchmarkGroup()

on_CI = haskey(ENV, "GITHUB_ACTIONS")

function create_distances()
    dists = [
        SqEuclidean(),
        Euclidean(),
        Cityblock(),
        TotalVariation(),
        Minkowski(2),
        Hamming(),
        SumAbsoluteDifference(),
        SumSquaredDifference(),
        MeanAbsoluteError(),
        MeanSquaredError(),
        RootMeanSquaredError(),
        ZNCC(),
        Hausdorff(),
        ModifiedHausdorff(),
        CIEDE2000(),
    ]
    return dists
end

#############
# Distances #
############

SUITE["distances"] = BenchmarkGroup()

function add_distances_benchmarks!(SUITE)

    imgA = testimage("cameraman")
    imgB = testimage("livingroom")

    alg = Otsu()
    imgA = binarize(imgA, alg)
    imgB = binarize(imgA, alg)

    imgC = Float32.(imgA)
    imgD = Float32.(imgB)

    dists = create_distances()

    for dist in (dists)
        Tdist = typeof(dist)
        SUITE["distances"][Tdist] = BenchmarkGroup()
        SUITE["distances"][Tdist]["ImageDistances.jl"] =
            @benchmarkable evaluate($dist, $imgA, $imgB)
        SUITE["distances"][Tdist]["Distances.jl"] =
            @benchmarkable Distances.evaluate($dist, $imgC, $imgD)
    end
end

add_distances_benchmarks!(SUITE)

###########
# Colwise #
###########

SUITE["colwise"] = BenchmarkGroup()

function add_colwise_benchmarks!(SUITE)

    imgA = testimage("cameraman")
    imgB = testimage("livingroom")

    alg = Otsu()
    imgA = binarize(imgA, alg)
    imgB = binarize(imgA, alg)

    imgC = Float32.(imgA)
    imgD = Float32.(imgB)

    # Two lists of images
    imgsA = [imgA, imgB, imgA, imgB]
    imgsB = [imgB, imgA, imgA, imgB]

    imgsC = [imgC, imgD, imgC, imgD]
    imgsD = [imgD, imgC, imgC, imgD]

    dists = create_distances()

    for dist in (dists)
        Tdist = typeof(dist)
        SUITE["colwise"][Tdist] = BenchmarkGroup()
        SUITE["colwise"][Tdist]["ImageDistances.jl"] =
            @benchmarkable colwise($dist, $imgsA, $imgsB)
        SUITE["colwise"][Tdist]["Distances.jl"] =
            @benchmarkable Distances.colwise($dist, $imgsC, $imgsD)
    end
end

add_colwise_benchmarks!(SUITE)

############
# Pairwise #
############

SUITE["pairwise"] = BenchmarkGroup()

function add_pairwise_benchmarks!(SUITE)

    imgA = testimage("cameraman")
    imgB = testimage("livingroom")

    alg = Otsu()
    imgA = binarize(imgA, alg)
    imgB = binarize(imgA, alg)

    imgC = Float32.(imgA)
    imgD = Float32.(imgB)

    # Two lists of images
    imgsA = [imgA, imgB, imgA, imgB]
    imgsB = [imgB, imgA, imgA, imgB]

    imgsC = [imgC, imgD, imgC, imgD]
    imgsD = [imgD, imgC, imgC, imgD]
    dists = create_distances()

    for dist in (dists)
        Tdist = typeof(dist)
        SUITE["pairwise"][Tdist] = BenchmarkGroup()
        SUITE["pairwise"][Tdist]["ImageDistances.jl"] =
            @benchmarkable pairwise($dist, $imgsA, $imgsB)
        SUITE["pairwise"][Tdist]["Distances.jl"] =
            @benchmarkable Distances.pairwise($dist, $imgsC, $imgsD)
    end
end

add_pairwise_benchmarks!(SUITE)

