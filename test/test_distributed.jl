@testset "distributed.jl" begin
    # basic example
    function sleep_id(x...)
        sleep(0.25)
        return myid()
    end
    ex = Experiment(
        "test",
        sleep_id,
        rand,
        Dict{Any,Any}("x!" => [10, 20, 30]),
        Dict{Any,Any}("solver!" => ["cat", "dog"]),
    )
    # remove workers
    rmprocs(workers())
    ids = run(ex)
    @test all(ids .== 1)

    # add 2 more
    addprocs(6)
    @everywhere import OptiTest
    ids = run(ex)
    @test minimum(ids) < maximum(ids)
    rmprocs(workers())
end
