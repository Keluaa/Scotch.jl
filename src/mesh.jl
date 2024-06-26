
"""
    Mesh

Wrapper around a `SCOTCH_Mesh` pointer.

References to the arrays which may have been used to build the mesh are stored in the struct,
preventing them from being GC'ed by Julia.
"""
mutable struct Mesh
    ptr           :: Ptr{LibScotch.SCOTCH_Mesh}
    adj_index     :: Vector{SCOTCH_Num}
    adj_array     :: Vector{SCOTCH_Num}
    adj_index_end :: Union{Vector{SCOTCH_Num}, Nothing}
    element_load  :: Union{Vector{SCOTCH_Num}, Nothing}
    vertex_load   :: Union{Vector{SCOTCH_Num}, Nothing}
    vertex_labels :: Union{Vector{SCOTCH_Num}, Nothing}
    ctx
end

Base.cconvert(::Type{Ptr{LibScotch.SCOTCH_Mesh}}, m::Mesh) = m.ptr
Base.cconvert(::Type{Ptr{Cvoid}}, m::Mesh) = Ptr{Cvoid}(m.ptr)


"""
    mesh_alloc()

Allocate a new [`Mesh`](@ref) with `SCOTCH_meshAlloc`, then initialize it with `SCOTCH_meshInit`.

Finalizers will properly call `SCOTCH_meshExit` then `SCOTCH_memFree` once unused.
"""
function mesh_alloc()
    mesh_ptr = LibScotch.SCOTCH_meshAlloc()
    mesh = Mesh(mesh_ptr, Vector{SCOTCH_Num}(), Vector{SCOTCH_Num}(), nothing, nothing, nothing, nothing, nothing)
    @check LibScotch.SCOTCH_meshInit(mesh)
    finalizer(mesh) do m
        LibScotch.SCOTCH_meshExit(m)
        LibScotch.SCOTCH_memFree(m)
    end
    return mesh
end


"""
    mesh_build(adj_index::Vector{SCOTCH_Num}, adj_array::Vector{SCOTCH_Num}, elem_count, node_count;
        index_start_element=1, index_start_node=1, check=true, arc_count=length(adj_array),
        adj_index_end::Union{Vector{SCOTCH_Num}, Nothing}=nothing,
        element_load ::Union{Vector{SCOTCH_Num}, Nothing}=nothing,
        vertex_load  ::Union{Vector{SCOTCH_Num}, Nothing}=nothing,
        vertex_labels::Union{Vector{SCOTCH_Num}, Nothing}=nothing,
    )

Allocate and initialize a new [`Mesh`](@ref) using `SCOTCH_meshBuild`.

`arc_count` is twice the number of edges. The default value assumes that `adj_array` is compact.

If `check == true`, then `SCOTCH_meshCheck` may throw an error if the mesh is invalid.
"""
function mesh_build(adj_index::Vector{SCOTCH_Num}, adj_array::Vector{SCOTCH_Num}, elem_count, node_count;
    index_start_element=1, index_start_node=1, check=true, arc_count=length(adj_array),
    adj_index_end::Union{Vector{SCOTCH_Num}, Nothing}=nothing,
    element_load ::Union{Vector{SCOTCH_Num}, Nothing}=nothing,
    vertex_load  ::Union{Vector{SCOTCH_Num}, Nothing}=nothing,
    vertex_labels::Union{Vector{SCOTCH_Num}, Nothing}=nothing,
)
    mesh = mesh_alloc()

    vendtab = isnothing(adj_index_end) ? C_NULL : pointer(adj_index_end)
    velotab = isnothing(element_load)  ? C_NULL : pointer(element_load)
    vnlotab = isnothing(vertex_load)   ? C_NULL : pointer(vertex_load)
    vlbltab = isnothing(vertex_labels) ? C_NULL : pointer(vertex_labels)

    @check LibScotch.SCOTCH_meshBuild(mesh,
        index_start_element, index_start_node, elem_count, node_count,
        adj_index, vendtab, velotab, vnlotab, vlbltab,
        arc_count, adj_array
    )

    check && @check LibScotch.SCOTCH_meshCheck(mesh)

    # Since SCOTCH does not do copies, all data is shared: therefore we must keep all arrays alive
    # together. The best way to do this is be grouping them all in the same object.
    mesh.adj_index = adj_index
    mesh.adj_array = adj_array
    mesh.adj_index_end = adj_index_end
    mesh.element_load  = element_load 
    mesh.vertex_load   = vertex_load  
    mesh.vertex_labels = vertex_labels
    return mesh
end


