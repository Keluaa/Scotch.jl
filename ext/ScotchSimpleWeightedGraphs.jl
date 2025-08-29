module ScotchSimpleWeightedGraphs

using Scotch
import Graphs
import SimpleWeightedGraphs

"""
    SimpleWeightedGraph(graph::Scotch.Graph)

Build a new `SimpleWeightedGraph` from a SCOTCH `graph`.

Vertices weights are ignored. Retrieve them manually with `Scotch.graph_data(graph).vertices_weights`.
"""
function SimpleWeightedGraphs.SimpleWeightedGraph(s_graph::Scotch.Graph)
    s_data = Scotch.graph_data(s_graph)
    convert_index(i) = i - s_data.index_start + 1
    if isnothing(s_data.adj_idx) || isnothing(s_data.adj_array)
        error("cannot convert SCOTCH graph: edge data is inaccessible")
    end
    adj_idx::Vector{Scotch.SCOTCH_Num}   = s_data.adj_idx
    adj_array::Vector{Scotch.SCOTCH_Num} = s_data.adj_array

    graph = SimpleWeightedGraphs.SimpleWeightedGraph{Scotch.SCOTCH_Num, Scotch.SCOTCH_Num}(s_data.n_vertices)
    edge_t = SimpleWeightedGraphs.SimpleWeightedGraphEdge{Scotch.SCOTCH_Num, Scotch.SCOTCH_Num}
    if isnothing(s_data.arcs_weights)
        # Consider all edges to have a weight of 1 by default
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
                Graphs.add_edge!(graph, edge_t(convert_index(i), convert_index(j), one(Scotch.SCOTCH_Num)))
            end
        end
    else
        for i in 1:s_data.n_vertices
            if isnothing(s_data.adj_idx_end)
                # Compact storage
                neighbor_range = convert_index(adj_idx[i]):convert_index(adj_idx[i + 1] - 1)
            else
                neighbor_range = convert_index(adj_idx[i]):convert_index(s_data.adj_idx_end[i] - 1)
            end
            neighbors = @view adj_array[neighbor_range]
            weights   = @view s_data.arcs_weights[neighbor_range]
            for (j, w) in zip(neighbors, weights)
                j < i && continue  # skip edges which have already been added
                Graphs.add_edge!(graph, edge_t(convert_index(i), convert_index(j), w))
            end
        end
    end

    return graph
end

end

