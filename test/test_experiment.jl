@testset "experiments.jl" begin
    @testset "distributed" begin
        # sleeper helper fn
        function sleep_id(test_dict)
            sleep(0.25)
            test_dict["id"] = myid()
            return test_dict
        end

        # simple experiment
        ex = Dict("x!" => 1:9)

        # check it runs without any workers (ie single threaded)
        rmprocs(workers())
        df = run(ex, sleep_id)
        @test length(df.id) == 9
        @test all(df.id .== 1)

        # add 3 workers
        addprocs(3)
        @everywhere import OptiTest
        df = run(ex, sleep_id)
        @test length(df.id) == 9
        @test minimum(df.id) < maximum(df.id)
        rmprocs(workers())
    end
end
