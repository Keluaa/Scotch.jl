
using SCOTCH_jll
using Clang.Generators

cd(@__DIR__)

include_dir = joinpath(SCOTCH_jll.artifact_dir, "include")

options = load_options(joinpath(@__DIR__, "generator.toml"))

args = get_default_args()
push!(args, "-I$include_dir")

headers = [joinpath(include_dir, "scotch.h")]

ctx = create_context(headers, args, options)

build!(ctx)
