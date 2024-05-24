
random_proc(proc) = LibScotch.SCOTCH_randomProc(proc)
random_seed(seed) = LibScotch.SCOTCH_randomSeed(seed)
random_reset() = LibScotch.SCOTCH_randomReset()
random_val(max=typemax(SCOTCH_Num)) = LibScotch.SCOTCH_randomVal(max)


mutable struct Context
    ptr :: Ptr{LibScotch.SCOTCH_Context}
end

Base.cconvert(::Type{Ptr{LibScotch.SCOTCH_Context}}, c::Context) = c.ptr
Base.cconvert(::Type{Ptr{Cvoid}}, c::Context) = Ptr{Cvoid}(c.ptr)


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


random_clone(ctx::Context)      = LibScotch.SCOTCH_contextRandomClone(ctx)
random_seed(ctx::Context, seed) = LibScotch.SCOTCH_contextRandomSeed(ctx, seed)
random_reset(ctx::Context)      = LibScotch.SCOTCH_contextRandomReset(ctx)


function context_option(ctx::Context, option::Integer)
    option_val = Ref{SCOTCH_Num}(0)
    @check LibScotch.SCOTCH_contextOptionGetNum(ctx, option, option_val)
    return option_val[]
end

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


function bind_graph(ctx::Context, graph::Graph)
    ctx_graph = graph_alloc()
    @check LibScotch.SCOTCH_contextBindGraph(ctx, graph, ctx_graph)
    ctx_graph.ctx = ctx
    return ctx_graph
end


function bind_mesh(ctx::Context, mesh::Mesh)
    ctx_mesh = mesh_alloc()
    @check LibScotch.SCOTCH_contextBindGraph(ctx, mesh, ctx_mesh)
    ctx_mesh.ctx = ctx
    return ctx_mesh
end
