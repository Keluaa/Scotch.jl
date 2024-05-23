using Scotch
using Documenter

DocMeta.setdocmeta!(Scotch, :DocTestSetup, :(using Scotch); recursive=true)

makedocs(;
    modules=[Scotch],
    authors="Keluaa <34173752+Keluaa@users.noreply.github.com> and contributors",
    sitename="Scotch.jl",
    format=Documenter.HTML(;
        canonical="https://Keluaa.github.io/Scotch.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Keluaa/Scotch.jl",
    devbranch="main",
)
