
"""
    Graph

Wrapper around a `SCOTCH_Graph` pointer.

References to the arrays which may have been used to build the graph are stored in the struct,
preventing them from being GC'ed by Julia.
"""
mutable struct Graph
    ptr         :: Ptr{LibScotch.SCOTCH_Graph}
    adj_index   :: Vector{SCOTCH_Num}
    adj_array   :: Vector{SCOTCH_Num}
    v_weights   :: Union{Vector{SCOTCH_Num}, Nothing}
    e_weights   :: Union{Vector{SCOTCH_Num}, Nothing}
    adj_idx_end :: Union{Vector{SCOTCH_Num}, Nothing}
    labels      :: Union{Vector{SCOTCH_Num}, Nothing}
    ctx
end

Base.cconvert(::Type{Ptr{LibScotch.SCOTCH_Graph}}, g::Graph) = g.ptr
Base.cconvert(::Type{Ptr{Cvoid}}, g::Graph) = Ptr{Cvoid}(g.ptr)


"""
    graph_alloc()

Allocate a new [`Graph`](@ref) with `SCOTCH_graphAlloc`, then initialize it with `SCOTCH_graphInit`.

Finalizers will properly call `SCOTCH_graphExit` then `SCOTCH_memFree` once unused.
"""
function graph_alloc()
    graph_ptr = LibScotch.SCOTCH_graphAlloc()
    graph = Graph(
        graph_ptr, Vector{SCOTCH_Num}(), Vector{SCOTCH_Num}(),
        nothing, nothing, nothing, nothing, nothing
    )
    @check LibScotch.SCOTCH_graphInit(graph)
    finalizer(graph) do g
        LibScotch.SCOTCH_graphExit(g)
        LibScotch.SCOTCH_memFree(g)
    end
    return graph
end


"""
    graph_size(graph::Graph)

Number of vertices and edges (arcs) of the `graph`.
"""
function graph_size(graph::Graph)
    n_vertices = Ref(SCOTCH_Num(0))
    n_edges = Ref(SCOTCH_Num(0))
    LibScotch.SCOTCH_graphSize(graph, n_vertices, n_edges)
    return (; vertices=n_vertices[], edges=n_edges[])
end


"""
    graph_build(
        adj_index::Vector{SCOTCH_Num}, adj_array::Vector{SCOTCH_Num};
        index_start=1, check=true,
        adj_index_end::Union{Vector{SCOTCH_Num}, Nothing}=nothing,
        v_weights::Union{Vector{SCOTCH_Num}, Nothing}=nothing,
        e_weights::Union{Vector{SCOTCH_Num}, Nothing}=nothing,
        labels::Union{Vector{SCOTCH_Num}, Nothing}=nothing
    )

Allocate and initialize a new [`Graph`](@ref) using `SCOTCH_graphBuild`.

If `check == true`, then `SCOTCH_graphCheck` may throw an error if the graph is invalid.

If `adj_index_end` is given, `adj_index` is considered to be non-compact.
"""
function graph_build(
    adj_index::Vector{SCOTCH_Num}, adj_array::Vector{SCOTCH_Num};
    index_start=1, check=true,
    adj_index_end::Union{Vector{SCOTCH_Num}, Nothing}=nothing,
    v_weights::Union{Vector{SCOTCH_Num}, Nothing}=nothing,
    e_weights::Union{Vector{SCOTCH_Num}, Nothing}=nothing,
    labels::Union{Vector{SCOTCH_Num}, Nothing}=nothing
)
    graph = graph_alloc()

    vertnbr = isnothing(adj_index_end) ? SCOTCH_Num(length(adj_index)+1) : SCOTCH_Num(length(adj_index))
    edgenbr = SCOTCH_Num(length(adj_array))

    verttab = pointer(adj_index)
    edgetab = pointer(adj_array)

    vendtab = isnothing(adj_index_end) ? C_NULL : pointer(adj_index_end)
    velotab = isnothing(v_weights)     ? C_NULL : pointer(v_weights)
    edlotab = isnothing(e_weights)     ? C_NULL : pointer(e_weights)
    vlbltab = isnothing(labels)        ? C_NULL : pointer(labels)

    @check LibScotch.SCOTCH_graphBuild(graph, index_start,
        vertnbr, verttab, vendtab, velotab, vlbltab,
        edgenbr, edgetab, edlotab
    )

    check && @check LibScotch.SCOTCH_graphCheck(graph)

    # Since SCOTCH does not do copies, all data is shared: therefore we must keep all arrays alive
    # together. The best way to do this is be grouping them all in the same object.
    graph.adj_index = adj_index
    graph.adj_array = adj_array
    graph.v_weights = v_weights
    graph.e_weights = e_weights
    graph.adj_index_end = adj_index_end
    graph.labels = labels
    return graph
