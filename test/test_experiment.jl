@testset "experiments.jl" begin
    ex = Experiment(
        "test",
        (x...) -> println(x...),
        rand,
        Dict{Any,Any}("x!" => [10, 20, 30]),
        Dict{Any,Any}("solver!" => ["cat", "dog"]),
    )
    @test length(tests!(ex)) == 6
end
