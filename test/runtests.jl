using Scotch
using Test
using Aqua

@testset "Scotch.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(Scotch)
    end
    # Write your tests here.
end
