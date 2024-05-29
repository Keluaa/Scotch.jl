
using SCOTCH_jll
using Clang.Generators

cd(@__DIR__)

include_dir = joinpath(SCOTCH_jll.artifact_dir, "include")

options = load_options(joinpath(@__DIR__, "generator.toml"))

args = get_default_args()
push!(args, "-I$include_dir")

# 'scotch.h' does not include 'stdio.h' and therefore references to 'FILE*' are undefined.
headers = [joinpath(@__DIR__, "include_stdio.h")]

ctx = create_context(headers, args, options)

build!(ctx)
