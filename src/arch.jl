
mutable struct Arch
    ptr :: Ptr{LibScotch.SCOTCH_Arch}
end

Base.cconvert(::Type{Ptr{LibScotch.SCOTCH_Arch}}, arch::Arch) = arch.ptr
Base.cconvert(::Type{Ptr{Cvoid}}, a::Arch) = Ptr{Cvoid}(a.ptr)


function arch_alloc()
    arch = Arch(LibScotch.SCOTCH_archAlloc())
    @check LibScotch.SCOTCH_archInit(arch)
    finalizer(arch) do a
        LibScotch.SCOTCH_archExit(a)
        LibScotch.SCOTCH_memFree(a)
    end
    return arch
end


function arch_load(file::IOStream)
    arch = arch_alloc()
    fd_ptr = Ref(Cint(fd(file)))
    @check LibScotch.SCOTCH_archLoad(arch, fd_ptr)
    return arch
end


function arch_load(filename::AbstractString)
    return open(filename, "r") do file
        arch_load(file)
    end
end


function save(arch::Arch, file::IOStream)
    @check LibScotch.SCOTCH_archSave(arch, file)
    return arch
end


function arch_size(arch::Arch)
    return LibScotch.SCOTCH_archSize(arch)
end


function arch_name(arch::Arch)
    chars = LibScotch.SCOTCH_archName(arch)
    return unsafe_string(Base.unsafe_convert(Ptr{UInt8}, chars))
end


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

function arch_build(graph; restrain::Union{Vector{SCOTCH_Num}, Nothing}=nothing)
    return arch_build(graph, nothing, :deco_2, restrain)
end

function arch_build(graph, strat::Strat; target=:default, restrain::Union{Vector{SCOTCH_Num}, Nothing}=nothing)
    return arch_build(graph, strat, target, restrain)
end


function arch_complete_graph(n_vertices; weights::Union{Vector{SCOTCH_Num}, Nothing}=nothing, variable=false)
    arch = arch_alloc()
    if isnothing(weights)
        @check LibScotch.SCOTCH_archCmplt(arch, n_vertices)
    else
        @check LibScotch.SCOTCH_archCmpltw(arch, n_vertices, weights)
    end
    variable && @check LibScotch.SCOTCH_archVcmplt(arch)
    return arch
end


function arch_hypercube(dim; variable=false)
    arch = arch_alloc()
    @check LibScotch.SCOTCH_archHcub(arch, dim)
    variable && @check LibScotch.SCOTCH_archVhcub(arch)
    return arch
end


function arch_mesh(dimensions::Vector{SCOTCH_Num})
    arch = arch_alloc()
    @check LibScotch.SCOTCH_archMeshX(arch, length(dimensions), dimensions)
    return arch
end


function arch_torus(dimensions::Vector{SCOTCH_Num})
    arch = arch_alloc()
    @check LibScotch.SCOTCH_archTorusX(arch, length(dimensions), dimensions)
    return arch
end


function arch_tree(levels::Vector{SCOTCH_Num}, link_cost::Vector{SCOTCH_Num})
    arch = arch_alloc()
    @check LibScotch.SCOTCH_archTleaf(arch, length(levels), levels, link_cost)
    return arch
end


function arch_subset(arch::Arch, processors::Vector{SCOTCH_Num})
    sub_arch = arch_alloc()
    @check LibScotch.SCOTCH_archSub(sub_arch, arch, length(processors), processors)
    return sub_arch
end


# TODO: target domain handling routines (section 8.6)