end


function graph_dump(graph::Graph, file::IO, name_prefix::AbstractString, name_suffix::AbstractString)
    raw_file = Base.Libc.FILE(file)
    @check LibScotch.SCOTCH_graphDump(graph, raw_file, name_prefix, name_suffix)
    close(raw_file)
end


"""
    graph_dump(graph::Graph, filename::AbstractString, name_prefix::AbstractString, name_suffix::AbstractString)

Use `SCOTCH_graphDump` to dump the `graph` to `filename`.
"""
function graph_dump(graph::Graph, filename::AbstractString, name_prefix::AbstractString, name_suffix::AbstractString)
    open(filename, "w") do file
        graph_dump(graph, file, name_prefix, name_suffix)
    end
end


"""
    save(graph::Graph, file::IO)

Save the `graph` to `file` using `SCOTCH_graphSave`.
"""
function save(graph::Graph, file::IO)
    raw_file = Base.Libc.FILE(file)
    @check LibScotch.SCOTCH_graphSave(graph, raw_file)
    close(raw_file)
end


"""
    graph_load(file::IO; index_start=nothing, vertex_weights=true, edge_weights=true)
    graph_load(filename::AbstractString; kwargs...)

Load a new [`Graph`](@ref) from `file` with `SCOTCH_graphLoad`.

If `index_start == nothing`, then the base indexing of the file is conserved.
"""
function graph_load(file::IO; index_start=nothing, vertex_weights=true, edge_weights=true)
    graph = graph_alloc()
    index_start = isnothing(index_start) ? -1 : index_start  # -1: keep same start
    flagval = SCOTCH_Num(1) * !vertex_weights + SCOTCH_Num(2) * !edge_weights
    raw_file = Base.Libc.FILE(file)
    @check LibScotch.SCOTCH_graphLoad(graph, raw_file, index_start, flagval)
    close(raw_file)
    return graph
end


function graph_load(filename::AbstractString; kwargs...)
    open(filename, "r") do file
        return graph_load(file, kwargs...)
    end
end


"""
    graph_base_index(graph::Graph)

Return the base index of `graph`, using `SCOTCH_graphData`.
"""
function graph_base_index(graph::Graph)
    base_idx = Ref{SCOTCH_Num}(0)
    LibScotch.SCOTCH_graphData(graph, base_idx,
        C_NULL, C_NULL, C_NULL, C_NULL, C_NULL, C_NULL, C_NULL, C_NULL
    )
    return base_idx[]
end


"""
    graph_base_index!(graph::Graph, base_idx)

Sets the base index of `graph` using `SCOTCH_graphBase`
"""
function graph_base_index!(graph::Graph, base_idx)
    return LibScotch.SCOTCH_graphBase(graph, base_idx)
end


