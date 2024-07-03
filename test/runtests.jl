using Scotch
using Test
using Aqua

@testset "Scotch.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(Scotch)
    end

    @show Scotch.version()
    @show Scotch.LibScotch.SCOTCH_jll.libscotch
    @test Scotch.version() == VersionNumber(Scotch.LibScotch.SCOTCH_VERSION, Scotch.LibScotch.SCOTCH_RELEASE, Scotch.LibScotch.SCOTCH_PATCHLEVEL)

    @testset "Strat" begin
        map_strat = Scotch.strat_build(:graph_map; strategy=:default, parts=4, imbalance_ratio=0.05, remap=true)
        mktemp() do tmp_path, io
            Scotch.save(map_strat, io)
            close(io)
            strat_str = readchomp(tmp_path)
            Scotch.strat(:graph_map, strat_str)
        end
    end

    @testset "Arch" begin
        arch_cg4 = Scotch.arch_complete_graph(4)
        arch_cg4_2 = mktemp() do tmp_path, io
            Scotch.save(arch_cg4, io)
            close(io)
            Scotch.arch_load(tmp_path)
        end
        @test Scotch.arch_name(arch_cg4) == Scotch.arch_name(arch_cg4_2) == "cmplt"
        @test Scotch.arch_size(arch_cg4) == Scotch.arch_size(arch_cg4_2) == 4

        arch_cg6w = Scotch.arch_complete_graph(6; weights=Int32[1, 5, 1, 2, 3, 6])
        @test Scotch.arch_name(arch_cg6w) == "cmpltw"
        @test Scotch.arch_size(arch_cg6w) == 6
        @test !Scotch.is_arch_variable(arch_cg6w)

        arch_hc2 = Scotch.arch_hypercube(2)
        @test Scotch.arch_name(arch_hc2) == "hcub"
        @test Scotch.arch_size(arch_hc2) == 4

        arch_vhc3 = Scotch.arch_hypercube(3; variable=true)
        @test Scotch.arch_name(arch_vhc3) == "varhcub"
        @test Scotch.arch_size(arch_vhc3) == 1
        @test Scotch.is_arch_variable(arch_vhc3)

        arch_mesh = Scotch.arch_mesh(Int32[5, 3])
        @test Scotch.arch_name(arch_mesh) == "meshXD"
        @test Scotch.arch_size(arch_mesh) == 5*3

        # torus and mesh are the same, but torus has periodic boundaries
        arch_torus = Scotch.arch_torus(Int32[5, 3])
        @test Scotch.arch_name(arch_torus) == "torusXD"
        @test Scotch.arch_size(arch_torus) == 5*3

        arch_tree = Scotch.arch_tree(Int32[3, 2, 2], Int32[20, 7, 2])  # Tree example in section 6.4.2
        @test Scotch.arch_name(arch_tree) == "tleaf"
        @test Scotch.arch_size(arch_tree) == 3*2*2

        sub_arch = Scotch.arch_subset(arch_tree, Int32[1, 2, 3])
        @test Scotch.arch_name(sub_arch) == "sub"
        @test Scotch.arch_size(sub_arch) == 3

        @testset "Arch from graph" begin
            grid_3x3 = open(joinpath(@__DIR__, "3x3_grid.grf"), "r") do file
                Scotch.graph_load(file)
            end

            @test Scotch.graph_base_index(grid_3x3) == 1
            Scotch.graph_base_index!(grid_3x3, 0)
            @test Scotch.graph_base_index(grid_3x3) == 0

            arch_graph = Scotch.arch_build(grid_3x3)
            @test Scotch.arch_name(arch_graph) == "deco"
            @test Scotch.arch_size(arch_graph) == 9

            strat = Scotch.strat_build(:implicit)
            arch_graph_d  = Scotch.arch_build(grid_3x3, strat; target=:default)
            arch_graph_d1 = Scotch.arch_build(grid_3x3, strat; target=:deco_1)
            @test Scotch.arch_name(arch_graph_d1) == Scotch.arch_name(arch_graph_d) == "deco"
            @test Scotch.arch_size(arch_graph_d1) == Scotch.arch_size(arch_graph_d) == 9
        end
    end

    @testset "Graph" begin
        grid_3x3 = open(joinpath(@__DIR__, "3x3_grid.grf"), "r") do file
            Scotch.graph_load(file)
        end

        @test Tuple(Scotch.graph_size(grid_3x3)) == (9, 24)
        @test Scotch.graph_diameter(grid_3x3) == 4
        @test Scotch.graph_base_index(grid_3x3) == 1

        mktemp() do tmp_path, io
            Scotch.save(grid_3x3, io)
            close(io)
            @test readchomp(tmp_path) == readchomp(joinpath(@__DIR__, "3x3_grid.grf"))
        end

        grid_data = Scotch.graph_data(grid_3x3)
        @test grid_data.index_start == 1
        @test grid_data.n_vertices == 9
        @test grid_data.n_arcs == 24
        @test grid_data.n_edges == 12
        @test length(grid_data.adj_idx) == 9
        @test length(grid_data.adj_idx_end) == 9
        @test isnothing(grid_data.vertices_weights)
        @test isnothing(grid_data.vertices_labels)
        @test length(grid_data.adj_array) == 24
        @test isnothing(grid_data.arcs_weights)

        grid_copy = Scotch.graph_build(deepcopy(grid_data.adj_idx), deepcopy(grid_data.adj_array); adj_idx_end=deepcopy(grid_data.adj_idx_end))
        @test Tuple(Scotch.graph_size(grid_copy)) == (9, 24)

        # Graph coloring relies on randomness, we must use a fixed seed
        Scotch.random_seed(0)
        Scotch.random_reset()
        n_colors, colors = Scotch.graph_color(grid_3x3)
        @test length(colors) == 9
        @test n_colors == 5

        map_arch = Scotch.arch_complete_graph(4)
        map_strat = Scotch.strat_build(:graph_map; strategy=:default, parts=4, imbalance_ratio=1/9)
        mapping = Scotch.graph_map(grid_3x3, map_arch, map_strat)
        @test length(mapping) == 9
        parts = map(p -> findall(==(p), mapping), 0:3)
        @test sum(length.(parts)) == 9
        @test count(==(2) ∘ length, parts) == 3
        @test count(==(3) ∘ length, parts) == 1
        @test minimum(mapping) == 0

        # Redo the mapping for the first 3 vertices
        mapping[1:3] .= -1
        Scotch.graph_map(grid_3x3, map_arch, map_strat; partition=mapping, fixed=true)
        new_parts = map(p -> findall(==(p), mapping), 0:3)
        @test sum(length.(parts)) == 9
        @test count(==(2) ∘ length, parts) == 3
        @test count(==(3) ∘ length, parts) == 1
        @test minimum(mapping) == 0

        # Weighted remapping
        costs = zeros(Scotch.SCOTCH_Num, 9)
        costs[3:6] .= 1  # middle 3 vertices
        weighted_mapping = Scotch.graph_remap(grid_3x3, map_arch, mapping, 1.0, costs, map_strat)
        @test weighted_mapping != mapping

        prev_col = (weighted_mapping[1:3:end] .= -1)  # fix the first column
        Scotch.graph_remap(grid_3x3, map_arch, mapping, 1.0, costs, map_strat; partition=mapping, fixed=true)
        @test prev_col == weighted_mapping[1:3:end]

        stats = Scotch.graph_stat(grid_3x3)
        @test stats.vertex_load.min == stats.vertex_load.max == stats.vertex_load.avg == 1
        @test stats.edge_load.min   == stats.edge_load.max   == stats.edge_load.avg   == 1
        @test stats.vertex_degree.min == 2
        @test stats.vertex_degree.max == 4

        coarse_graph, multi_nodes_map = Scotch.graph_coarsen(grid_3x3, 6, 2/3)
        @test coarse_graph !== nothing !== multi_nodes_map
        coarsened_count = count(multi_nodes_map[1:2:end] .!= multi_nodes_map[2:2:end])
        @test Scotch.graph_size(coarse_graph).vertices == Scotch.graph_size(grid_3x3).vertices - coarsened_count

        @warn "Two-step coarsening tests disabled" maxlog=1
        # coarse_vertex_count, mates = Scotch.graph_coarsen_match(grid_3x3, 6, 2/3)
        # @test coarse_vertex_count ≤ 6
        # coarse_graph, multi_nodes_map = Scotch.graph_coarsen(grid_3x3, 6, 2/3; fine_mates=mates)

        # @test coarse_graph !== nothing !== multi_nodes_map
        # coarsened_count = count(multi_nodes_map[1:2:end] .!= multi_nodes_map[2:2:end])
        # @test coarse_vertex_count == coarse_vertex_count
        # @test Scotch.graph_size(coarse_graph).vertices == 6

        # Make a + shape by removing the corners
        cross_graph = Scotch.graph_induce(grid_3x3, Int32[2, 4, 5, 6, 8])
        @test Scotch.graph_size(cross_graph) == (; vertices=5, edges=4*2)
        @test Scotch.graph_diameter(cross_graph) == 2

        # Same thing, other method
        cross_part = Scotch.SCOTCH_GraphPart2[
            0, 1, 0,
            1, 1, 1,
            0, 1, 0
        ]
        cross_graph = Scotch.graph_induce(grid_3x3, cross_part, Scotch.SCOTCH_GraphPart2(1))
        @test Scotch.graph_size(cross_graph) == (; vertices=5, edges=4*2)
        @test Scotch.graph_diameter(cross_graph) == 2

        # Partitionning
        part_strat = Scotch.strat_build(:implicit)
        partition = Scotch.graph_part(grid_3x3, 3, part_strat)
        @test extrema(partition) == (0, 2)
        parts = map(p -> findall(==(p), partition), 0:2)
        @test sum(length.(parts)) == 9
        @test length(parts) == 3

        @warn "Repartitionning tests disabled" maxlog=1
        # Repartitionning: remove the last partition
        # costs = Scotch.SCOTCH_Num.(partition .== 2)
        # partition[partition .== 2] .= -1
        # new_partition = Scotch.graph_repart(grid_3x3, 2, partition, 1.0, costs, part_strat)
        # @test extrema(new_partition) == (0, 1)
        # parts = map(p -> findall(==(p), new_partition), 0:1)
        # @test sum(length.(parts)) == 9
        # @test length(parts) == 2
    end

    @testset "Mesh" begin
        tri_mesh = Scotch.mesh_load(joinpath(@__DIR__, "triangles.msh"))

        @test Tuple(Scotch.mesh_size(tri_mesh)) == (4, 6, 24)

        mktemp() do tmp_path, io
            Scotch.save(tri_mesh, io)
            close(io)
            @test readchomp(tmp_path) == readchomp(joinpath(@__DIR__, "triangles.msh"))
        end

        tri_msh_idx = Scotch.SCOTCH_Num[1, 2, 5, 8, 9, 12, 13, 16, 19, 22, 25]
        tri_msh_adj = Scotch.SCOTCH_Num[7, 7, 8, 9, 7, 8, 10, 9, 9, 10, 8, 10, 1, 2, 3, 5, 2, 3, 4, 5, 2, 3, 6, 5]
        tri_mesh_manual = Scotch.mesh_build(tri_msh_idx, tri_msh_adj, 4, 6;
            index_start_element=7, index_start_node=1, arc_count=24
        )

        mktemp() do tmp_path, io
            Scotch.save(tri_mesh_manual, io)
            close(io)
            @test readchomp(tmp_path) == readchomp(joinpath(@__DIR__, "triangles.msh"))
        end

        mesh_data = Scotch.mesh_data(tri_mesh_manual)
        @test mesh_data.base_element_index == 7
        @test mesh_data.base_node_index == 1
        @test mesh_data.n_elements == 4
        @test mesh_data.n_nodes == 6
        @test mesh_data.n_arcs == 24
        @test mesh_data.n_edges == 12
        @test mesh_data.max_vertex_degree == 3
        @test pointer(mesh_data.adj_idx) == pointer(tri_msh_idx)
        @test length(mesh_data.adj_idx)  == length(tri_msh_idx) - 1
        @test length(mesh_data.adj_idx_end) == length(tri_msh_idx) - 1  # converted to non-compact
        @test isnothing(mesh_data.elements_weights)
        @test isnothing(mesh_data.nodes_weights)
        @test isnothing(mesh_data.vertex_labels)
        @test pointer(mesh_data.adj_array) == pointer(tri_msh_adj)
        @test length(mesh_data.adj_array)  == length(tri_msh_adj)

        stats = Scotch.mesh_stat(tri_mesh)
        @test stats.node_load.min      == stats.node_load.max      == stats.node_load.avg      == 1
        @test stats.element_degree.min == stats.element_degree.max == stats.element_degree.avg == 3
        @test stats.node_degree.min == 1
        @test stats.node_degree.max == 3

        tri_mesh_graph = Scotch.mesh_graph(tri_mesh; dual=true)  # graph of the element topology
        @test Tuple(Scotch.graph_size(tri_mesh_graph)) == (4, 6)
        @test Scotch.graph_diameter(tri_mesh_graph) == 2
    end

    @testset "Context" begin
        ctx = Scotch.context_alloc()

        Scotch.context_option!(ctx, :deterministic, true)
        @test Scotch.context_option(ctx, :deterministic) == 1

        Scotch.context_option!(ctx, :fixed_seed, true)
        @test Scotch.context_option(ctx, :fixed_seed) == 1

        graph = Scotch.graph_load(joinpath(@__DIR__, "3x3_grid.grf"))
        ctx_graph = Scotch.bind_graph(ctx, graph)

        map_arch = Scotch.arch_complete_graph(4)
        map_strat = Scotch.strat_build(:graph_map; strategy=:default, parts=4, imbalance_ratio=1/9)

        Scotch.random_seed(ctx, 42)
        Scotch.random_reset(ctx)
        mapping_1 = Scotch.graph_map(ctx_graph, map_arch, map_strat)

        Scotch.random_seed(ctx, 42)
        Scotch.random_reset(ctx)
        mapping_2 = Scotch.graph_map(ctx_graph, map_arch, map_strat)
        @test mapping_1 == mapping_2
    end
end
