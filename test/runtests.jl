using OptiTest
using Test
using Aqua

@testset "OptiTest.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(OptiTest)
    end
    # Write your tests here.
end