"""
    graph_data(graph::Graph)

Returns a `NamedTuple` containing:
```julia
(;
    index_start, n_vertices, n_arcs, n_edges,
    adj_idx, adj_idx_end, vertices_weights,
    vertices_labels, adj_array, arcs_weights
)
```

Arrays are either `nothing` or wrapped into a `Vector{SCOTCH_Num}`.
They share the data with the underlying `graph`.
"""
function graph_data(graph::Graph)
    base_idx             = Ref{SCOTCH_Num}(0)
    n_vertices           = Ref{SCOTCH_Num}(0)
    n_arcs               = Ref{SCOTCH_Num}(0)

    adj_idx_ptr          = Ref{Ptr{SCOTCH_Num}}(0)
    adj_idx_end_ptr      = Ref{Ptr{SCOTCH_Num}}(0)
    vertices_weights_ptr = Ref{Ptr{SCOTCH_Num}}(0)
    vertices_labels_ptr  = Ref{Ptr{SCOTCH_Num}}(0)
    adj_array_ptr        = Ref{Ptr{SCOTCH_Num}}(0)
    arcs_weights_ptr     = Ref{Ptr{SCOTCH_Num}}(0)

    LibScotch.SCOTCH_graphData(graph, base_idx,
        n_vertices, adj_idx_ptr, adj_idx_end_ptr, vertices_weights_ptr, vertices_labels_ptr,
        n_arcs, adj_array_ptr, arcs_weights_ptr
    )

    if adj_idx_end_ptr[] == adj_idx_ptr[] + 1
        adj_idx_end_ptr[] = C_NULL  # compact array
        adj_idx_len = n_vertices[] + 1
    else
        adj_idx_len = n_vertices[]
    end

    adj_idx          = adj_idx_ptr[]          == C_NULL ? nothing : unsafe_wrap(Vector{SCOTCH_Num}, adj_idx_ptr[],          adj_idx_len)
    adj_idx_end      = adj_idx_end_ptr[]      == C_NULL ? nothing : unsafe_wrap(Vector{SCOTCH_Num}, adj_idx_end_ptr[],      n_vertices[])
    vertices_weights = vertices_weights_ptr[] == C_NULL ? nothing : unsafe_wrap(Vector{SCOTCH_Num}, vertices_weights_ptr[], n_vertices[])
    vertices_labels  = vertices_labels_ptr[]  == C_NULL ? nothing : unsafe_wrap(Vector{SCOTCH_Num}, vertices_labels_ptr[],  n_vertices[])
    adj_array        = adj_array_ptr[]        == C_NULL ? nothing : unsafe_wrap(Vector{SCOTCH_Num}, adj_array_ptr[],        n_arcs[])  # might be wrong?
    arcs_weights     = arcs_weights_ptr[]     == C_NULL ? nothing : unsafe_wrap(Vector{SCOTCH_Num}, arcs_weights_ptr[],     n_arcs[])

    return (;
        index_start = base_idx[],
        n_vertices=n_vertices[], n_arcs=n_arcs[], n_edges=n_arcs[] ÷ 2,
        adj_idx, adj_idx_end,
        vertices_weights, vertices_labels,
        adj_array, arcs_weights
    )
end


"""
    graph_coarsen(fine_graph::Graph, n_vertices, coarsening_ratio;
        no_merge=false, coarse_multi_nodes::Union{Vector{SCOTCH_Num}, Nothing}=nothing,
        fine_mates::Union{Vector{SCOTCH_Num}, Nothing}=nothing
    )

Coarsen `fine_graph` into a new [`Graph`](@ref) with `n_vertices` at maximum.
Returns `(coarse_graph, coarse_multi_nodes)`, or `(nothing, nothing)` if the coarsening failed.

`no_merge` sets the `SCOTCH_COARSENNOMERGE` flag.

If `fine_mates` is given, `SCOTCH_graphCoarsenBuild` is used, `SCOTCH_graphCoarsen` otherwise.
"""
function graph_coarsen(fine_graph::Graph, n_vertices, coarsening_ratio;
    no_merge=false, coarse_multi_nodes::Union{Vector{SCOTCH_Num}, Nothing}=nothing,
    fine_mates::Union{Vector{SCOTCH_Num}, Nothing}=nothing
)
    coarse_graph = graph_alloc()

    if isnothing(coarse_multi_nodes)
        coarse_multi_nodes = Vector{SCOTCH_Num}(undef, n_vertices * 2)
    end

    flagval = SCOTCH_Num(0)
    no_merge && (flagval |= LibScotch.SCOTCH_COARSENNOMERGE)

    if isnothing(fine_mates)
        ret = LibScotch.SCOTCH_graphCoarsen(fine_graph, n_vertices, coarsening_ratio, flagval, coarse_graph, coarse_multi_nodes)
        ret == 1 && return nothing, nothing
        ret == 2 && error("SCOTCH call to SCOTCH_graphCoarsen returned 2")
    else
        @check LibScotch.SCOTCH_graphCoarsenBuild(fine_graph, n_vertices, fine_mates, coarse_graph, coarse_multi_nodes)
    end

    return coarse_graph, coarse_multi_nodes
