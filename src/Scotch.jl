"""
    Scotch

Wrapper for the SCOTCH graph partitionning library.

The official SCOTCH user manual is referenced everywhere is this documentation.
You can get the user manual from the [official GitLab](https://gitlab.inria.fr/scotch/scotch/tree/master/doc).
"""
module Scotch

include("../gen/LibScotch.jl")

import .LibScotch: SCOTCH_Num, SCOTCH_GraphPart2


"""
    SCOTCH_Num

Integer type (should be a `Cint`/`Int32` on most machines).
"""
SCOTCH_Num


"""
    SCOTCH_GraphPart2

Small integer type (should be a `Cuchar`/`UInt8` on most machines).
"""
SCOTCH_GraphPart2


"""
    version()

The version of the loaded SCOTCH library. Calls `SCOTCH_version`.
"""
function version()
    major = Ref(Cint(0))
    minor = Ref(Cint(0))
    patch = Ref(Cint(0))
    LibScotch.SCOTCH_version(major, minor, patch)
    return VersionNumber(major[], minor[], patch[])
end


macro check(call)
    !Base.isexpr(call, :call) && error("expected function call, got: $call")
    func_name = call.args[1]

    # Unwrap `LibScotch.func_name` to `func_name`
    while Base.isexpr(func_name, :., 2)
        func_name = func_name.args[2]
        func_name isa QuoteNode && (func_name = func_name.value)
    end

    error_str = Expr(:string, "call to ", string(func_name), " returned ", :ret)
    return esc(quote
        ret = $call
        ret != 0 && error($error_str)
    end)
end


"""
    save(obj, filename::AbstractString)

Saves `obj` to the given `filename`.
"""
function save(obj, filename::AbstractString)
    open(filename, "w") do file
        save(obj, file)
    end
end


include("strat.jl")
include("arch.jl")
include("graph.jl")
include("mesh.jl")
include("context.jl")

# TODO: geometry handling routines (section 8.17)

end
