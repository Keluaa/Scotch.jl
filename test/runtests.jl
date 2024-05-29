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

        n_colors, colors = Scotch.graph_color(grid_3x3)
        @test length(colors) == 9
        @test n_colors == 5

        map_arch = Scotch.arch_complete_graph(4)
        map_strat = Scotch.strat_build(:graph_map; strategy=:default, parts=4, imbalance_ratio=1/9)
        mapping = Scotch.graph_map(grid_3x3, map_arch, map_strat)
        @test length(mapping) == 9
        parts = map(p -> findall(==(p), mapping), 1:4)
        @test sum(length.(parts)) == 9
        @test count(==(2) ∘ length, parts) == 3
        @test count(==(3) ∘ length, parts) == 1
        @test minimum(mapping) == grid_data.index_start

        stats = Scotch.graph_stat(grid_3x3)
        @test stats.vertex_load.min == stats.vertex_load.max == stats.vertex_load.avg == 1
        @test stats.edge_load.min   == stats.edge_load.max   == stats.edge_load.avg   == 1
        @test stats.vertex_degree.min == 2
        @test stats.vertex_degree.max == 4
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

        Scotch.random_seed(ctx, 42)
        Scotch.random_reset(ctx)

        graph = Scotch.graph_load(joinpath(@__DIR__, "3x3_grid.grf"))
        ctx_graph = Scotch.bind_graph(ctx, graph)

        map_arch = Scotch.arch_complete_graph(4)
        map_strat = Scotch.strat_build(:graph_map; strategy=:default, parts=4, imbalance_ratio=1/9)
        mapping = Scotch.graph_map(ctx_graph, map_arch, map_strat)
        @test mapping == Int32[4, 3, 1, 4, 3, 1, 4, 2, 2]
    end
end