end


"""
    graph_coarsen_match(fine_graph::Graph, n_vertices, coarsening_ratio;
        no_merge=false, fine_mates::Union{Vector{SCOTCH_Num}, Nothing}=nothing
    )

Fill `fine_mates` using `SCOTCH_graphCoarsenMatch`
Returns `(n_vertices, fine_mates)`, or `(nothing, nothing)` if the coarsening failed.

`no_merge` sets the `SCOTCH_COARSENNOMERGE` flag.
"""
function graph_coarsen_match(fine_graph::Graph, n_vertices, coarsening_ratio;
    no_merge=false, fine_mates::Union{Vector{SCOTCH_Num}, Nothing}=nothing
)
    if isnothing(fine_mates)
        fine_mates = Vector{SCOTCH_Num}(undef, graph_size(fine_graph).vertices)
    end

    flagval = SCOTCH_Num(0)
    no_merge && (flagval |= LibScotch.SCOTCH_COARSENNOMERGE)

    coarvertptr = Ref(SCOTCH_Num(n_vertices))
    ret = LibScotch.SCOTCH_graphCoarsenMatch(fine_graph, n_vertices, coarsening_ratio, flagval, fine_mates)
    ret == 1 && return 0, nothing
    ret == 2 && error("SCOTCH call to SCOTCH_graphCoarsenMatch returned 2")

    return coarvertptr[], fine_mates
end


"""
    graph_color(graph::Graph; colors::Union{Vector{SCOTCH_Num}, Nothing}=nothing)

Compute a coloring of the `graph` using `SCOTCH_graphColor`. Returns `(n_colors, colors)`.
"""
function graph_color(graph::Graph; colors::Union{Vector{SCOTCH_Num}, Nothing}=nothing)
    if isnothing(colors)
        colors = Vector{SCOTCH_Num}(undef, graph_size(graph).vertices)
    end

    flagval = SCOTCH_Num(0)

    n_colors = Ref{SCOTCH_Num}(0)
    @check LibScotch.SCOTCH_graphColor(graph, colors, n_colors, flagval)

    return n_colors[], colors
end


"""
    graph_diameter(graph::Graph)

Diameter of the `graph`, using `SCOTCH_graphDiamPV`.
"""
function graph_diameter(graph::Graph)
    diameter = LibScotch.SCOTCH_graphDiamPV(graph)
    diameter == -1 && error("SCOTCH call to SCOTCH_graphDiamPV returned -1")
    return diameter
end


"""
    graph_induce(graph::Graph, keep_vertices::Vector{SCOTCH_Num})

A new [`Graph`] induced from `graph` by keeping the vertices in `keep_vertices`, using `SCOTCH_graphInduceList`.
"""
function graph_induce(graph::Graph, keep_vertices::Vector{SCOTCH_Num})
    induced_graph = graph_alloc()
    @check LibScotch.SCOTCH_graphInduceList(graph, length(keep_vertices), keep_vertices, induced_graph)
    return induced_graph
end


"""
    graph_induce(graph::Graph, vertices_part::Vector{SCOTCH_GraphPart2}, keep_part::SCOTCH_GraphPart2)

A new [`Graph`] induced from `graph` by keeping the vertices for which `vertices_part` matches `keep_part`,
using `SCOTCH_graphInducePart`.
"""
function graph_induce(graph::Graph, vertices_part::Vector{SCOTCH_GraphPart2}, keep_part::SCOTCH_GraphPart2)
    induced_graph = graph_alloc()
    vnumnbr = count(==(keep_part), vertices_part)
    @check LibScotch.SCOTCH_graphInducePart(graph, vnumnbr, vertices_part, keep_part, induced_graph)
    return induced_graph
