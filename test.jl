using ImageDistances
using ImageCore, ImageShow
using Distances: eval_op

x = rand(RGB{N0f8}, 4, 4)
y = rand(RGB{N0f8}, 4, 4)

evaluate(Euclidean(), x, y)
evaluate(Minkowski(2), x, y)
