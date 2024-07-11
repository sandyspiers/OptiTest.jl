@testset "utils.jl" begin
    # test all keys method
    d = Dict("x" => nothing, "y" => 5)
    @test all_keys(d) == Set(["x", "y"])
    d = Dict("x" => nothing, "y" => Dict("z" => 5))
    @test all_keys(d) == Set(["x", "y", "z"])

    # test isapprox extension
    @test Dict("x" => 1, "y" => 2) ≈ Dict("y" => 2, "x" => 1)
    @test !(Dict("x" => 1, "y" => 2) ≈ Dict("y" => 1, "x" => 1))

    # test flatten
    dict = Dict("x" => 1, "y" => Dict("aa" => rand, "b" => max))
    @test flatten(dict) ≈ Dict(("x") => 1, ("y", "aa") => rand, ("y", "b") => max)
    dict = Dict(("x") => 1, ("y", "aa") => rand, ("y", "b") => max)
    @test flatten(dict) ≈ Dict(("x") => 1, ("y", "aa") => rand, ("y", "b") => max)
    dict = Dict(
        "xx" => Dict("q" => Dict("10" => 10), "w" => Dict("2" => 20)),
        "y" => Dict("aa" => rand, "b" => max),
    )
    @test flatten(dict) ≈ Dict(
        ("xx", "q", "10") => 10,
        ("xx", "w", "2") => 20,
        ("y", "aa") => rand,
        ("y", "b") => max,
    )
end