end


"""
    graph_stat(graph::Graph)

Statistics about the `graph`: returns `(; vertex_load, edge_load, vertex_degree)`.
Each value contains the following fields: `min`, `max`, `sum` (not for `vertex_degree`), `avg` (average)
and `var` (standard deviation).
"""
function graph_stat(graph::Graph)
    velomin = Ref{SCOTCH_Num}(0); velomax = Ref{SCOTCH_Num}(0); velosum = Ref{SCOTCH_Num}(0)
    degrmin = Ref{SCOTCH_Num}(0); degrmax = Ref{SCOTCH_Num}(0)
    edlomin = Ref{SCOTCH_Num}(0); edlomax = Ref{SCOTCH_Num}(0); edlosum = Ref{SCOTCH_Num}(0)
    veloavg = Ref{Float64}(0.0);  velodlt = Ref{Float64}(0.0)
    degravg = Ref{Float64}(0.0);  degrdlt = Ref{Float64}(0.0)
    edloavg = Ref{Float64}(0.0);  edlodlt = Ref{Float64}(0.0)
    @check LibScotch.SCOTCH_graphStat(graph,
        velomin, velomax, velosum, veloavg, velodlt,
        degrmin, degrmax, degravg, degrdlt,
        edlomin, edlomax, edlosum, edloavg, edlodlt
    )
    return (;
        vertex_load   = (; min=velomin[], max=velomax[], sum=velosum[], avg=veloavg[], var=velodlt[]),
        edge_load     = (; min=edlomin[], max=edlomax[], sum=edlosum[], avg=edloavg[], var=edlodlt[]),
        vertex_degree = (; min=degrmin[], max=degrmax[],                avg=degravg[], var=degrdlt[]),
    )
end


"""
    graph_map(graph::Graph, arch::Arch, strat::Strat; partition=nothing, fixed=false)

Map `graph` to `arch` with `strat` using `SCOTCH_graphMap`.
Returns `partition` while conserving the base index of the `graph`.

If `fixed == true`, then `partition` gives the fixed vertices and `SCOTCH_graphMapFixed` is used instead.
"""
function graph_map(graph::Graph, arch::Arch, strat::Strat; partition=nothing, fixed=false)
    index_start = graph_base_index(graph)

    if fixed
        isnothing(partition) && throw(ArgumentError("`fixed=true` requires `partition`"))
        index_start != 0 && for (i, v) in enumerate(partition)
            # Keep fixed vertices, move others to 0:n_vertices-1
            partition[i] = ifelse(v == -1, v, v - index_start)
        end
    elseif isnothing(partition)
        partition = Vector{SCOTCH_Num}(undef, graph_size(graph).vertices)
    end

    if fixed
        @check LibScotch.SCOTCH_graphMapFixed(graph, arch, strat, partition)
    else
        @check LibScotch.SCOTCH_graphMap(graph, arch, strat, partition)
    end

    index_start != 0 && (partition .+= index_start)
    return partition
end


"""
    graph_remap(
        graph::Graph, arch::Arch, old_partition::Vector{SCOTCH_Num},
        cost_factor::Float64, costs::Vector{SCOTCH_Num}, strat::Strat;
        partition=nothing, fixed=false
    )

Compute a mapping from an `old_partition`, `costs` and `cost_factor`, using `SCOTCH_graphRemap`.
Returns `partition` while conserving the base index of the `graph`.

If `fixed == true`, then `partition` gives the fixed vertices and `SCOTCH_graphRemapFixed is used instead.
"""
function graph_remap(
    graph::Graph, arch::Arch, old_partition::Vector{SCOTCH_Num},
    cost_factor::Float64, costs::Vector{SCOTCH_Num}, strat::Strat;
    partition=nothing, fixed=false
)
    index_start = graph_base_index(graph)

    if fixed
        isnothing(partition) && throw(ArgumentError("`fixed=true` requires `partition`"))
        index_start != 0 && for (i, v) in enumerate(partition)
            # Keep fixed vertices, move others to 0:n_vertices-1
            partition[i] = ifelse(v == -1, v, v - index_start)
        end
    elseif isnothing(partition)
        partition = Vector{SCOTCH_Num}(undef, graph_size(graph).vertices)
    end

    if fixed
        @check LibScotch.SCOTCH_graphRemapFixed(graph, arch, old_partition, cost_factor, costs, strat, partition)
    else
        @check LibScotch.SCOTCH_graphRemap(graph, arch, old_partition, cost_factor, costs, strat, partition)
    end

    index_start != 0 && (partition .+= index_start)
    return partition
