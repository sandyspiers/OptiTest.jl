@testset "experiments.jl" begin
    @testset "_iterate" begin
        @test _iterate(1) == 1
        @test _iterate([1, 2, 3]) == [1, 2, 3]
        @test _iterate(Iterable(1:10)) == 1:10

        nt = (x=Iterable(1:10),)
        iters = _iterate(nt)
        @test length(iters) == 10
        @test first(iters).x == 1
        @test last(iters).x == 10

        nt = (x=Iterable(1:10), y=Iterable([:a, :b]), z=rand)
        iters = _iterate(nt)
        @test length(iters) == 20
        @test first(iters).x == 1
        @test last(iters).x == 10
        @test first(iters).y == :a
        @test last(iters).y == :b
        @test first(iters).z == rand

        nt = (x=Iterable([1, Iterable(2:10)]), y=Iterable([:a, :b]))
        iters = _iterate(nt)
        @test length(iters) == 20
        @test first(iters).x == 1
        @test last(iters).x == 10
        @test first(iters).y == :a
        @test last(iters).y == :b

        nt = (x=Iterable(1:3), y=FlattenIterable([(a=:a,), (a=Iterable([:b, :c]),)]))
        iters = _iterate(nt)
        @test length(iters) == 9
        @test first(iters).x == 1
        @test last(iters).x == 3
        @test_throws Exception first(iters).y
        @test first(iters).a == :a
        @test last(iters).a == :c
    end
    @testset "Experiment" begin
        ex = Experiment(;#
            a=FlattenIterable((#
                x=Iterable(1:10),
                s=Seed(0),
            )),
            b=Iterable([:a, :b]),
        )
        test = tests(ex)
        @test length(test) == 20
        @test first(test).x == 1
        @test_throws Exception first(test).a
        @test first(test).b == :a
        @test last(test).x == 10
        @test last(test).s == 10
        @test last(test).b == :b
    end
end
