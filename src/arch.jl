
"""
    Arch

Wrapper around a `SCOTCH_Arch` pointer.
"""
mutable struct Arch
    ptr :: Ptr{LibScotch.SCOTCH_Arch}
    parent :: Union{Nothing, Arch}
end

Base.cconvert(::Type{Ptr{LibScotch.SCOTCH_Arch}}, arch::Arch) = arch.ptr
Base.cconvert(::Type{Ptr{Cvoid}}, a::Arch) = Ptr{Cvoid}(a.ptr)


"""
    arch_alloc()

Allocate a new [`Arch`](@ref) with `SCOTCH_archAlloc`, then initialize it with `SCOTCH_archInit`.

Finalizers will properly call `SCOTCH_archExit` then `SCOTCH_memFree` once unused.
"""
function arch_alloc()
    arch = Arch(LibScotch.SCOTCH_archAlloc(), nothing)
    @check LibScotch.SCOTCH_archInit(arch)
    finalizer(arch) do a
        LibScotch.SCOTCH_archExit(a)
        LibScotch.SCOTCH_memFree(a)
    end
    return arch
end


"""
    arch_load(filename::AbstractString)    
    arch_load(file::IO)

Load a new [`Arch`](@ref) from the given file. See `SCOTCH_archLoad`.
"""
function arch_load(file::IO)
    arch = arch_alloc()
    raw_file = Base.Libc.FILE(file)
    @check LibScotch.SCOTCH_archLoad(arch, raw_file)
    close(raw_file)
    return arch
end


function arch_load(filename::AbstractString)
    return open(filename, "r") do file
        arch_load(file)
    end
end


"""
    save(arch::Arch, file::IO)

Save the `arch` to `file` using `SCOTCH_archSave`.
"""
function save(arch::Arch, file::IO)
    raw_file = Base.Libc.FILE(file)
    @check LibScotch.SCOTCH_archSave(arch, raw_file)
    close(raw_file)
    return arch
end


"""
    arch_size(arch::Arch)

Number of nodes in `arch`. See `SCOTCH_archSize`.
"""
function arch_size(arch::Arch)
    return LibScotch.SCOTCH_archSize(arch)
end


"""
    arch_name(arch::Arch)

Name of `arch`. See `SCOTCH_archName`.
"""
function arch_name(arch::Arch)
    chars = LibScotch.SCOTCH_archName(arch)
    return unsafe_string(Base.unsafe_convert(Ptr{UInt8}, chars))
end


"""
    is_arch_variable(arch::Arch)

`true` if `arch` has a variable size.
"""
is_arch_variable(arch::Arch) = LibScotch.SCOTCH_archVar(arch) == 1


function arch_build(graph, strat::Union{Strat, Nothing}, target::Symbol, restrain::Union{Vector{SCOTCH_Num}, Nothing})
    arch = arch_alloc()

    listnbr = isnothing(restrain) ? 0 : length(restrain)
    listptr = isnothing(restrain) ? C_NULL : pointer(restrain)

    if target === :default
        @check LibScotch.SCOTCH_archBuild(arch, graph, listnbr, listptr, strat::Strat)
    elseif target === :deco_1
        @check LibScotch.SCOTCH_archBuild0(arch, graph, listnbr, listptr, strat::Strat)
    elseif target === :deco_2
        @check LibScotch.SCOTCH_archBuild2(arch, graph, listnbr, listptr)
    else
        throw(ArgumentError("unknown target: $target"))
    end

    return arch
end


"""
    arch_build(graph::Graph; restrain=nothing)

Allocate and initialize a new [`Arch`](@ref) with `SCOTCH_archBuild2`.

`restrain` may be a `Vector{SCOTCH_Num}` of indices of graph nodes.
"""
function arch_build(graph; restrain::Union{Vector{SCOTCH_Num}, Nothing}=nothing)
    return arch_build(graph, nothing, :deco_2, restrain)
end