end


"""
    graph_part(graph::Graph, parts, strat::Strat; partition=nothing, fixed=false, overlap=false)

Partitions the `graph` into `parts`, with the given `strat`egy, using `SCOTCH_graphPart`.
Returns `partition` while conserving the base index of the `graph`.

If `fixed == true`, then `partition` gives the fixed vertices and `SCOTCH_graphPartFixed is used instead.

If `overlap == true`, then `SCOTCH_graphPartOvl` is used instead.
"""
function graph_part(graph::Graph, parts, strat::Strat; partition=nothing, fixed=false, overlap=false)
    index_start = graph_base_index(graph)

    if fixed
        overlap && throw(ArgumentError("`fixed` and `overlap` are mutually exclusive"))
        isnothing(partition) && throw(ArgumentError("`fixed=true` requires `partition`"))
        index_start != 0 && for (i, v) in enumerate(partition)
            # Keep fixed vertices, move others to 0:n_vertices-1
            partition[i] = ifelse(v == -1, v, v - index_start)
        end
    elseif isnothing(partition)
        partition = Vector{SCOTCH_Num}(undef, graph_size(graph).vertices)
    end

    if fixed
        @check LibScotch.SCOTCH_graphPartFixed(graph, parts, strat, partition)
    elseif overlap
        @check LibScotch.SCOTCH_graphPartOvl(graph, parts, strat, partition)
    else
        @check LibScotch.SCOTCH_graphPart(graph, parts, strat, partition)
    end

    if index_start != 0
        if overlap
            for (i, v) in enumerate(partition)
                partition[i] = ifelse(v == -1, v, v - index_start)
            end
        else
            partition .+= index_start
        end
    end
    return partition
end


"""
    graph_repart(
        graph::Graph, parts, old_partition::Vector{SCOTCH_Num},
        cost_factor::Float64, costs::Vector{SCOTCH_Num}, strat::Strat;
        partition=nothing, fixed=false
    )

Re-partitions the `graph` into `parts`, with the `old_partition`, `costs` and `cost_factor`, using `SCOTCH_graphRepart`.
Returns `partition` while conserving the base index of the `graph`.

If `fixed == true`, then `partition` gives the fixed vertices and `SCOTCH_graphPartFixed is used instead.
"""
function graph_repart(
    graph::Graph, parts, old_partition::Vector{SCOTCH_Num},
    cost_factor::Float64, costs::Vector{SCOTCH_Num}, strat::Strat;
    partition=nothing, fixed=false
)
    index_start = graph_base_index(graph)

    if fixed
        isnothing(partition) && throw(ArgumentError("`fixed=true` requires `partition`"))
        index_start != 0 && for (i, v) in enumerate(partition)
            # Keep fixed vertices, move others to 0:n_vertices-1
            partition[i] = ifelse(v == -1, v, v - index_start)
        end
    elseif isnothing(partition)
        partition = Vector{SCOTCH_Num}(undef, graph_size(graph).vertices)
    end

    if fixed
        @check LibScotch.SCOTCH_graphRepartFixed(graph, parts, old_partition, cost_factor, costs, strat, partition)
    else
        @check LibScotch.SCOTCH_graphRepart(graph, parts, old_partition, cost_factor, costs, strat, partition)
    end

    index_start != 0 && (partition .+= index_start)
    return partition
end
