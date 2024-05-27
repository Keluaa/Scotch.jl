
random_proc(proc) = LibScotch.SCOTCH_randomProc(proc)
random_val(max=typemax(SCOTCH_Num)) = LibScotch.SCOTCH_randomVal(max)


"""
    random_seed(seed)

Sets the global RNG seed using `SCOTCH_randomSeed`.
"""
random_seed(seed) = LibScotch.SCOTCH_randomSeed(seed)


"""
    random_reset()

Resets the global RNG seed using `SCOTCH_randomReset`.
"""
random_reset() = LibScotch.SCOTCH_randomReset()


"""
    Context

Wrapper around a `SCOTCH_Context` pointer.
"""
mutable struct Context
    ptr :: Ptr{LibScotch.SCOTCH_Context}
end

Base.cconvert(::Type{Ptr{LibScotch.SCOTCH_Context}}, c::Context) = c.ptr
Base.cconvert(::Type{Ptr{Cvoid}}, c::Context) = Ptr{Cvoid}(c.ptr)


"""
    context_alloc()

Allocate a new [`Context`](@ref) with `SCOTCH_contextAlloc`, then initialize it with `SCOTCH_contextInit`.

Finalizers will properly call `SCOTCH_contextExit` then `SCOTCH_memFree` once unused.
"""
function context_alloc()
    ctx_ptr = LibScotch.SCOTCH_contextAlloc()
    ctx = Context(ctx_ptr)
    @check LibScotch.SCOTCH_contextInit(ctx)
    finalizer(ctx) do c
        LibScotch.SCOTCH_contextExit(c)
        LibScotch.SCOTCH_memFree(c)
    end
    return ctx
end


"""
    random_clone(ctx::Context)

Clone the global RNG state into `ctx` using `SCOTCH_contextRandomClone`.
"""
random_clone(ctx::Context) = LibScotch.SCOTCH_contextRandomClone(ctx)


"""
    random_seed(ctx::Context, seed)

Set the RNG seed of `ctx` using `SCOTCH_contextRandomSeed`.
"""
random_seed(ctx::Context, seed) = LibScotch.SCOTCH_contextRandomSeed(ctx, seed)


"""
    random_reset(ctx::Context)

Resets the RNG of `ctx` using `SCOTCH_contextRandomReset`.
"""
random_reset(ctx::Context) = LibScotch.SCOTCH_contextRandomReset(ctx)


function context_option(ctx::Context, option::Integer)
    option_val = Ref{SCOTCH_Num}(0)
    @check LibScotch.SCOTCH_contextOptionGetNum(ctx, option, option_val)
    return option_val[]
end


"""
    context_option(ctx::Context, option::Symbol)

Get the `option` for `ctx` to `value` using `SCOTCH_contextOptionGetNum`.

`option` can be:
- `:deterministic` for `SCOTCH_OPTIONNUMDETERMINISTIC`
- `:fixed_seed` for `SCOTCH_OPTIONNUMRANDOMFIXEDSEED`
"""
function context_option(ctx::Context, option::Symbol)
    option_i = if option === :deterministic
        LibScotch.SCOTCH_OPTIONNUMDETERMINISTIC
    elseif option === :fixed_seed
        LibScotch.SCOTCH_OPTIONNUMRANDOMFIXEDSEED
    else
        error("unknown option: $option")
    end
    return context_option(ctx, option_i)
end


function context_option!(ctx::Context, option::Integer, value)
    @check LibScotch.SCOTCH_contextOptionSetNum(ctx, option, value)
end


"""
    context_option!(ctx::Context, option::Symbol, value::Bool)

Set the `option` for `ctx` to `value` using `SCOTCH_contextOptionSetNum`.

`option` can be:
- `:deterministic` for `SCOTCH_OPTIONNUMDETERMINISTIC`
- `:fixed_seed` for `SCOTCH_OPTIONNUMRANDOMFIXEDSEED`
"""
function context_option!(ctx::Context, option::Symbol, value::Bool)
    option_i = if option === :deterministic
        LibScotch.SCOTCH_OPTIONNUMDETERMINISTIC
    elseif option === :fixed_seed
        LibScotch.SCOTCH_OPTIONNUMRANDOMFIXEDSEED
    else
        error("unknown option: $option")
    end
    return context_option!(ctx, option_i, value)
end


"""
    bind_graph(ctx::Context, graph::Graph)

Create a new [`Graph`](@ref) from `graph` bound to `ctx` using `SCOTCH_contextBindGraph`.
"""
function bind_graph(ctx::Context, graph::Graph)
    ctx_graph = graph_alloc()
    @check LibScotch.SCOTCH_contextBindGraph(ctx, graph, ctx_graph)
    ctx_graph.ctx = ctx
    return ctx_graph
end


"""
    bind_graph(ctx::Context, mesh::Mesh)

Create a new [`Graph`](@ref) from `mesh` bound to `ctx` using `SCOTCH_contextBindGraph`.
"""
function bind_mesh(ctx::Context, mesh::Mesh)
    ctx_mesh = mesh_alloc()
    @check LibScotch.SCOTCH_contextBindGraph(ctx, mesh, ctx_mesh)
    ctx_mesh.ctx = ctx
    return ctx_mesh
end