"""
    arch_build(graph::Graph, strat::Strat; target=:default, restrain=nothing)

Allocate and initialize a new [`Arch`](@ref) using `strat`egy for the given `target`:
- `:default` uses `SCOTCH_archBuild`
- `:deco_1` uses `SCOTCH_archBuild0`
- `:deco_2` uses `SCOTCH_archBuild2`

`restrain` may be a `Vector{SCOTCH_Num}` of indices of graph nodes.
"""
function arch_build(graph, strat::Strat; target=:default, restrain::Union{Vector{SCOTCH_Num}, Nothing}=nothing)
    return arch_build(graph, strat, target, restrain)
end


"""
    arch_complete_graph(n_vertices; weights=nothing, variable=false)

Allocate and initialize a new [`Arch`](@ref) for a complete graph topology with `SCOTCH_archCmplt`,
`SCOTCH_archCmpltw` or `SCOTCH_archVcmplt`.
"""
function arch_complete_graph(n_vertices; weights::Union{Vector{SCOTCH_Num}, Nothing}=nothing, variable=false)
    arch = arch_alloc()
    if isnothing(weights)
        @check LibScotch.SCOTCH_archCmplt(arch, n_vertices)
    else
        if length(weights) != n_vertices
            error("expected weights array to have $n_vertices elements, got: $(length(weights))")
        end
        @check LibScotch.SCOTCH_archCmpltw(arch, n_vertices, weights)
    end
    variable && @check LibScotch.SCOTCH_archVcmplt(arch)
    return arch
end


"""
    arch_hypercube(dim; variable=false)

Allocate and initialize a new [`Arch`](@ref) for a hypercube topology with `SCOTCH_archHcub` or
`SCOTCH_archVhcub`.
"""
function arch_hypercube(dim; variable=false)
    arch = arch_alloc()
    @check LibScotch.SCOTCH_archHcub(arch, dim)
    variable && @check LibScotch.SCOTCH_archVhcub(arch)
    return arch
end


"""
    arch_mesh(dimensions::Vector{SCOTCH_Num})

Allocate and initialize a new [`Arch`](@ref) for a mesh topology with `SCOTCH_archMeshX`.
"""
function arch_mesh(dimensions::Vector{SCOTCH_Num})
    arch = arch_alloc()
    @check LibScotch.SCOTCH_archMeshX(arch, length(dimensions), dimensions)
    return arch
end


"""
    arch_torus(dimensions::Vector{SCOTCH_Num})

Allocate and initialize a new [`Arch`](@ref) for a torus topology with `SCOTCH_archTorusX`.
"""
function arch_torus(dimensions::Vector{SCOTCH_Num})
    arch = arch_alloc()
    @check LibScotch.SCOTCH_archTorusX(arch, length(dimensions), dimensions)
    return arch
end


"""
    arch_tree(levels::Vector{SCOTCH_Num}, link_cost::Vector{SCOTCH_Num})

Allocate and initialize a new [`Arch`](@ref) for a tree topology with `SCOTCH_archTleaf`.

The tree has `length(levels)` levels (excluding the leafs), each of them with `levels[i]` children
per level node, and a link cost to the parent node of `link_cost[i]`.
"""
function arch_tree(levels::Vector{SCOTCH_Num}, link_cost::Vector{SCOTCH_Num})
    arch = arch_alloc()
    @check LibScotch.SCOTCH_archTleaf(arch, length(levels), levels, link_cost)
    return arch
end


"""
    arch_subset(arch::Arch, processors::Vector{SCOTCH_Num}; one_index=true)

Allocate and initialize a new [`Arch`](@ref) from a subset of `arch` including `processors` with `SCOTCH_archSub`.

If `one_index == true`, `processors` are 1-based indices to the processors in the parent `arch`,
otherwise they are 0-based and no conversion is done.

The resulting `sub_arch` keeps a reference to the parent `arch`, to prevent it from being deallocated.
"""
function arch_subset(arch::Arch, processors::Vector{SCOTCH_Num}; one_index=true)
    sub_arch = arch_alloc()
    processors_indices = one_index ? (processors .- SCOTCH_Num(1)) : processors
    @check LibScotch.SCOTCH_archSub(sub_arch, arch, length(processors), processors_indices)
    sub_arch.parent = arch
    return sub_arch
end


# TODO: target domain handling routines (section 8.6)
# TODO: SCOTCH_archLtleaf is unexported in 7.0.4
