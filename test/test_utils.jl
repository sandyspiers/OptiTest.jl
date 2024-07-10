@testset "utils.jl" begin
    # test all keys method
    d = Dict("x" => nothing, "y" => 5)
    @test all_keys(d) == Set(["x", "y"])
    d = Dict("x" => nothing, "y" => Dict("z" => 5))
    @test all_keys(d) == Set(["x", "y", "z"])
end
