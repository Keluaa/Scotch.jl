```@meta
CurrentModule = Scotch
```

# Scotch

Documentation for [Scotch](https://github.com/Keluaa/Scotch.jl).

The official SCOTCH user manual is referenced everywhere is this documentation.
You can get the manual from the [official GitLab](https://gitlab.inria.fr/scotch/scotch/tree/master/doc).

Any SCOTCH function of the C library used within the wrapper is mentioned here.
Therefore you can search any SCOTCH function from this page to know what its Julia equivalent is.

All names starting with `SCOTCH_` are part of the C library.
You can access all symbols defined in the C library through `Scotch.LibScotch`.

## Strategy

```@docs
Strat
strat_alloc
strat_flags
strat
strat_build
```

## Architecture

```@docs
Arch
arch_alloc
arch_load
arch_size
arch_name
arch_build
arch_complete_graph
arch_hypercube
arch_mesh
arch_torus
arch_tree
arch_subset
```

## Graph

```@docs
Graph
graph_alloc
graph_size
graph_build
graph_base_index
graph_base_index!
graph_data
graph_dump
graph_load
graph_coarsen
graph_coarsen_match
graph_color
graph_diameter
graph_induce
graph_stat
```

### Mapping and partitioning

```@docs
graph_map
graph_remap
graph_part
graph_repart
```

## Mesh

```@docs
Mesh
mesh_alloc
mesh_build
mesh_data
mesh_load
mesh_graph
mesh_size
mesh_stat
```

## Block ordering

```@docs
block_ordering
```

## Context

```@docs
Context
context_alloc
random_clone
random_seed(::Context, ::Any)
random_reset(::Context)
context_option
context_option!
bind_graph
bind_mesh
```

## Utilities

```@docs
save
random_seed(::Any)
random_reset()
version
```

## Types

```@docs
SCOTCH_Num
SCOTCH_GraphPart2
```
