using BenchmarkTools
using ImageDistances
using TestImages

const SUITE = BenchmarkGroup()

on_CI = haskey(ENV, "GITHUB_ACTIONS")

function create_distances()
    dists = [
        SqEuclidean(),
        Euclidean(),
        Cityblock(),
    ]
    return dists
end

###########
# Colwise #
###########

SUITE["colwise"] = BenchmarkGroup()

function add_colwise_benchmarks!(SUITE)

    imgA = testimage("cameraman") # N0f8
    imgB = testimage("lena_gray_512") # N0f8

    # two lists of images
    imgsA = [imgA, imgB, imgA, imgB]
    imgsB = [imgB, imgA, imgA, imgB]

    dists = create_distances()

    for dist in (dists)
        Tdist = typeof(dist)
        SUITE["colwise"][Tdist] = BenchmarkGroup()
        SUITE["colwise"][Tdist]["specialized"] = @benchmarkable colwise($dist, $imgsA, $imgsB)
    end
end

add_colwise_benchmarks!(SUITE)


############
# Pairwise #
############

SUITE["pairwise"] = BenchmarkGroup()

function add_pairwise_benchmarks!(SUITE)

    imgA = testimage("cameraman") # N0f8
    imgB = testimage("lena_gray_512") # N0f8

    # two lists of images
    imgsA = [imgA, imgB, imgA, imgB]
    imgsB = [imgB, imgA, imgA, imgB]

    dists = create_distances()

    for dist in (dists)
        Tdist = typeof(dist)
        SUITE["pairwise"][Tdist] = BenchmarkGroup()
        SUITE["pairwise"][Tdist]["specialized"] = @benchmarkable pairwise($dist, $imgsA, $imgsB)
    end
end

add_pairwise_benchmarks!(SUITE)
