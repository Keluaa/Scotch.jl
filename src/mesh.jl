
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


function mesh_build(adj_index::Vector{SCOTCH_Num}, adj_array::Vector{SCOTCH_Num}, elem_count, node_count;
    index_start_element=1, index_start_node=1, check=true,
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
        length(adj_array), adj_array
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


function mesh_load(file::IOStream; index_start=nothing)
    mesh = mesh_alloc()
    index_start = isnothing(index_start) ? -1 : index_start
    @check LibScotch.SCOTCH_meshLoad(mesh, file, index_start)
    return mesh
end


function save(mesh::Mesh, file::IOStream)
    @check LibScotch.SCOTCH_meshSave(mesh, file)
end


function mesh_graph(mesh::Mesh; dual=false, n_com=2)
    graph = graph_alloc()
    if dual
        @check LibScotch.SCOTCH_meshGraphDual(mesh, graph, n_com)
    else
        @check LibScotch.SCOTCH_meshGraph(mesh, graph)
    end
    return graph
end


function mesh_size(mesh::Mesh)
    n_elements = Ref{SCOTCH_Num}()
    n_nodes = Ref{SCOTCH_Num}()
    n_edges = Ref{SCOTCH_Num}()
    @check LibScotch.SCOTCH_meshSize(mesh, n_elements, n_nodes, n_edges)
    return (; elements=n_elements[], nodes=n_nodes[], edges=n_edges[])
end


function mesh_stat(mesh::Mesh)
    vnlomin = Ref{SCOTCH_Num}(0); vnlomax = Ref{SCOTCH_Num}(0); vnlosum = Ref{SCOTCH_Num}(0)
    edegmin = Ref{SCOTCH_Num}(0); edegmax = Ref{SCOTCH_Num}(0)
    ndegmin = Ref{SCOTCH_Num}(0); ndegmax = Ref{SCOTCH_Num}(0)
    vnloavg = Ref{Float64}(0.0);  vnlodlt = Ref{Float64}(0.0)
    edegavg = Ref{Float64}(0.0);  edegdlt = Ref{Float64}(0.0)
    ndegavg = Ref{Float64}(0.0);  ndegdlt = Ref{Float64}(0.0)
    @check LibScotch.SCOTCH_meshStat(mesh,
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


function mesh_order(mesh::Mesh, strat::Strat;
    permutation    ::Union{Bool, Nothing, Vector{SCOTCH_Num}}=nothing,
    inv_permutation::Union{Bool, Nothing, Vector{SCOTCH_Num}}=nothing,
    columns        ::Union{Bool, Nothing, Vector{SCOTCH_Num}}=nothing,
    separators_tree::Union{Bool, Nothing, Vector{SCOTCH_Num}}=nothing
)
    alloc_or_not(::Nothing, _)  = C_NULL
    alloc_or_not(b::Bool, size) = b ? Vector{SCOTCH_Num}(undef, size) : C_NULL
    alloc_or_not(v::Vector, _)  = v

    (; nodes) = mesh_size(mesh)

    permtab = alloc_or_not(permutation, nodes)
    peritab = alloc_or_not(inv_permutation, nodes)
    cblk = Ref{SCOTCH_Num}(0)
    rangtab = alloc_or_not(columns, nodes + 1)
    treetab = alloc_or_not(separators_tree, nodes)

    @check LibScotch.SCOTCH_meshOrder(mesh, strat, permtab, peritab, cblk, rangtab, treetab)

    return permtab, peritab, cblk[], rangtab, treetab
end
