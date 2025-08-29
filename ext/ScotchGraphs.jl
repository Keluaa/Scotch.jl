module ScotchGraphs

using Scotch
import Graphs

"""
    graph_build(
        graph::Graphs.AbstractGraph;
        edge_weights::Union{Bool, Nothing, AbstractMatrix}=false,
        vertex_weights::Union{Nothing, AbstractVector}=nothing,
        check=true,
    )

Convert any `Graphs.AbstractGraph` (e.g. `SimpleGraph`, `SimpleWeightedDiGraph`...) into
a `Scotch.Graph`.
Self edges are ignored.
Non-integer weights are *rounded to the nearest integer*.

If `edge_weights` is `true`, then `Graphs.weights(graph)` is used to get the edge weight matrix.
This supports all `SimpleGraph` and `SimpleWeightedGraph` (directed or undirected), as well as
graph weights defined by other packages.
`edge_weights` can also be the edge weight matrix directly.

When given, `vertex_weights` are the weights of each vertex, ordered the same way as for the
graph's vertices.

Note that while directed graphs are supported as input, SCOTCH does not support uni-directional edges.
All edges must be bi-directional with the same weight.

If `check` is `true`, then the converted graph is checked by SCOTCH.
Since not all `graph`s are accepted by SCOTCH, it is strongly recommended to keep it `true`.
"""
function Scotch.graph_build(
    graph::Graphs.AbstractGraph;
    edge_weights=false, vertex_weights::Union{Nothing, AbstractVector}=nothing,
    check=true,
)
    n_vertices = Graphs.nv(graph)
    n_edges    = Graphs.ne(graph) * (Graphs.is_directed(graph) ? 1 : 2)
    g_weights  = if edge_weights == true
        Graphs.weights(graph)
    elseif edge_weights isa AbstractMatrix
        edge_weights
    else
        nothing
    end

    if (n_vertices + 1) ≥ typemax(Scotch.SCOTCH_Num) || n_edges ≥ typemax(Scotch.SCOTCH_Num)
        error("graph is too large (", n_vertices, " vertices and ", n_edges, " edges) for SCOTCH")
    end

    # Compressed storage format of the graph for the grid. Same as for METIS.
    adj_index = Vector{Scotch.SCOTCH_Num}(undef, n_vertices + 1)
    adj_array = Vector{Scotch.SCOTCH_Num}(undef, n_edges)
    v_weights = !isnothing(vertex_weights) ? Vector{Scotch.SCOTCH_Num}(undef, n_vertices) : nothing
    e_weights = !isnothing(g_weights)      ? Vector{Scotch.SCOTCH_Num}(undef, n_edges)    : nothing

    adj_index[1] = 1
    adj_array_idx = 1
    for j in Graphs.vertices(graph)
        ne = 0
        for i in Graphs.outneighbors(graph, j)
            i == j && continue  # ignore self edges

            adj_array[adj_array_idx] = i
            if !isnothing(e_weights)
                e_weights[adj_array_idx] = g_weights[j, i]
                if g_weights[i, j] != g_weights[j, i]
                    error("SCOTCH does not support uni-directional/asymmetric edges: ", j => i)
                end
            end

            adj_array_idx += 1
            ne += 1
        end
        adj_index[j + 1] = adj_index[j] + ne

        if !isnothing(v_weights)
            v_weights[j] = vertex_weights[j]
        end
    end

    return Scotch.graph_build(adj_index, adj_array; index_start=1, v_weights, e_weights, check)
end


"""
    SimpleGraph(graph::Scotch.Graph)

Build a new `SimpleGraph` from a SCOTCH `graph`.
Edge and vertices weights are ignored.
"""
function Graphs.SimpleGraphs.SimpleGraph(s_graph::Scotch.Graph)
    s_data = Scotch.graph_data(s_graph)
    convert_index(i) = i - s_data.index_start + 1
    if isnothing(s_data.adj_idx) || isnothing(s_data.adj_array)
        error("cannot convert SCOTCH graph: edge data is inaccessible")
    end
    adj_idx::Vector{Scotch.SCOTCH_Num}   = s_data.adj_idx
    adj_array::Vector{Scotch.SCOTCH_Num} = s_data.adj_array

    graph = Graphs.SimpleGraph{Scotch.SCOTCH_Num}(s_data.n_vertices)
    for i in 1:s_data.n_vertices
        if isnothing(s_data.adj_idx_end)
            # Compact storage
            neighbor_range = convert_index(adj_idx[i]):convert_index(adj_idx[i + 1] - 1)
        else
            neighbor_range = convert_index(adj_idx[i]):convert_index(s_data.adj_idx_end[i] - 1)
        end
        neighbors = @view adj_array[neighbor_range]
        for j in neighbors
            j < i && continue  # skip edges which have already been added
            Graphs.add_edge!(graph, convert_index(i), convert_index(j))
        end
    end

    return graph
end

end