"""
    mesh_data(mesh::Mesh)

Returns a `NamedTuple` containing:
```julia
(;
    base_element_index, base_node_index,
    n_elements, n_nodes, n_arcs, n_edges,
    adj_idx, adj_idx_end,
    elements_weights, nodes_weights, vertex_labels,
    adj_array,
    max_vertex_degree
)
```

Arrays are either `nothing` or wrapped into a `Vector{SCOTCH_Num}`.
They share the data with the underlying `mesh`.
"""
function mesh_data(mesh::Mesh)
    base_element_index   = Ref{SCOTCH_Num}(0)
    base_node_index      = Ref{SCOTCH_Num}(0)
    n_elements           = Ref{SCOTCH_Num}(0)
    n_nodes              = Ref{SCOTCH_Num}(0)
    n_arcs               = Ref{SCOTCH_Num}(0)
    max_vertex_degree    = Ref{SCOTCH_Num}(0)

    adj_idx_ptr          = Ref{Ptr{SCOTCH_Num}}(0)
    adj_idx_end_ptr      = Ref{Ptr{SCOTCH_Num}}(0)
    elements_weights_ptr = Ref{Ptr{SCOTCH_Num}}(0)
    nodes_weights_ptr    = Ref{Ptr{SCOTCH_Num}}(0)
    vertex_labels_ptr    = Ref{Ptr{SCOTCH_Num}}(0)
    adj_array_ptr        = Ref{Ptr{SCOTCH_Num}}(0)

    LibScotch.SCOTCH_meshData(mesh,
        base_element_index, base_node_index, n_elements, n_nodes,
        adj_idx_ptr, adj_idx_end_ptr, elements_weights_ptr, nodes_weights_ptr, vertex_labels_ptr,
        n_arcs, adj_array_ptr,
        max_vertex_degree
    )

    if adj_idx_end_ptr[] == adj_idx_ptr[] + 1
        adj_idx_end_ptr[] = C_NULL  # compact array
        adj_idx_len = n_elements[] + n_nodes[] + 1
    else
        adj_idx_len = n_elements[] + n_nodes[]
    end

    adj_idx          = adj_idx_ptr[]          == C_NULL ? nothing : unsafe_wrap(Vector{SCOTCH_Num}, adj_idx_ptr[],          adj_idx_len)
    adj_idx_end      = adj_idx_end_ptr[]      == C_NULL ? nothing : unsafe_wrap(Vector{SCOTCH_Num}, adj_idx_end_ptr[],      adj_idx_len)
    elements_weights = elements_weights_ptr[] == C_NULL ? nothing : unsafe_wrap(Vector{SCOTCH_Num}, elements_weights_ptr[], n_elements[])
    nodes_weights    = nodes_weights_ptr[]    == C_NULL ? nothing : unsafe_wrap(Vector{SCOTCH_Num}, nodes_weights_ptr[],    n_nodes[])
    vertex_labels    = vertex_labels_ptr[]    == C_NULL ? nothing : unsafe_wrap(Vector{SCOTCH_Num}, vertex_labels_ptr[],    n_elements[] + n_nodes[])
    adj_array        = adj_array_ptr[]        == C_NULL ? nothing : unsafe_wrap(Vector{SCOTCH_Num}, adj_array_ptr[],        n_arcs[])  # might be wrong?

    return (;
        base_element_index=base_element_index[], base_node_index=base_node_index[],
        n_elements=n_elements[], n_nodes=n_nodes[], n_arcs=n_arcs[], n_edges=n_arcs[] ÷ 2,
        adj_idx, adj_idx_end,
        elements_weights, nodes_weights, vertex_labels,
        adj_array,
        max_vertex_degree=max_vertex_degree[]
    )
end


"""
    mesh_load(file::IO; index_start=nothing)
    mesh_load(filename::AbstractString; kwargs...)

Load a new [`Mesh`](@ref) from `file` with `SCOTCH_meshLoad`.

If `index_start == nothing`, then the base indexing of the file is conserved.
"""
function mesh_load(file::IO; index_start=nothing)
    mesh = mesh_alloc()
    index_start = isnothing(index_start) ? -1 : index_start
    raw_file = Base.Libc.FILE(file)
    @check LibScotch.SCOTCH_meshLoad(mesh, raw_file, index_start)
    close(raw_file)
    return mesh
end


function mesh_load(filename::AbstractString; kwargs...)
    open(filename, "r") do file
        return mesh_load(file; kwargs...)
    end
end


"""
    save(mesh::Mesh, file::IO)

Save the `mesh` to `file` using `SCOTCH_meshSave`.
"""
function save(mesh::Mesh, file::IO)
    raw_file = Base.Libc.FILE(file)
    @check LibScotch.SCOTCH_meshSave(mesh, raw_file)
    close(raw_file)
end


"""
    mesh_graph(mesh::Mesh; dual=false, n_com=2)

Create a new [`Graph`](@ref) from the `mesh` using `SCOTCH_meshGraph`.

If `dual == true`, then `SCOTCH_meshGraphDual` is used instead, with `n_com` being the minimum number
of shared mesh elements for an edge to be created being two vertices.
"""
function mesh_graph(mesh::Mesh; dual=false, n_com=2)
    graph = graph_alloc()
    if dual
        @check LibScotch.SCOTCH_meshGraphDual(mesh, graph, n_com)
    else
        @check LibScotch.SCOTCH_meshGraph(mesh, graph)
    end
    return graph
