
"""
    Graph

Wrapper around a `SCOTCH_Graph` pointer.

References to the arrays which may have been used to build the graph are stored in the struct,
preventing them from being GC'ed by Julia.
"""
mutable struct Graph
    ptr         :: Ptr{LibScotch.SCOTCH_Graph}
    n_vertices  :: SCOTCH_Num
    n_edges     :: SCOTCH_Num
    index_start :: SCOTCH_Num
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
        graph_ptr, 0, 0, 0, Vector{SCOTCH_Num}(), Vector{SCOTCH_Num}(),
        nothing, nothing, nothing, nothing, nothing
    )
    @check LibScotch.SCOTCH_graphInit(graph)
    finalizer(graph) do g
        LibScotch.SCOTCH_graphExit(g)
        LibScotch.SCOTCH_memFree(g)
    end
    return graph
end


function graph_size(graph::Ptr{LibScotch.SCOTCH_Graph})
    n_vertices = Ref(SCOTCH_Num(0))
    n_edges = Ref(SCOTCH_Num(0))
    LibScotch.SCOTCH_graphSize(graph, n_vertices, n_edges)
    return n_vertices[], n_edges[]
end

"""
    graph_size(graph::Graph)

Number of vertices and edges of the `graph`.
"""
graph_size(graph::Graph) = graph.n_vertices, graph.n_edges


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
    graph.n_vertices = vertnbr
    graph.n_edges = edgenbr
    graph.index_start = index_start
    graph.adj_index = adj_index
    graph.adj_array = adj_array
    graph.v_weights = v_weights
    graph.e_weights = e_weights
    graph.adj_index_end = adj_index_end
    graph.labels = labels
    return graph
end


function graph_dump(graph::Graph, file::IOStream, name_prefix::AbstractString, name_suffix::AbstractString)
    @check LibScotch.SCOTCH_graphDump(graph, file, name_prefix, name_suffix)
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


function save(graph::Graph, file::IOStream)
    @check LibScotch.SCOTCH_graphSave(graph, file)
end


"""
    graph_load(file::IOStream; index_start=nothing, vertex_weights=true, edge_weights=true)

Load a new [`Graph`](@ref) from `file` with `SCOTCH_graphLoad`.

If `index_start == nothing`, then the base indexing of the file is conserved.
"""
function graph_load(file::IOStream; index_start=nothing, vertex_weights=true, edge_weights=true)
    graph = graph_alloc()
    index_start = isnothing(index_start) ? -1 : index_start  # -1: keep same start
    flagval = SCOTCH_Num(1) * !vertex_weights + SCOTCH_Num(2) * !edge_weights
    @check LibScotch.SCOTCH_graphLoad(graph, file, index_start, flagval)
    return graph
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
        fine_mates = Vector{SCOTCH_Num}(undef, fine_graph.n_vertices)
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
        colors = Vector{SCOTCH_Num}(undef, graph.n_vertices)
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
    if fixed
        isnothing(partition) && throw(ArgumentError("`fixed=true` requires `partition`"))
        graph.index_start != 0 && for (i, v) in enumerate(partition)
            # Keep fixed vertices, move others to 0:n_vertices-1
            partition[i] = ifelse(v == -1, v, v - graph.index_start)
        end
    elseif isnothing(partition)
        partition = Vector{SCOTCH_Num}(undef, graph.n_vertices)
    end

    if fixed
        @check LibScotch.SCOTCH_graphMapFixed(graph, arch, strat, partition)
    else
        @check LibScotch.SCOTCH_graphMap(graph, arch, strat, partition)
    end

    graph.index_start != 0 && (partition .+= graph.index_start)
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
    if fixed
        isnothing(partition) && throw(ArgumentError("`fixed=true` requires `partition`"))
        graph.index_start != 0 && for (i, v) in enumerate(partition)
            # Keep fixed vertices, move others to 0:n_vertices-1
            partition[i] = ifelse(v == -1, v, v - graph.index_start)
        end
    elseif isnothing(partition)
        partition = Vector{SCOTCH_Num}(undef, graph.n_vertices)
    end

    if fixed
        @check LibScotch.SCOTCH_graphRemapFixed(graph, arch, old_partition, cost_factor, costs, strat, partition)
    else
        @check LibScotch.SCOTCH_graphRemap(graph, arch, old_partition, cost_factor, costs, strat, partition)
    end

    graph.index_start != 0 && (partition .+= graph.index_start)
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
    if fixed
        overlap && throw(ArgumentError("`fixed` and `overlap` are mutually exclusive"))
        isnothing(partition) && throw(ArgumentError("`fixed=true` requires `partition`"))
        graph.index_start != 0 && for (i, v) in enumerate(partition)
            # Keep fixed vertices, move others to 0:n_vertices-1
            partition[i] = ifelse(v == -1, v, v - graph.index_start)
        end
    elseif isnothing(partition)
        partition = Vector{SCOTCH_Num}(undef, graph.n_vertices)
    end

    if fixed
        @check LibScotch.SCOTCH_graphPartFixed(graph, parts, strat, partition)
    elseif overlap
        @check LibScotch.SCOTCH_graphPartOvl(graph, parts, strat, partition)
    else
        @check LibScotch.SCOTCH_graphPart(graph, parts, strat, partition)
    end

    if graph.index_start != 0
        if overlap
            for (i, v) in enumerate(partition)
                partition[i] = ifelse(v == -1, v, v - graph.index_start)
            end
        else
            partition .+= graph.index_start
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
    if fixed
        isnothing(partition) && throw(ArgumentError("`fixed=true` requires `partition`"))
        graph.index_start != 0 && for (i, v) in enumerate(partition)
            # Keep fixed vertices, move others to 0:n_vertices-1
            partition[i] = ifelse(v == -1, v, v - graph.index_start)
        end
    elseif isnothing(partition)
        partition = Vector{SCOTCH_Num}(undef, graph.n_vertices)
    end

    if fixed
        @check LibScotch.SCOTCH_graphRepartFixed(graph, parts, old_partition, cost_factor, costs, strat, partition)
    else
        @check LibScotch.SCOTCH_graphRepart(graph, parts, old_partition, cost_factor, costs, strat, partition)
    end

    graph.index_start != 0 && (partition .+= graph.index_start)
    return partition
end
