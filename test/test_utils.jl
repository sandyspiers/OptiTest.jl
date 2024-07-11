@testset "utils.jl" begin
    # test isapprox extension
    @test Dict("x" => 1, "y" => 2) ≈ Dict("y" => 2, "x" => 1)
    @test !(Dict("x" => 1, "y" => 2) ≈ Dict("y" => 1, "x" => 1))

    # test all keys method
    d = Dict("x" => nothing, "y" => 5)
    @test all_keys(d) == Set([("x",), ("y",)])
    d = Dict("x" => nothing, "y" => Dict("z" => 5))
    @test all_keys(d) == Set([("x",), ("y", "z")])

    # test rec get
    d = Dict("x" => nothing, "y" => Dict("z" => 5))
    @test rec_get(d, ("y", "z")) == 5

    # test rec set
    d = Dict("x" => nothing, "y" => Dict("z" => 5))
    rec_set!(d, ("y", "z"), 100)
    @test d["y"]["z"] == 100
end