end


"""
    mesh_size(mesh::Mesh)

Returns the number of `(; elements, nodes, edges)` for the `mesh`, using `SCOTCH_meshSize`.
"""
function mesh_size(mesh::Mesh)
    n_elements = Ref{SCOTCH_Num}()
    n_nodes = Ref{SCOTCH_Num}()
    n_edges = Ref{SCOTCH_Num}()
    LibScotch.SCOTCH_meshSize(mesh, n_elements, n_nodes, n_edges)
    return (; elements=n_elements[], nodes=n_nodes[], edges=n_edges[])
end


"""
    mesh_stat(mesh::Mesh)

Statistics about the `mesh`: returns `(; node_load, element_degree, node_degree)`.
Each value contains the following fields: `min`, `max`, `sum` (only for `node_load`), `avg` (average)
and `var` (standard deviation).
"""
function mesh_stat(mesh::Mesh)
    vnlomin = Ref{SCOTCH_Num}(0); vnlomax = Ref{SCOTCH_Num}(0); vnlosum = Ref{SCOTCH_Num}(0)
    edegmin = Ref{SCOTCH_Num}(0); edegmax = Ref{SCOTCH_Num}(0)
    ndegmin = Ref{SCOTCH_Num}(0); ndegmax = Ref{SCOTCH_Num}(0)
    vnloavg = Ref{Float64}(0.0);  vnlodlt = Ref{Float64}(0.0)
    edegavg = Ref{Float64}(0.0);  edegdlt = Ref{Float64}(0.0)
    ndegavg = Ref{Float64}(0.0);  ndegdlt = Ref{Float64}(0.0)
    LibScotch.SCOTCH_meshStat(mesh,
        vnlomin, vnlomax, vnlosum, vnloavg, vnlodlt,
        edegmin, edegmax, edegavg, edegdlt,
        ndegmin, ndegmax, ndegavg, ndegdlt
    )
    return (;
        node_load      = (; min=vnlomin[], max=vnlomax[], sum=vnlosum[], avg=vnloavg[], var=vnlodlt[]),
        element_degree = (; min=edegmin[], max=edegmax[],                avg=edegavg[], var=edegdlt[]),
        node_degree    = (; min=ndegmin[], max=ndegmax[],                avg=ndegavg[], var=ndegdlt[]),
    )
end


"""
    block_ordering(graph_or_mesh::Union{Graph, Mesh}, strat::Strat;
        permutation    ::Union{Bool, Nothing, Vector{SCOTCH_Num}}=nothing,
        inv_permutation::Union{Bool, Nothing, Vector{SCOTCH_Num}}=nothing,
        columns        ::Union{Bool, Nothing, Vector{SCOTCH_Num}}=nothing,
        separators_tree::Union{Bool, Nothing, Vector{SCOTCH_Num}}=nothing
    )

Compute a block ordering of the `graph` or `mesh` using `SCOTCH_graphOrder` or `SCOTCH_meshOrder`.
Returns `(permutation, inv_permutation, num_blocks, columns, separators_tree)`.

`permutation`, `inv_permutation`, `columns` or `separators_tree` can have 3 values each:
- `nothing`: converted to `C_NULL` and subsequantly ignored
- `true`: a new vector of the appropriate size is allocated and returned
- a `Vector{SCOTCH_Num}`: used and returned without allocation
"""
function block_ordering(graph_or_mesh::Union{Graph, Mesh}, strat::Strat;
    permutation    ::Union{Bool, Nothing, Vector{SCOTCH_Num}}=nothing,
    inv_permutation::Union{Bool, Nothing, Vector{SCOTCH_Num}}=nothing,
    columns        ::Union{Bool, Nothing, Vector{SCOTCH_Num}}=nothing,
    separators_tree::Union{Bool, Nothing, Vector{SCOTCH_Num}}=nothing
)
    alloc_or_not(::Nothing, _)  = C_NULL
    alloc_or_not(b::Bool, size) = b ? Vector{SCOTCH_Num}(undef, size) : C_NULL
    alloc_or_not(v::Vector, _)  = v

    num_v = if graph_or_mesh isa Mesh
        mesh_size(graph_or_mesh).nodes
    else
        graph_size(graph_or_mesh).vertices
    end

    permtab = alloc_or_not(permutation, num_v)
    peritab = alloc_or_not(inv_permutation, num_v)
    cblk = Ref{SCOTCH_Num}(0)
    rangtab = alloc_or_not(columns, num_v + 1)
    treetab = alloc_or_not(separators_tree, num_v)

    if graph_or_mesh isa Mesh
        @check LibScotch.SCOTCH_meshOrder(graph_or_mesh, strat, permtab, peritab, cblk, rangtab, treetab)
    else
        @check LibScotch.SCOTCH_graphOrder(graph_or_mesh, strat, permtab, peritab, cblk, rangtab, treetab)
    end

    return permtab, peritab, cblk[], rangtab, treetab
end
