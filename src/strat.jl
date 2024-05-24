
mutable struct Strat
    ptr :: Ptr{LibScotch.SCOTCH_Strat}
end

Base.cconvert(::Type{Ptr{LibScotch.SCOTCH_Strat}}, s::Strat) = s.ptr
Base.cconvert(::Type{Ptr{Cvoid}}, s::Strat) = Ptr{Cvoid}(s.ptr)


function strat_alloc()
    strat = Strat(LibScotch.SCOTCH_stratAlloc())
    @check LibScotch.SCOTCH_stratInit(strat)
    finalizer(strat) do s
        LibScotch.SCOTCH_stratExit(s)
        LibScotch.SCOTCH_memFree(s)
    end
    return strat
end


function strat_flags(; strategy=:default,
    recursive=false, remap=false,
    disconnected=false, level_max=false, level_min=false, leaf_simple=false, sepa_simple=false
)
    flagval = SCOTCH_Num(0)
    if     strategy === :default  flagval |= LibScotch.SCOTCH_STRATDEFAULT 
    elseif strategy === :balance  flagval |= LibScotch.SCOTCH_STRATBALANCE
    elseif strategy === :quality  flagval |= LibScotch.SCOTCH_STRATQUALITY
    elseif strategy === :safety   flagval |= LibScotch.SCOTCH_STRATSAFETY
    elseif strategy === :speed    flagval |= LibScotch.SCOTCH_STRATSPEED
    else   throw(ArgumentError("unknown strategy: $strategy"))
    end

    recursive    && (flagval |= LibScotch.SCOTCH_STRATRECURSIVE)
    remap        && (flagval |= LibScotch.SCOTCH_STRATREMAP)
    disconnected && (flagval |= LibScotch.SCOTCH_STRATDISCONNECTED)
    level_max    && (flagval |= LibScotch.SCOTCH_STRATLEVELMAX)
    level_min    && (flagval |= LibScotch.SCOTCH_STRATLEVELMIN)
    leaf_simple  && (flagval |= LibScotch.SCOTCH_STRATLEAFSIMPLE)
    sepa_simple  && (flagval |= LibScotch.SCOTCH_STRATSEPASIMPLE)

    return flagval
end


function strat(flag, partitions, imbalance_ratio; kwargs...)
    flagval = strat_flags(; strategy=flag, kwargs...)
    strat = strat_alloc()
    @check LibScotch.SCOTCH_stratGraphMapBuild(strat, flagval, partitions, imbalance_ratio)
    return strat
end


function strat(type::Symbol, strategy::AbstractString)
    strat = strat_alloc()
    if type === :graph_bipart
        @check LibScotch.SCOTCH_stratGraphBipart(strat, strategy)
    elseif type === :graph_map
        @check LibScotch.SCOTCH_stratGraphMap(strat, strategy)
    elseif type === :graph_part_overlap
        @check LibScotch.SCOTCH_stratGraphPartOvl(strat, strategy)
    elseif type === :graph_order
        @check LibScotch.SCOTCH_stratGraphOrder(strat, strategy)
    elseif type === :mesh_order
        @check LibScotch.SCOTCH_stratMeshOrder(strat, strategy)
    else
        throw(ArgumentError("unknown strategy type: $type"))
    end
    return strat
end


function strat_build(type::Symbol;
    imbalance_ratio::Float64=0.0, parts=0,
    max_cluster_weight=0, min_edge_density=0.0, level_nbr=0,
    strategy=:default, kwargs...
)
    strat = strat_alloc()
    flagval = strat_flags(; strategy, kwargs...)

    if type === :graph_bipart
        @check LibScotch.SCOTCH_stratGraphClusterBuild(strat, flagval, max_cluster_weight, min_edge_density, imbalance_ratio)
    elseif type === :graph_map
        @check LibScotch.SCOTCH_stratGraphMapBuild(strat, flagval, parts, imbalance_ratio)
    elseif type === :graph_part_overlap
        @check LibScotch.SCOTCH_stratGraphPartOvlBuild(strat, flagval, parts, imbalance_ratio)
    elseif type === :graph_order
        @check LibScotch.SCOTCH_stratGraphOrderBuild(strat, flagval, level_nbr, imbalance_ratio)
    elseif type === :mesh_order
        @check LibScotch.SCOTCH_stratMeshOrderBuild(strat, flagval, imbalance_ratio)
    else
        throw(ArgumentError("unknown strategy type: $type"))
    end

    return strat
end


function save(strat::Strat, file::IOStream)
    @check LibScotch.SCOTCH_stratSave(strat, file)
end
