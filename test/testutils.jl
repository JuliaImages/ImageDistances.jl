const SizeLike = Union{Integer,AbstractUnitRange}

function generate_test_types(number_types::AbstractArray, color_types::AbstractArray)
    test_types = map(Iterators.product(number_types, color_types)) do T
        try
            T[2]{T[1]}
        catch err
            !isa(err, TypeError) && rethrow(err)
        end
    end
    test_types = filter(x->x != false, test_types)
end
