using EarthMoversDistance: CSignature, CFlow, FLOW_ARRAY_SIZE

struct EarthMoverBinned{F,H<:AbstractArray,C} <: ImageMetric
    binner!::F
    histA::H
    histB::H
    sigA::CSignature
    sigB::CSignature
    cost::C
    cflow::Vector{CFlow}
end

function costlb(ip, jp, edges::AbstractVector{T}) where T
    # lower-bound cost
    # Adjacent bins have no cost, because you may move by "epsilon" and cross over
    # to the next bin
    i, j = ip[], jp[]
    ii, jj = Int(i), Int(j)
    # The final bin is for NaN pixels, which match with zero cost
    (abs(ii-jj) <= 1 || ii == length(edges)+2 || jj == length(edges)+2) && return zero(Cfloat)
    return Cfloat(ii > jj ? edges[ii-1] - edges[jj] : edges[jj-1] - edges[ii])
end

function EarthMoverBinned(edges::AbstractVector, cost=(i, j)->costlb(i, j, edges))
    binner! = graybinner(edges)
    len = length(edges)+2
    len > FLOW_ARRAY_SIZE && error("edges exceeded maximum allowed size of $(EarthMoversDistance.FLOW_ARRAY_SIZE)")
    histA, histB = Vector{Cfloat}(undef, len), Vector{Cfloat}(undef, len)
    sigA, sigB = CSignature(histA), CSignature(histB)
    costfun = @cfunction $cost Cfloat (Ref{Cfloat}, Ref{Cfloat})
    cflow = fill(CFlow(0, 0, 0), FLOW_ARRAY_SIZE)
    metric = EarthMoverBinned(binner!, histA, histB, sigA, sigB, costfun, cflow)
    # For reasons that are not clear, the first usage errors unless we do the following:
    evaluate(metric, [0.0f0], [0.0f0])
    return metric
end

function evaluate(em::EarthMoverBinned, imgA::AbstractArray, imgB::AbstractArray)
    em.binner!(em.histA, imgA)
    em.binner!(em.histB, imgB)
    # Do the ccall directly to avoid the allocations
    cflowsizeptr = Ref{Cint}(0)
    res = ccall((:emd, :emd), # function name and library name
                Cfloat,       # return type
                (Ref{CSignature}, Ref{CSignature}, Ptr{Nothing}, Ref{CFlow}, Ref{Cint}), # argument types
                Ref(em.sigA), Ref(em.sigB), em.cost, em.cflow, cflowsizeptr)
    return res
end

function graybinner(edges::AbstractVector)
    @assert !Base.has_offset_axes(edges)
    ord = Base.Order.ForwardOrdering()
    @assert issorted(edges, ord)
    let ord=ord   # julia issue #15276
        function graybinner!(hist, A)
            fill!(hist, 0)
            for a in A
                if isnan(a)
                    hist[end] += oneunit(eltype(hist))
                else
                    hist[searchsortedfirst(edges, a, ord)] += oneunit(eltype(hist))
                end
            end
            return hist
        end
    end
end
